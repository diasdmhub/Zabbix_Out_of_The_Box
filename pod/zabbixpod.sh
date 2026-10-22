#!/usr/bin/env bash
# SCRIPT TO CREATE A POD AND ZABBIX CONTAINERS
# by diasdm


# CHANGE VARIABLES HERE IF REQUIRED
ZBXMAJORVER="8"            # ZABBIX MAJOR VERSION
ZBXMINORVER="0"            # ZABBIX MINOR VERSION
DBROOTPASS="zabbix"        # DBMS ROOT PASSWORD
DBNAME="zabbix"            # ZABBIX DATABASE NAME
DBUSER="zabbix"            # ZABBIX DATABASE USER
DBPASS="zabbix"            # ZABBIX DATABASE PASSWORD
PORTWEB="8080"             # ZABBIX FRONTEND WEB PORT
PORTSNMP="1162"            # SNMP TRAP PORT
PORTMCP="8443"             # ZABBIX MCP SERVER PORT (ZABBIX 8.0+)
MCPALLOWEDIP="127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"    # MCP CLIENTS ALLOWED (ZABBIX 8.0+)
OSTAG="ol"                 # OS BASE IMAGE TAG


# VARIABLES SET
ZBXVER="${ZBXMAJORVER}.${ZBXMINORVER}"
ZBXSERVERNAME="zabbix${ZBXMAJORVER}${ZBXMINORVER}"
PODNAME="${ZBXSERVERNAME}pod"
ZBXTAG="${OSTAG}-${ZBXVER}-latest"
TIMEZ="$(timedatectl show --value -p Timezone)"    # LOCAL TIMEZONE IN PHP FORMAT
DBTAG="lts"
SELENIUMTAG="latest"
AUTOUPDATEREG="docker.io/library/io.containers.autoupdate=registry"
MCPMINMAJORVER="8"         # FIRST ZABBIX MAJOR VERSION WITH THE MCP SERVER
DBUPGRADECNF="$HOME/$PODNAME/mysql/conf/zbx_db_upgrade.cnf"    # TEMPORARY MYSQL OPTIONS FOR DB CREATION/UPGRADE
DBUPGRADETIMEOUT="1800"    # MAX SECONDS TO WAIT FOR THE DB CREATION/UPGRADE

# ZABBIX MCP SERVER IS ONLY AVAILABLE FROM ZABBIX 8.0 ONWARDS
if [ "$ZBXMAJORVER" -ge "$MCPMINMAJORVER" ]; then
    ZBXMCP="true"
    PODMCPPORT=(-p "$PORTMCP":8443)
else
    ZBXMCP="false"
    PODMCPPORT=()
fi


# VOLUME DIRECTORIES SET

[ -z "$HOME" ] && { printf "\nFailed to open the home directory \"%s\"\n" "$HOME" ; exit 1; }

[ -d "$HOME/$PODNAME" ] || mkdir -p "$HOME/$PODNAME/mysql/data" ; \
    mkdir -p "$HOME/$PODNAME/mysql/conf" ; \
    mkdir -p "$HOME/$PODNAME/agent" ; \
    mkdir -p "$HOME/$PODNAME/server/alertscripts" ; \
    mkdir -p "$HOME/$PODNAME/server/externalscripts" ; \
    mkdir -p "$HOME/$PODNAME/server/snmptraps"

# ALLOWS ZABBIX TO CREATE TRIGGERS WHILE BINARY LOGGING IS ENABLED (DB CREATION/UPGRADE ONLY)
# Removed by the "DATABASE UPGRADE SET" step once Zabbix Server has started
printf "[mysqld]\nlog_bin_trust_function_creators=1\n" > "$DBUPGRADECNF" || { printf "\nFailed to create \"%s\"\n" "$DBUPGRADECNF" ; exit 1; }
chmod 644 "$DBUPGRADECNF"


# POD CREATION
printf "\n%s POD CREATION\n" "$PODNAME"

podman pod create \
    --name "$PODNAME" \
    --infra-name "$PODNAME"-infra \
    -p "$PORTWEB":8080 \
    -p "$PORTSNMP":162/udp \
    -p 10051:10051 \
    "${PODMCPPORT[@]}" \
    -v "$HOME/$PODNAME"/mysql/data:/var/lib/mysql:z \
    -v "$HOME/$PODNAME"/mysql/conf:/etc/mysql/conf.d:z \
    -v "$HOME/$PODNAME"/agent:/etc/zabbix/zabbix_agentd.d:z \
    -v "$HOME/$PODNAME"/server/alertscripts:/usr/lib/zabbix/alertscripts:z \
    -v "$HOME/$PODNAME"/server/externalscripts:/usr/lib/zabbix/externalscripts:z \
    -v "$HOME/$PODNAME"/server/snmptraps:/var/lib/zabbix/snmptraps:z

## CONTAINER SET ##

# ZABBIX DBMS CONTAINER
printf "\n%s-mysql CONTAINER CREATION\n" "$ZBXSERVERNAME"

