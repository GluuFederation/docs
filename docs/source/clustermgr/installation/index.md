# Cluster Manager Installation

## Prerequisites

- A minimum of four (4) machines running **Ubuntu 18-20, CentOS 7/ RHEL 7 or CentOS 8/ RHEL 8**:
    - Cluster Manager: One (1) machine with at least 4GB of RAM for cluster manager, which will proxy TCP and HTTP traffic.
    - Load Balancer: One (1) machine 4GB of RAM for the Nginx load balancer and Twemproxy. This server is not necessary if you are using your own load balancer **and** you use Redis Cluster on the Gluu Server installations.
    - Gluu Server(s): At least two (2) machines with at least 8GB of RAM for Gluu Servers. *SeLinux should be disabled in case of nochroot installation*.
    - Redis Cache Server (optional): One (1) machine with at least 4GB of RAM if you want to use redis for caching.

## Ports

| Gluu Servers | Description |
| -- | -- |
| 22 | SSH |
| 443 | HTTPS |
| 30865 | Csync2 |
| 1636 | LDAPS |
| 4444 | LDAP Administration |
| 8989 | LDAP Replication |
| 16379 | Stunnel |

| Load Balancer | Description |
|--| --|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |

!!! Note
    The Load Balancer is the only node that should be externally accessible through 80 and 443 from outside your cluster network.

| Redis Cache Server | Description |
|--| --|
| 16379 | Stunnel |

| Cluster Manager | Description|
| -- | --|
| 22 | SSH |
|1636| LDAPS |

### Port Usage

- 22 will be used by Cluster Manager to pull logs and make adjustments to the systems

- 80 and 443 are self-explanatory. 443 must be open between the Load Balancer and the Gluu Server

- 1636, 4444 and 8989 are necessary for LDAP usage and replication. These should be open between Gluu Server nodes

- 30865 is the default port for Csync2 file system replication

- 16379 is for securing the caching communication between Gluu servers and Redis Cache Server over Stunnel

### Proxy

If you're behind a proxy, you'll have to configure it inside the container/chroot as well.

Log into each Gluu node and set the HTTP proxy in the container/chroot to your proxy's URL like so:

```

# /sbin/gluu-serverd login

Gluu.root# vi /etc/yum.conf

```

insert into the `[main]` section:

```

[main]
.
.
proxy=http://proxy.example.org:3128/

```

Save the file.

The following error will be shown in Cluster Manager if the proxy is not configured properly inside the chroot:

```
One of the configured repositories failed (Unknown), and yum doesn't have enough cached data to continue... etc.

Could not retrieve mirrorlist http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=updates&infra=stock error was 14: curl#7 - "Failed to connect to 2604:1580:fe02:2::10: Network is unreachable"
```

## Installing Cluster Manager

### SSH & Keypairs

Give Cluster Manager the ability to establish an SSH connection to the servers in the cluster. This includes the NGINX/load-balancing server. A simple key generation example:

`ssh-keygen -t rsa -b 4096 -m PEM`

- This will initiate a prompt to create a key pair. Cluster Manager must be able to open connections to the servers.

!!! Note
    Cluster Manager now works with encrypted keys and will prompt you for the password any time Cluster Manager is restarted.

- Copy the public key (default is `id_rsa.pub`) to the `/root/.ssh/authorized_keys` file of all servers in the cluster, including the Load Balancer (unless another load-balancing service will be used) and Redis Cache Server. **This MUST be the root authorized_keys.**


### Install Binary Package
If you are using CentOS 8 or RedHat 8 for Cluster Manager, you are in luck, we have rpm package. Steps to install Cluster Manager on these distrubutios:

1. Install Epel Release

    ```
    sudo rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    ```

    ```
    sudo yum clean all
    ```

2. Install Java

    ```
    sudo yum install java-1.8.0-openjdk
    ```

3. Install Cluster Manager

    ```
    sudo wget https://repo.gluu.org/rhel/Gluu-rhel-8-testing.repo -O /etc/yum.repos.d/Gluu.repo
    ```

    ```
    sudo wget https://repo.gluu.org/rhel/RPM-GPG-KEY-GLUU -O /etc/pki/rpm-gpg/RPM-GPG-KEY-GLUU
    ```

    ```
    sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-GLUU
    ```

    ```
    sudo yum clean all
    ```

    ```
    sudo yum install clustermgr
    ```

4. Download Key Generator

    ```
    sudo mkdir -p $HOME/.clustermgr4/javalibs
    ```

    ```
    sudo wget https://ox.gluu.org/maven/org/gluu/oxauth-client/4.3.0.Final/oxauth-client-4.3.0.Final-jar-with-dependencies.jar  -O  $HOME/.clustermgr4/javalibs/keygen.jar
    ```

5. Cluster Manager Service

    Enable Cluster Manager so that it startrs on boot

    ```
    sudo systemctl enable clustermgr
    ```

    Now start

    ```
    sudo systemctl start clustermgr
    ```

    You can see status

    ```
    sudo systemctl status clustermgr
    ```

    To stop
    
    ```
    sudo systemctl stop clustermgr
    ```

    Cluster Manager CLI can also be used for starting/stopping

    ```
    clustermgr4-cli start
    clustermgr4-cli stop
    ```

6. Connect Cluster Manager

    On your desktop, execute the following command:
    
    ```
    ssh -L 5000:localhost:5000 root@address.of.cluster.manager
    ```

Use address of you Cluster Manager machine for `address.of.cluster.manager`

Open your browser and point to http://localhost:5000

-->


