#!/bin/bash
# SCRIPT TO CREATE A POD AND ZABBIX CONTAINERS
# by diasdm


# CHANGE VARIABLES HERE IF REQUIRED
ZBXMAJORVER="7"            # ZABBIX MAJOR VERSION
ZBXMINORVER="0"            # ZABBIX MINOR VERSION
DBROOTPASS="zabbix"        # DBMS ROOT PASSWORD
DBNAME="zabbix"            # ZABBIX DATABASE PASSWORD
DBUSER="zabbix"            # ZABBIX DATABASE USER
DBPASS="zabbix"            # ZABBIX DATABASE PASSWORD
PORTWEB="8080"             # ZABBIX FRONTEND WEB PORT
PORTSNMP="1162"            # SNMP TRAP PORT
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


# VOLUME DIRECTORIES SET
[ -d "$HOME/$PODNAME" ] || mkdir -p "$HOME/$PODNAME/mysql/data" ; \
    mkdir -p "$HOME/$PODNAME/mysql/conf" ; \
    mkdir -p "$HOME/$PODNAME/agent" ; \
    mkdir -p "$HOME/$PODNAME/server/alertscripts" ; \
    mkdir -p "$HOME/$PODNAME/server/externalscripts" ; \
    mkdir -p "$HOME/$PODNAME/server/snmptraps"


# POD CREATION
printf "\n$PODNAME POD CREATION\n"

podman pod create \
    --name "$PODNAME" \
    --infra-name "$PODNAME"-infra \
    -p "$PORTWEB":8080 \
    -p "$PORTSNMP":162/udp \
    -p 10051:10051 \
    -v "$HOME/$PODNAME"/mysql/data:/var/lib/mysql:z \
    -v "$HOME/$PODNAME"/mysql/conf:/etc/mysql/conf.d:z \
    -v "$HOME/$PODNAME"/agent:/etc/zabbix/zabbix_agentd.d:z \
    -v "$HOME/$PODNAME"/server/alertscripts:/usr/lib/zabbix/alertscripts:z \
    -v "$HOME/$PODNAME"/server/externalscripts:/usr/lib/zabbix/externalscripts:z \
    -v "$HOME/$PODNAME"/server/snmptraps:/var/lib/zabbix/snmptraps:z

## CONTAINER SET ##

# ZABBIX DBMS CONTAINER
printf "\n$ZBXSERVERNAME-mysql CONTAINER CREATION\n"

podman create \
    --name $ZBXSERVERNAME-mysql \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --init \
    --tz=local \
    --label "$AUTOUPDATEREG" \
    -e MYSQL_ROOT_PASSWORD="$DBROOTPASS" \
    docker.io/library/mysql:"$DBTAG" \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_bin

# ZABBIX SERVER CONTAINER
printf "\n$ZBXSERVERNAME-server CONTAINER CREATION\n"

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
    docker.io/zabbix/zabbix-server-mysql:"$ZBXTAG"

# ZABBIX FRONTEND CONTAINER
printf "\n$ZBXSERVERNAME-web-nginx-mysql CONTAINER CREATION\n"

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
    -e ZBX_SERVER_HOST="${ZBXSERVERNAME}-server" \
    -e ZBX_SERVER_NAME="${ZBXSERVERNAME}_Pod" \
    -e PHP_TZ="$TIMEZ" \
    -e EXPOSE_WEB_SERVER_INFO="on" \
    docker.io/zabbix/zabbix-web-nginx-mysql:"$ZBXTAG"

# ZABBIX SNMPTRAPS CONTAINER
printf "\n$ZBXSERVERNAME-snmptraps CONTAINER CREATION\n"

podman create \
    --name $ZBXSERVERNAME-snmptraps \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --tz=local \
    --init \
    --label "$AUTOUPDATEREG" \
    docker.io/zabbix/zabbix-snmptraps:"$ZBXTAG"

# ZABBIX WEB SERVICE CONTAINER
printf "\n$ZBXSERVERNAME-web-service CONTAINER CREATION\n"

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
printf "\n$ZBXSERVERNAME-agent2 CONTAINER CREATION\n"

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
printf "\n$ZBXSERVERNAME-selenium CONTAINER CREATION\n"

podman create \
    --name $ZBXSERVERNAME-selenium \
    --stop-signal SIGHUP \
    --pod "$PODNAME" \
    --tz=local \
    --init \
    --shm-size-systemd=0 \
    --label "$AUTOUPDATEREG" \
    -e TZ="$TIMEZ" \
    docker.io/selenium/standalone-chrome:"$SELENIUMTAG"


## SYSTEMD SET ##
printf "\nSYSTEMD \"$PODNAME.service\" SERVICE CREATION\n"

SERVDIR="$HOME/.config/systemd/user"

# When logging in from another user
if [[ -z ${XDG_RUNTIME_DIR} ]]; then
    printf "\nXDG_RUNTIME_DIR var not set. Exporting it\n"
    export XDG_RUNTIME_DIR="/run/user/${UID}"
    printf '\nexport XDG_RUNTIME_DIR="/run/user/${UID}"' >> $HOME/.bashrc
fi
if [[ -z ${DBUS_SESSION_BUS_ADDRESS} ]]; then
    printf "\nDBUS_SESSION_BUS_ADDRESS var not set. Exporting it\n"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
    printf '\nexport DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"' >> $HOME/.bashrc
fi

# CHECK FOR THE DEFAULT SYSTEMD SERVICE USER DIRECTORY
[ -d "$SERVDIR" ] || mkdir -v -p "$SERVDIR"

# GENERATE THE POD SYSTEMD SERVICES
cd "$SERVDIR"
podman generate systemd -f --pod-prefix "" --name "$PODNAME"
cd ~
systemctl --user daemon-reload
systemctl --user enable "$PODNAME.service"
systemctl --user start "$PODNAME.service"
systemctl --user --no-pager status "$PODNAME.service"

printf "\nZabbix Pod started at http://$(hostname -I | cut -d ' ' -f 1):$PORTWEB\n\n"