podman create \
    --name $ZBXSERVERNAME-mysql \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --init \
    --tz=local \
    --label "$AUTOUPDATEREG" \
    -e MYSQL_ROOT_PASSWORD="$DBROOTPASS" \
    docker.io/mysql:"$DBTAG" \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_bin

# ZABBIX SERVER CONTAINER
printf "\n%s-server CONTAINER CREATION\n" "$ZBXSERVERNAME"

podman create \
    --name $ZBXSERVERNAME-server \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --init \
    --cap-add=net_raw \
    --tz=local \
    --label "$AUTOUPDATEREG" \
    -e DB_SERVER_HOST="$ZBXSERVERNAME-mysql" \
    -e DB_SERVER_PORT="3306" \
    -e MYSQL_ROOT_PASSWORD="$DBROOTPASS" \
    -e MYSQL_DATABASE="$DBNAME" \
    -e MYSQL_USER="$DBUSER" \
    -e MYSQL_PASSWORD="$DBPASS" \
    -e ZBX_ALLOWUNSUPPORTEDDBVERSIONS=1 \
    -e ZBX_IPMIPOLLERS=1 \
    -e ZBX_STARTCONNECTORS=1 \
    -e ZBX_STARTVMWARECOLLECTORS=1 \
    -e ZBX_ENABLE_SNMP_TRAPS=true \
    -e ZBX_STARTREPORTWRITERS=1 \
    -e ZBX_WEBSERVICEURL=http://$ZBXSERVERNAME-web-service:10053/report \
    -e ZBX_WEBDRIVERURL=http://$ZBXSERVERNAME-selenium:4444 \
    -e ZBX_STARTBROWSERPOLLERS=4 \
    -e ZBX_NODEADDRESS="${ZBXSERVERNAME}-server" \
    docker.io/zabbix/zabbix-server-mysql:"$ZBXTAG"

# ZABBIX FRONTEND CONTAINER
printf "\n%s-web-nginx-mysql CONTAINER CREATION\n" "$ZBXSERVERNAME"

podman create \
    --name $ZBXSERVERNAME-web-nginx-mysql \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --tz=local \
    --init \
    --label "$AUTOUPDATEREG" \
    -e DB_SERVER_HOST="$ZBXSERVERNAME-mysql" \
    -e DB_SERVER_PORT="3306" \
    -e MYSQL_DATABASE="$DBNAME" \
    -e MYSQL_USER="$DBUSER" \
    -e MYSQL_PASSWORD="$DBPASS" \
    -e ZBX_SERVER_NAME="${ZBXSERVERNAME}_Pod" \
    -e PHP_TZ="$TIMEZ" \
    -e EXPOSE_WEB_SERVER_INFO="on" \
    -e ZBX_SERVER_HOST="${ZBXSERVERNAME}-server" \
    docker.io/zabbix/zabbix-web-nginx-mysql:"$ZBXTAG"

# ZABBIX SNMPTRAPS CONTAINER
printf "\n%s-snmptraps CONTAINER CREATION\n" "$ZBXSERVERNAME"

podman create \
    --name $ZBXSERVERNAME-snmptraps \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --tz=local \
    --init \
    --label "$AUTOUPDATEREG" \
    docker.io/zabbix/zabbix-snmptraps:"$ZBXTAG"

# ZABBIX WEB SERVICE CONTAINER
printf "\n%s-web-service CONTAINER CREATION\n" "$ZBXSERVERNAME"

podman create \
    --name $ZBXSERVERNAME-web-service \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --tz=local \
    --init \
    --cap-add=SYS_ADMIN \
    --label "$AUTOUPDATEREG" \
    -e ZBX_ALLOWEDIP="$ZBXSERVERNAME-server" \
    docker.io/zabbix/zabbix-web-service:"$ZBXTAG"

# ZABBIX AGENT 2 CONTAINER
printf "\n%s-agent2 CONTAINER CREATION\n" "$ZBXSERVERNAME"

podman create \
    --name $ZBXSERVERNAME-agent2 \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --tz=local \
    --privileged \
    --init \
    --label "$AUTOUPDATEREG" \
    -e ZBX_HOSTNAME="$ZBXSERVERNAME-server" \
    -e ZBX_SERVER_HOST="$ZBXSERVERNAME-server" \
    -e ZBX_PASSIVE_ALLOW="true" \
    -e ZBX_ACTIVE_ALLOW="true" \
    docker.io/zabbix/zabbix-agent2:"$ZBXTAG"

# SELENIUM GRID STANDALONE WITH CHROME - For browser item
printf "\n%s-selenium CONTAINER CREATION\n" "$ZBXSERVERNAME"

podman create \
    --name $ZBXSERVERNAME-selenium \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --tz=local \
    --init \
    --shm-size-systemd=0 \
    --label "$AUTOUPDATEREG" \
    -e TZ="$TIMEZ" \
    -e SE_START_VNC=false \
    -e SE_ENABLE_TRACING=false \
    -e SE_ENABLE_BROWSER_LEFTOVERS_CLEANUP=true \
    -e SE_BROWSER_LEFTOVERS_INTERVAL_SECS=7200 \
    -e SE_BROWSER_LEFTOVERS_PROCESSES_SECS=3600 \
    -e SE_BROWSER_LEFTOVERS_TEMPFILES_DAYS=2 \
    docker.io/selenium/standalone-chrome:"$SELENIUMTAG"

