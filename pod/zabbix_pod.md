| [↩️ Back](./) |
| --- |

# ZABBIX PODMAN POD

Nowadays there are several reasons to use containers and some tools are available to manage them. [Podman](https://podman.io/) is such a tool, and besides Docker, it uses the [concept of Pods](https://kubernetes.io/docs/concepts/workloads/pods/), commonly used in Kubernetes.

Zabbix SIA provides Docker images for each Zabbix component to run as a portable and self-sufficient container. Also, [Docker Compose files](https://www.zabbix.com/documentation/current/en/manual/installation/containers) are available to define and run multi-container Zabbix components in Docker. Since Podman can use Docker images, it is easy to port them to a Pod context. One [can even use the compose file](https://github.com/containers/podman-compose) to launch Zabbix containers. However, out-of-the-box Podman is not ready to run the compose files.

There are multiple Zabbix components that are constantly communicating with each other. When deploying Zabbix components as containers, they must be tightly coupled and may need to share resources. With the Pod concept, these containers can form a single cohesive unit. So, to let Zabbix benefit from Podman's improvements, here's a simplified Pod proposal for Zabbix components in a Shell script format.

There are other differences between Podman and Docker, but this proposal is mainly intended for quick testing and development of Zabbix environments, while taking advantage of some of Podman's benefits.

<BR>

## Possible benefits

- ⭐ Rootless container environment
- ⭐ Container isolation and shared resources within a Pod

<BR>

## Requirements

> **Many distributions offer packages for Podman, including Windows. Yet, this is a Shell script designed to run in a Linux environment.**

- 🛠️ [Install Podman](https://podman.io/docs/installation)
- 🛠️ [Basic setup](https://github.com/containers/podman/blob/main/docs/tutorials/podman_tutorial.md)
- 🛠️ [Rootless environment](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)
- 🛠️ [SystemD TimedateD](https://www.freedesktop.org/wiki/Software/systemd/timedated/) - _for timezone reading_

<BR>

---

### ➡️ [Script Download](./zabbixpod.sh)

---

<BR>

## Quick Setup

1. Copy the script to your environment
2. Make the script executable
    - `chmod +x zabbixpod.sh`
3. With Podman installed, start the script
    - `./zabbixpod.sh`
4. Access the Zabbix Frontend
    - `http://host.ip:8080`

<BR>

## The Script

⚠️ **The script has a number of variables to set up the Zabbix Pod environment. They can all be changed to suit your needs. However, it is recommended that you only change the first set of variables to avoid errors.**

```shell
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
```

<BR>

**1.** The script first creates a Pod called `zabbix[VERSION]pod`.

**2.** Most of the attributes that make up the Pod are assigned to the `infra` container and cannot be changed once it is created. It has some volumes associated with it for the database, Zabbix server, and agent files, which allows for some data persistence.

```shell
[user@host ~]$ tree zabbixpod/
zabbixpod/
├── agent
├── mysql
│   ├── conf
│   └── data
└── server
    ├── alertscripts
    ├── externalscripts
    └── snmptraps
```

**3.** The Pod also binds some ports for Zabbix to receive connections.
- `8080/TCP` for Web access to Zabbix Frontend.
- `10051/TCP` for hosts to connect to Zabbix Server.
- `1162/UDP` for Zabbix to receive SNMP traps.

**4.** Following the Pod, a MySQL container is created. It is not binded to a routable network accessible from outside the Pod. Its credentials are set in the first variable set.

**5.** Next, Zabbix component containers are created all binded to the `localhost` address of the Pod as a shared network name space. They are:

- `Zabbix Server`
- `Zabbix Web Frontend`
- `Zabbix SNMPTraps`
- `Zabbix Web Service`
- `Zabbix Agent 2`
- `Selenium Grid Standalone Chrome`

**6.** The **first time** the Pod is launched, it may take **about 2 minutes to be able to access the Zabbix Frontend** while the database is being created.

**7.** SystemD is configured to control the Pod as a service, and the `systemctl --user` command can be used to start and stop the service.

> ⚠️ When the rootless user logs out of their session, any running containers are stopped. It is best to enable user lingering for your particular user so that the Pod can run automatically. If required, run the following command **as root**: `sudo loginctl enable-linger [user]`.

<BR>

## Test

In a small environment, very few resources are required to run this type of Pod, as shown in the image below. However, long-term stability has not been verified, and your mileage may vary depending on your requirements.

![Pod resources consumption](./image/resources.png)

For testing purposes, let's create an environment to run the Zabbix Pod.

<BR>

### Environment

> _As of this writing, I'm testing with Zabbix 7.0 LTS._

🧪 **`Oracle Linux Server 9.4`**

🧪 **`Podman 4.9.4-rhel`**

<BR>

### Execution

Run the script (`./zabbixpod.sh`), and then it will create the containers inside the Pod. If the images are not found locally, Podman will download them, just like Docker.

```
[user@pods ~]$ ./zabbixpod70.sh 
577719cbbaf4e70804751b6e37633c5fcd0e11af3d46f0beba122f8deda1c3a5
5deb71310c4997ed0d0be498bfe55153fcce75dc82b9de93f1ef09d08924555d
815fb0b068ce70b9094ef4f79a204d18c30371deaa0504d85fe2264305395e3e
3c330dd51a455283fec18f735ad335ab957626210d938eea70ff8053e1d9870c
e3ce0dc04c355e8598696149c3cb2ec913d6b00c7544657c8dc65e6db1e1e36c
114790303cfe1d1d0d1b43200b98373049d8679288c3e01c122657db5b8216c1
cc17ba20432416cc3e61ff44852bdfc9a91fa5753d0125d96ab501853a91f788
cef75dcb93117b13fcdc76b65dd5a98f378960164133e652058b8c98fe98fcba

mkdir: created directory '/home/user/.config/systemd'
mkdir: created directory '/home/user/.config/systemd/user'

/home/user/.config/systemd/user/container-zabbix70-mysql.service
/home/user/.config/systemd/user/container-zabbix70-server.service
/home/user/.config/systemd/user/pod-zabbix70pod.service
/home/user/.config/systemd/user/container-zabbix70-web-nginx-mysql.service
/home/user/.config/systemd/user/container-zabbix70-snmptraps.service
/home/user/.config/systemd/user/container-zabbix70-web-service.service
/home/user/.config/systemd/user/container-zabbix70-agent2.service
/home/user/.config/systemd/user/container-zabbix70-selenium.service

Created symlink /home/user/.config/systemd/user/default.target.wants/pod-zabbix70pod.service → /home/user/.config/systemd/user/pod-zabbix70pod.service.

● pod-zabbix70pod.service - Podman pod-zabbix70pod.service
     Loaded: loaded (/home/user/.config/systemd/user/pod-zabbix70pod.service; enabled; preset: disabled)
     Active: active (running) since Mon 2024-09-02 00:23:49 -03; 49ms ago
       Docs: man:podman-generate-systemd(1)
    Process: 15313 ExecStart=/usr/bin/podman start zabbix70pod-infra (code=exited, status=0/SUCCESS)
   Main PID: 15341 (conmon)
      Tasks: 15 (limit: 190758)
     Memory: 6.4M
        CPU: 52ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/pod-zabbix70pod.service
             ├─15324 /usr/bin/slirp4netns --disable-host-loopback --mtu=65520 --enable-sandbox --enable-seccomp --enable-ipv6 -c -r 3 -e 4 --netns-type=path /run/user/1000/netns>
             ├─15325 /usr/bin/fuse-overlayfs -o lowerdir=/home/user/.local/share/containers/storage/overlay/l/QQLZ5V6BC4UP4YOCZCQT6LM5DY,upperdir=/home/user/.local/share/container>
             ├─15328 rootlessport
             ├─15333 rootlessport-child
             └─15341 /usr/bin/conmon --api-version 1 -c cc6955806f559ebe67ad7a6ec23713317f349868a0bea0f08783bcbffdfb5c2e -u cc6955806f559ebe67ad7a6ec23713317f349868a0bea0f08783b>

Zabbix Pod started at http://192.168.7.102:8080
```

To confirm the Pod execution, just list it (`podman pod list`) and its containers (`podman ps -ap`).

```
[user@pods ~]$ podman pod list
POD ID        NAME         STATUS      CREATED         INFRA ID      # OF CONTAINERS
577719cbbaf4  zabbix70pod  Running     13 minutes ago  cc6955806f55  8

[user@pods ~]$ podman ps -ap
CONTAINER ID  IMAGE                                                  COMMAND               CREATED         STATUS         PORTS                                                                    NAMES                     POD ID        PODNAME
cc6955806f55  localhost/podman-pause:4.9.4-rhel-1721808536                                 13 minutes ago  Up 13 minutes  0.0.0.0:8080->8080/tcp, 0.0.0.0:10051->10051/tcp, 0.0.0.0:1162->162/udp  zabbix70pod-infra         577719cbbaf4  zabbix70pod
5deb71310c49  docker.io/library/mysql:lts                            --character-set-s...  13 minutes ago  Up 13 minutes  0.0.0.0:8080->8080/tcp, 0.0.0.0:10051->10051/tcp, 0.0.0.0:1162->162/udp  zabbix70-mysql            577719cbbaf4  zabbix70pod
815fb0b068ce  docker.io/zabbix/zabbix-server-mysql:ol-7.0-latest     /usr/sbin/zabbix_...  13 minutes ago  Up 13 minutes  0.0.0.0:8080->8080/tcp, 0.0.0.0:10051->10051/tcp, 0.0.0.0:1162->162/udp  zabbix70-server           577719cbbaf4  zabbix70pod
3c330dd51a45  docker.io/zabbix/zabbix-web-nginx-mysql:ol-7.0-latest                        13 minutes ago  Up 13 minutes  0.0.0.0:8080->8080/tcp, 0.0.0.0:10051->10051/tcp, 0.0.0.0:1162->162/udp  zabbix70-web-nginx-mysql  577719cbbaf4  zabbix70pod
e3ce0dc04c35  docker.io/zabbix/zabbix-snmptraps:ol-7.0-latest        /usr/sbin/snmptra...  13 minutes ago  Up 13 minutes  0.0.0.0:8080->8080/tcp, 0.0.0.0:10051->10051/tcp, 0.0.0.0:1162->162/udp  zabbix70-snmptraps        577719cbbaf4  zabbix70pod
114790303cfe  docker.io/zabbix/zabbix-web-service:ol-7.0-latest      /usr/sbin/zabbix_...  13 minutes ago  Up 13 minutes  0.0.0.0:8080->8080/tcp, 0.0.0.0:10051->10051/tcp, 0.0.0.0:1162->162/udp  zabbix70-web-service      577719cbbaf4  zabbix70pod
cc17ba204324  docker.io/zabbix/zabbix-agent2:ol-7.0-latest           /usr/sbin/zabbix_...  13 minutes ago  Up 13 minutes  0.0.0.0:8080->8080/tcp, 0.0.0.0:10051->10051/tcp, 0.0.0.0:1162->162/udp  zabbix70-agent2           577719cbbaf4  zabbix70pod
cef75dcb9311  docker.io/selenium/standalone-chrome:latest            /opt/bin/entry_po...  13 minutes ago  Up 13 minutes  0.0.0.0:8080->8080/tcp, 0.0.0.0:10051->10051/tcp, 0.0.0.0:1162->162/udp  zabbix70-selenium         577719cbbaf4  zabbix70pod
```

> _**Note that the Pod was created under a non-privileged user (`~`) and all data is stored in the user's home directory with the same name as the Pod.**_

The Zabbix Frontend should be accessible at `http://host.ip:8080`. The default user and password are `Admin` and `zabbix` respectively.

You can also create multiple pods for different versions of Zabbix on the same system. Note, however, that each pod should use a different set of binded ports. These should be configured in the script variable set.

<BR>

| [⬆️ Top](#zabbix-podman-pod) |
| --- |