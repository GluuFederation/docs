# oxd-server Installation 

## System Requirements

oxd needs to be deployed on a server or VM with the following **minimum** requirements. 

|CPU Unit  |    RAM     |   Disk Space      | Processor Type |
|----------|------------|-------------------|----------------|
|       1  |    400MB     |   200MB            |  64 Bit        |

!!! Note
    **oxd requires Java version 1.8**
    
## Installation via Linux Packages

In version 4.2, oxd is offered as one of the several components of the Gluu Server CE. To include oxd in your instance, just ensure to hit Y when prompted at [installation](https://gluu.org/docs/ce/4.2/installation-guide) time.

Step 1: [Install](https://gluu.org/docs/ce/4.2/installation-guide) Gluu CE and ensure to hit Y when `Install Oxd?` is prompted while    running [setup scripts](https://gluu.org/docs/ce/4.2/installation-guide/setup_py/#setup-prompt).

Step 2: After the installation, [configure](../configuration/oxd-configuration/index.md) your oxd server.

Step 3: Restart oxd server using below command.

|Operation | Command|
|------ |------ |
|Restart oxd server | `systemctl restart oxd-server` |

After Gluu CE server installation is completed wait for about 10 minutes in total for the server to restart and finalize its configuration. After that period, to access Gluu CE server, sign in via a web browser to `hostname` provided during installation. For quick check whether oxd-server is alive use oxd `Health Check` endpoint `https://$HOSTNAME:8443/health-check`. This should return `{"status":"running"}` ensuring the successful installation of oxd.

## Manual installation

The oxd-server is a self-contained program. It can also be installed independently without Gluu CE server.

To run oxd-server:

1. download oxd distribution zip: https://ox.gluu.org/maven/org/gluu/oxd-server/4.2.1.Final/oxd-server-4.2.1.Final-distribution.zip

1. create a new directory ($OXD_SERVER_HOME) with appropriate name and unzip the downloaded `oxd-server-4.2.Final-distribution.zip` into it.

1. move to `$OXD_SERVER_HOME/conf` folder and edit `oxd-server.yml` file to make necessary configuration changes (like setting correct absolute path of `oxd-server.keystore` in `keyStorePath` property etc.)

1. now go to `$OXD_SERVER_HOME/bin` folder and start oxd-server using below command

  Windows:
```
oxd-start.bat 
```

  Linux:
```
sh oxd-start.sh
```

## Manual Build oxd-server Server

If you're a Java geek, you can build the oxd-server server using [Maven](http://maven.apache.org).

The code is available in [Github](https://github.com/GluuFederation/oxd).

The following command can be run inside the oxd folder to run the build:

```
  $ mvn clean package
```

## oxd-server Uninstall Procedure

### Ubuntu 18.04 (bionic)/Ubuntu 20.x (focal)/Debian 9 (stretch)/Debian 10 (buster)

```
systemctl stop oxd-server
sudo apt-get remove oxd-server
apt-get purge oxd-server
```

### CentOS 7/CentOS 8/RHEL 7/RHEL 8

```
systemctl stop oxd-server
yum remove oxd-server
rm -rf /opt/oxd-server.save
```

## Utility scripts

### View, delete entries inside the oxd-server database with lsox.sh or lsox.bat scripts

There are four types of parameters which can be used by lsox.sh/lsox.bat files:

 - `-l` - list all oxd_ids inside the oxd database
 - `-oxd_id <oxd_id>` - view JSON representation of the entity by oxd_id
 - `-d` - removes entity by oxd_id.
 - `-a` - authorization `access_token` (e.g. `lsox.sh -a gf4566-dlt456-emtr56-ddmg5kd`). It is optional if oxd is not running. If it is running then it is REQUIRED. This is true if h2 database is used for persistence which is default. The reason is that if oxd is running it locks h2 database file. The lock is exclusive, so script can't access the file while oxd is running. To handle it script needs authorization via `-a` parameter. Authorization means `access_token` obtained via `/get-client-token` API call (same as Authorization header value used for all API calls).

The script is located in `/opt/oxd-server/bin/lsox.sh`. If you hit the script without any parameters, it shows a hint:
```
yuriy@yuriyz:~/oxd-server-distribution/bin$ sh lsox.sh
BASEDIR=.
CONF=./../conf/oxd-server.yml
Missing required option: oxd_id
usage: utility-name
 -oxd_id,--oxd_id <arg>   oxd_id is unique identifier within oxd database
                          (returned by register_site and setup_client
                          commands)
 -l,--list                list all oxd_ids inside oxd database
 -d,--delete              deletes entry from oxd database                         

```

A typical call looks like this:
```
yuriy@yuriyz:~/oxd-server-4.0-SNAPSHOT-distribution/bin$ sh lsox.sh -oxd_id d8cc6dea-4d66-4995-b6e1-da3a33722f2e -a gf4566-dlt456-emtr56-ddmg5kd
BASEDIR=.
CONF=./../conf/oxd-server.yml

yuriy@yuriyz:~/oxd-server-4.0-SNAPSHOT-distribution/bin$JSON for oxd_id d8cc6dea-4d66-4995-b6e1-da3a33722f2e
{"scope":["openid","uma_protection","profile"],"contacts":[],"pat":null,"rpt":null,"oxd_id":"d8cc6dea-4d66-4995-b6e1-da3a33722f2e","op_configuration_endpoint":"https://ce-dev4.gluu.org/.well-known/openid-configuration","id_token":null,"access_token":null,"logout_redirect_uri":"https://client.example.com/cb","application_type":"web","redirect_uris":["https://client.example.com/cb"],"claims_redirect_uri":[],"response_types":["code"],"front_channel_logout_uri":[""],"client_id":"@!38D4.410C.1D43.8932!0001!37F2.B744!0008!B390.5F6D.2051.A8C0","client_secret":"4a72e386-97ed-49a0-a338-cd448e5020b3","client_registration_access_token":"920fdb64-9bd7-4b5f-8a8c-8689e29860b8","client_registration_client_uri":"https://ce-dev4.gluu.org/oxauth/restv1/register?client_id=@!38D4.410C.1D43.8932!0001!37F2.B744!0008!B390.5F6D.2051.A8C0","client_id_issued_at":1528879584000,"client_secret_expires_at":1528965984000,"client_name":null,"sector_identifier_uri":null,"client_jwks_uri":null,"token_endpoint_auth_signing_alg":null,"token_endpoint_auth_method":null,"is_setup_client":null,"setup_oxd_id":null,"setup_client_id":null,"ui_locales":["en"],"claims_locales":["en"],"acr_values":[""],"grant_types":["authorization_code","urn:ietf:params:oauth:grant-type:uma-ticket","client_credentials"],"user_id":null,"user_secret":null,"pat_expires_in":0,"pat_created_at":null,"pat_refresh_token":null,"uma_protected_resources":[],"rpt_token_type":null,"rpt_pct":null,"rpt_upgraded":null,"rpt_expires_at":null,"rpt_created_at":null,"oxd_rp_programming_language":"java"}
```

## Configuring Let's Encrypt CA trusted Certificates in Gluu CE server and oxd

The following is the easiest way to gather CA trusted certificates from Let's Encrypt with Certbot for your Gluu Server. Inside the Gluu Server chroot, run the following commands:

   ```
   apt-get update
   apt-get install software-properties-common
   add-apt-repository ppa:certbot/certbot
   apt-get update
   apt-get install python-certbot-apache 
   ```

Now that you have certbot installed, you can run the following:

   ```
   certbot --apache
   ```

This will prompt you with some additional questions and the automatically configure your Gluu Server's apache configuration to utilize the Let's Encrypt certs that it downloads to `/etc/letsencrypt/live/$HOSTNAME/cert.pem`, `/etc/letsencrypt/live/$HOSTNAME/privkey.pem` and `/etc/letsencrypt/live/$HOSTNAME/chain.pem`.

If you only want the certificates and for certbot to not handle configuring your web server configuration, run

   ```
   certbot --apache certonly
   ```

**Automating Renewal**

Run below command to automate certificate renewal.

   ```
   certbot renew
   ```

**Configuring Let's Encrypt Certificate to oxd packed with Gluu CE**

Follow below steps to use the Let's Encrypt Certificate configured to Gluu CE in oxd.

1. Change directory to `/etc/letsencrypt/live/$HOSTNAME/`. This directory should have the following certificate files: `cert.pem`, `chain.pem`, `fullchain.pem` and `privkey.pem`.

1. Concatenate all PEM files into one file `fullcert.pem` using command `cat /etc/letsencrypt/live/$HOSTNAME/*.pem > fullcert.pem`.

1. Then use OpenSSL to convert `fullcert.pem` into PKCS12 format. 

   ```
   openssl pkcs12 -export -out fullcert.pkcs12 -in fullcert.pem
   ```

1. It will prompt to enter `Export Password`. Type export password and press enter to create `fullcert.pkcs12`.

1. Now change directory to `/opt/oxd-server/conf` of oxd bundled with CE.

1. Set the path of `PKCS12 format` file (created in step 3) in `server.applicationConnectors.keyStorePath`and `server.adminConnectors.keyStorePath` fields of `/opt/oxd-server/conf/oxd-server.yml`. Also set `PKCS12` export password in `server.applicationConnectors.keyStorePassword`and `server.adminConnectors.keyStorePassword` fields. For example:

   ```
   # Connectors
   server:
     applicationConnectors:
       - type: https
         port: 8443
         keyStorePath:/etc/letsencrypt/live/www.ce-hostname.com/fullcert.pkcs12
         keyStorePassword: example
         validateCerts: false
     adminConnectors:
       - type: https
         port: 8444
         keyStorePath: /etc/letsencrypt/live/www.ce-hostname.com/fullcert.pkcs12
         keyStorePassword: example
         validateCerts: false
   ```

1. Restart oxd server. This will configure Let's Encrypt Certificate to oxd.