# ZABBIX MCP SERVER CONTAINER - Only for Zabbix 8.0+
if [ "$ZBXMCP" = "true" ]; then
    printf "\n%s-mcp-server CONTAINER CREATION\n" "$ZBXSERVERNAME"

    podman create \
        --name $ZBXSERVERNAME-mcp-server \
        --stop-signal SIGHUP \
        --pod "$PODNAME" \
        --tz=local \
        --init \
        --label "$AUTOUPDATEREG" \
        -e ZBX_FRONTEND_URL="http://$ZBXSERVERNAME-web-nginx-mysql:8080/api_jsonrpc.php" \
        -e ZBX_ALLOWEDIP="$MCPALLOWEDIP" \
        docker.io/zabbix/zabbix-mcp-server:"$ZBXTAG"
fi


## SYSTEMD SET ##
printf "\nSYSTEMD \"%s.service\" SERVICE CREATION\n" "$PODNAME"



# Skips the next steps if the user is root
if [ "$(id -u)" -ne 0 ]; then
    SERVDIR="$HOME/.config/systemd/user"
    SYSD_U_PARM="--user"

    # When logging in from another user
    if [ -z "${XDG_RUNTIME_DIR}" ]; then
        printf "\nXDG_RUNTIME_DIR var not set. Exporting it\n"
        export XDG_RUNTIME_DIR="/run/user/${UID}"
        printf '\nexport XDG_RUNTIME_DIR="/run/user/%s"' "$UID" >> "$HOME"/.bashrc
    fi
    if [ -z "${DBUS_SESSION_BUS_ADDRESS}" ]; then
        printf "\nDBUS_SESSION_BUS_ADDRESS var not set. Exporting it\n"
        export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
        printf '\nexport DBUS_SESSION_BUS_ADDRESS="unix:path=%s/bus"' "${XDG_RUNTIME_DIR}" >> "$HOME"/.bashrc
    fi

    # CHECK FOR THE DEFAULT SYSTEMD SERVICE USER DIRECTORY
    [ -d "$SERVDIR" ] || mkdir -v -p "$SERVDIR"

    # GENERATE THE POD SYSTEMD SERVICES
    cd "$SERVDIR"
fi

if [ "$(id -u)" -eq 0 ]; then
    cd "/usr/lib/systemd/system/" || { printf "\nFailed to open SystemD directory \"/usr/lib/systemd/system/\"\n" ; exit 1; }
    SYSD_U_PARM=" "
fi

podman generate systemd -f --pod-prefix "" --name "$PODNAME"
cd "$HOME"
printf "\n"
systemctl $SYSD_U_PARM daemon-reload
systemctl $SYSD_U_PARM enable "$PODNAME.service"
systemctl $SYSD_U_PARM start "$PODNAME.service"
systemctl $SYSD_U_PARM --no-pager status "$PODNAME.service"


## DATABASE UPGRADE SET ##
printf "\nWAITING FOR THE ZABBIX DATABASE CREATION/UPGRADE (UP TO %s SECONDS)\n" "$DBUPGRADETIMEOUT"

DBUPGRADESTATUS="timeout"
SECONDS=0
while [ "$SECONDS" -lt "$DBUPGRADETIMEOUT" ]; do
    ZBXSERVERLOG="$(podman logs "$ZBXSERVERNAME-server" 2>&1)"
    if printf "%s" "$ZBXSERVERLOG" | grep -q "database upgrade failed"; then
        DBUPGRADESTATUS="failed"
        break
    fi
    if printf "%s" "$ZBXSERVERLOG" | grep -q "server #0 started"; then
        DBUPGRADESTATUS="done"
        break
    fi
    sleep 10
done

if [ "$DBUPGRADESTATUS" = "done" ]; then
    # Reverts log_bin_trust_function_creators at runtime and for the next MySQL restarts
    podman exec -e MYSQL_PWD="$DBROOTPASS" "$ZBXSERVERNAME-mysql" \
        mysql -uroot -e "SET GLOBAL log_bin_trust_function_creators = 0;" \
        && rm -f "$DBUPGRADECNF" \
        && printf "\nZabbix database ready. log_bin_trust_function_creators set back to 0\n"
else
    printf "\nZabbix database creation/upgrade %s. log_bin_trust_function_creators remains 1\n" "$DBUPGRADESTATUS"
    printf "Check the log: podman logs -f %s-server\n" "$ZBXSERVERNAME"
    printf "When finished, run:\n"
    printf "  podman exec -it %s-mysql mysql -uroot -p -e \"SET GLOBAL log_bin_trust_function_creators = 0;\"\n" "$ZBXSERVERNAME"
    printf "  rm -f \"%s\"\n" "$DBUPGRADECNF"
fi

printf "\nZabbix Pod started at http://$(hostname -I | cut -d ' ' -f 1):%s\n\n" "$PORTWEB"
