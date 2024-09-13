| [↩️ Back](./) |
| --- |

# ZABBIX PODMAN POD

Nowadays there are several reasons to use containers and some tools are available to manage them. [Podman](https://podman.io/) is such a tool, and besides Docker, it uses the [concept of Pods](https://kubernetes.io/docs/concepts/workloads/pods/), commonly used in Kubernetes.

Zabbix SIA provides Docker images for each Zabbix component to run as a portable and self-sufficient container. Also, [Docker Compose files](https://www.zabbix.com/documentation/current/en/manual/installation/containers) are available to define and run multi-container Zabbix components in Docker. Since Podman can use Docker images, it is easy to port them to a Pod context. One [can even use the compose file](https://github.com/containers/podman-compose) to launch Zabbix containers. However, out-of-the-box Podman is not ready to run the compose files.

There are multiple Zabbix components that are constantly communicating with each other. When deploying Zabbix components as containers, they must be tightly coupled and may need to share resources. With the Pod concept, these containers can form a single cohesive unit. So, to let Zabbix benefit from Podman's improvements, here's a simplified Pod proposal for Zabbix components in a Shell script format.

There are other differences between Podman and Docker, but this proposal is mainly intended for quick testing and development of Zabbix environments, while taking advantage of some of Podman's benefits.

<BR>

## Possible benefits

- ⭐ Fast deployment
- ⭐ Rootless container environment
- ⭐ Container isolation and shared resources within a Pod

<BR>

## Requirements

> **Many distributions offer packages for Podman, including Windows. Yet, this is a Shell script designed to run in a Linux environment.**

- 🛠️ [Install Podman](https://podman.io/docs/installation)
- 🛠️ [Basic setup](https://github.com/containers/podman/blob/main/docs/tutorials/podman_tutorial.md)
- 🛠️ [Rootless environment](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)
- 🛠️ [SystemD TimedateD](https://www.freedesktop.org/wiki/Software/systemd/timedated/) - _for timezone reading and Pod service management_

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

**2.** Most of the attributes that make up the Pod are assigned to the `infra` container and cannot be changed once it is created. It has some volumes associated with it for the database, Zabbix server, and agent files, which allows for some data persistence. The data directory name is the same as the Pod.

```shell
[user@host ~]$ tree zabbix[version]pod/
zabbix[version]pod/
├── agent
├── mysql
│   ├── conf
│   └── data
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

**5.** Next, Zabbix component containers are created all binded to the `localhost` address of the Pod as a shared network name space. Also, a a web driver container is created for Zabbix browser items. The containers are:

- `Zabbix Server`
- `Zabbix Web Frontend`
- `Zabbix SNMPTraps`
- `Zabbix Web Service`
- `Zabbix Agent 2`
- `Selenium Grid Standalone Chrome`

**6.** The **first time** the Pod is launched, it may take ⚠️ **about 2 minutes to be able to access the Zabbix Frontend** while the database is being created.

**7.** SystemD is configured to control the Pod as a service, and the **`systemctl --user`** command can be used to start and stop the service.

> ⚠️ When the rootless user logs out of their session, any running containers are stopped. It is best to enable user lingering for your particular user so that the Pod can run automatically. If required, run the following command **as root**: `sudo loginctl enable-linger [pod user]`.

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
zabbix70pod POD CREATION
9d2208fc0b06d5b2e5c9e69dacc9d9fc80c92df87fde30507480a9dfa46b74f8

zabbix70-mysql CONTAINER CREATION
6951f76a9e281d5dfc5b0954a3b7d585adda26820d95617c0fb09c3d0e0b6323

zabbix70-server CONTAINER CREATION
26c94c865a348c578a93d6e4f63132f5949c210cf90348bf84487f76202f0f44

zabbix70-web-nginx-mysql CONTAINER CREATION
adb221f118fff0b3ead70b046ad0f6099767ac6f4d9677b49166b3f012444760

zabbix70-snmptraps CONTAINER CREATION
6c9e0d95236e0f68509ad4624d84cf3fb8c8f25cf7541f1ab02bd38ed02096a1

zabbix70-web-service CONTAINER CREATION
c1ff29f5faddeba23378edb27a6e18b11ad40d9d80e250178c6b17eefbcfaf69

zabbix70-agent2 CONTAINER CREATION
9652eaf154776ba8fdca18678770519503be2fd4cb95069ef0341d0d196bd10f

zabbix70-selenium CONTAINER CREATION
65cc775c7e56de1ad5d28e012de98164c81b26fbe972b6185bc4ee1d588d1e16

SYSTEMD "zabbix70pod.service" SERVICE CREATION

mkdir: created directory '/home/user/.config/systemd'
mkdir: created directory '/home/user/.config/systemd/user'

/home/user/.config/systemd/user/container-zabbix70-web-nginx-mysql.service
/home/user/.config/systemd/user/container-zabbix70-snmptraps.service
/home/user/.config/systemd/user/container-zabbix70-web-service.service
/home/user/.config/systemd/user/container-zabbix70-agent2.service
/home/user/.config/systemd/user/container-zabbix70-selenium.service
/home/user/.config/systemd/user/zabbix70pod.service
/home/user/.config/systemd/user/container-zabbix70-mysql.service
/home/user/.config/systemd/user/container-zabbix70-server.service

Created symlink /home/user/.config/systemd/user/default.target.wants/zabbix70pod.service → /home/user/.config/systemd/user/zabbix70pod.service.

● zabbix70pod.service - Podman zabbix70pod.service
     Loaded: loaded (/home/user/.config/systemd/user/zabbix70pod.service; enabled; preset: disabled)
     Active: active (running) since Thu 2024-09-12 20:49:38 -03; 40ms ago
       Docs: man:podman-generate-systemd(1)
    Process: 15198 ExecStart=/usr/bin/podman start zabbix70pod-infra (code=exited, status=0/SUCCESS)
   Main PID: 15226 (conmon)
      Tasks: 15 (limit: 190757)
     Memory: 7.2M
        CPU: 52ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/zabbix70pod.service
             ├─15209 /usr/bin/fuse-overlayfs -o lowerdir=/home/user/.local/share/containers/storage/over…
             ├─15210 /usr/bin/slirp4netns --disable-host-loopback --mtu=65520 --enable-sandbox --enable…
             ├─15212 rootlessport
             ├─15218 rootlessport-child
             └─15226 /usr/bin/conmon --api-version 1 -c 78e532e811dc8d6667f50e927c505ba07b3b5d49933242e…

Zabbix Pod started at http://192.168.7.102:8080
```

To confirm the Pod execution, its service status is shown. You may also list Pods with `podman pod list` and its containers with `podman ps -ap`.

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

> _**Note that the Pod was created under a non-privileged user (`~`) and all data is stored in the user's home directory.**_

<BR>

The Zabbix Frontend should be accessible at `http://host.ip:8080`. \
The default user and password are `Admin` and `zabbix` respectively.

You can also create multiple pods for different versions of Zabbix on the same system. Note, however, that each pod should use a different set of binded ports. These should be configured in the script variable set.

<BR>

| [⬆️ Top](#zabbix-podman-pod) |
| --- |