### Install Using PyPi or Github

Most recent version of Cluster Manager is available on Github, once we decided it stable we push to PyPi. In this scetion we will explain how to install Cluster Manager using **pip**.

#### Install Dependencies on Ubuntu

Install the necessary dependencies on the Gluu Cluster Manager machine:

##### On Ubuntu 20

```
apt install python3-pip python3-dev libssl-dev libffi-dev
apt install openjdk-11-jre-headless
apt install build-essential
pip3 install https://github.com/GluuFederation/redislite/archive/master.zip
```

Install Cluster Manager from github
```
pip3 install https://github.com/GluuFederation/cluster-mgr/archive/4.3.zip
```


#####  On Ubuntu 18
```
apt-get update
apt install python3-pip python3-dev libssl-dev libffi-dev
apt install openjdk-8-jre-headless
apt install build-essential
pip3 install --upgrade pip
pip3 install --upgrade setuptools
pip3 install --upgrade psutil
pip3 install --upgrade python3-ldap
pip3 install https://github.com/GluuFederation/redislite/archive/master.zip
pip3 install https://github.com/GluuFederation/cluster-mgr/archive/4.3.zip
```

Jre is required for <!--license requirements and --> key rotation. It is not necessary if Java (up to 8) is already installed.

#### RedHat 7 and CentOS 7
First install Dependencies.

Install depenepel release:

`rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm`

`yum repolist`

Install curl and wget if missing:

`yum install -y wget curl`

!!! Note
    If your Gluu Server nodes will be Red Hat 7, please enable epel release each node (by repeating above steps) before attempting to install Gluu Server via CM. 

```
yum install gcc gcc-c++ make python3-devel openldap-devel python3-pip libffi-devel openssl-devel
yum install java-1.8.0-openjdk
pip3 install --upgrade pip
pip3 install --upgrade setuptools
pip3 install --upgrade psutil
pip3 install --upgrade python3-ldap
pip3 install https://github.com/GluuFederation/redislite/archive/master.zip
```

Install Cluster Manager from github
```
pip3 install https://github.com/GluuFederation/cluster-mgr/archive/4.3.zip
```

There may be a few innocuous warnings, but this is normal.

### RedHat 8 and CentOS 8

First install Dependencies.

Install depenepel release:

`rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`

`yum repolist`

Install curl and wget if missing:

`yum install -y wget curl`

!!! Note
    If your Gluu Server nodes will be Red Hat 8, please enable epel release each node (by repeating above steps) before attempting to install Gluu Server via CM. 

```
yum install gcc gcc-c++ make python3-devel openldap-devel python3-pip libffi-devel openssl-devel
yum install java-11-openjdk-headless
pip3 install --upgrade psutil
pip3 install --upgrade python3-ldap
pip3 install https://github.com/GluuFederation/redislite/archive/master.zip
```

Install Cluster Manager from github
```
pip3 install https://github.com/GluuFederation/cluster-mgr/archive/4.3.zip
```

<!--
### Add License Validator

Prepare the license validator by using the following commands:

```
mkdir -p $HOME/.clustermgr4/javalibs
wget -q https://ox.gluu.org/maven/org/gluu/oxlicense-validator/4.3.0.Final/oxlicense-validator-4.3.0.Final-jar-with-dependencies.jar -O $HOME/.clustermgr4/javalibs/oxlicense-validator.jar
```

!!! Note
    License files are not currently enforced, it's on the honor system! Please see the [Gluu Support License](https://github.com/GluuFederation/cluster-mgr/blob/master/LICENSE) to see if you're eligible to use Cluster Manager in production. In future versions, a license file may be required.
    oxlicense-validator works with Java version up to 8. **Please use Java 7 or 8.**

-->

!!! Warning
    All Cluster Manager commands need to be run as root.

### Add Key Generator

If automated key rotation is required, you'll need to download the keygen.jar. Prepare the OpenID Connect keys generator by using the following commands:

```
mkdir -p $HOME/.clustermgr4/javalibs
wget https://ox.gluu.org/maven/org/gluu/oxauth-client/4.3.0.Final/oxauth-client-4.3.0.Final-jar-with-dependencies.jar  -O $HOME/.clustermgr4/javalibs/keygen.jar
```

Automated key rotation can be configured inside the Cluster Manager UI.

### Stop/Start/Restart Cluster Manager

The following commands will stop/start/restart all the components of Cluster Manager:

 - `clustermgr4-cli stop`
 - `clustermgr4-cli start`
 - `clustermgr4-cli restart`


!!! Note
    All the Cluster Manager logs can be found in the `$HOME/.clustermgr4/logs` directory

### Create Credentials

When Cluster Manager is run for the first time, it will prompt for creation of an admin username and password. This creates an authentication config file at `$HOME/.clustermgr4/auth.ini`.


### Create New User

We recommend creating an additional "cluster" user, other than the one used to install and configure Cluster Manager.

This is a basic security precaution, due to the fact that the user SSHing into this server has unfettered access to every server connected to Cluster Manager. By using a separate user, which will still be able to connect to localhost:5000, an administrator can give an operator limited access to a server, while still being able to take full control of Cluster Manager.

```
ssh -L 5000:localhost:5000 cluster@<server>
```

### Log In

Navigate to the Cluster Manager web GUI on your local machine:

```
http://localhost:5000/
```

## Deploy Clusters
Next, move on to [deploy the Gluu cluster](../deploy/index.md).

## Uninstallation

To uninstall Cluster Manager, simply:

```
pip3 uninstall clustermgr4
```
