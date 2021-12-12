# Using ldap storage in oxd

## Overview

The idea of using using `ldap` (or `Couchbase`) storage in oxd basically came so that oxd and Gluu Server can have common persistance. This is particularly useful when configuring high availability (HA) across multiple instances of the Gluu Server. 

oxd can also be configured to use any remote or local `ldap` (which is not used by Gluu server) as storage.

## Using Gluu server's `ldap` in oxd

To use Gluu server's `ldap` as storage in oxd-server we need to follow below steps:

1. [Login](https://www.gluu.org/docs/gluu-server/installation-guide/install-ubuntu/#start-the-server-and-log-in) to Gluu CE Server.

1. In /opt/oxd-server/conf/oxd-server.yml file of installed oxd-server set below parameters. Here, `gluu_server_configuration` storage tells oxd to use Gluu server persistance. In Gluu CE server the [persistance](https://www.gluu.org/docs/gluu-server/reference/persistence) configuration files are stored at location `/etc/gluu/conf`. Following 3 configuration files are used for ldap connection: `/etc/gluu/conf/gluu.properties`, `/etc/gluu/conf/gluu-ldap.properties` and `/etc/gluu/conf/salt`.

        ```
        storage: gluu_server_configuration
        storage_configuration:
            baseDn: o=gluu
            type: /etc/gluu/conf/gluu.properties
            connection: /etc/gluu/conf/gluu-ldap.properties
            salt: /etc/gluu/conf/salt
        ```
  
1. Restart oxd server. Once oxd is successfully restarted then it will start using the `ldap` storage configured in `oxd-server.yml`.

        ```
        systemctl restart oxd-server
        ```

### Fields details of configuration files

[Refer this](https://www.gluu.org/docs/gluu-server/reference/persistence) tutorials for more information on gluu persistance. You can also search [Gluu Server docs](https://www.gluu.org/docs/gluu-server) to learn more.

**gluu.properties fields**

oxd read `persistence.type` field from this file to find whether the storage is `ldap` or `couchbase`. The path of this file is set to `type` field in `oxd-server.yml`.

        ```
        persistence.type=<ldap or couchbase>
        ```

**gluu-ldap.properties fields**

This file contains fields whose value is required for creating the connection with ldap server. The path of this file is set to `connection` field in `oxd-server.yml`.

        ```
        bindDN: <ldap_binddn>
        bindPassword: <encoded_ ldap_pw>
        servers: <ldap_hostname>:<ldaps_port>

        useSSL: true
        ssl.trustStoreFile: <ldapTrustStoreFn>
        ssl.trustStorePin: <encoded_ldapTrustStorePass>
        ssl.trustStoreFormat: pkcs12

        maxconnections: 10

        # Max wait 20 seconds
        connection.max-wait-time-millis=20000

        # Force to recreate polled connections after 30 minutes
        connection.max-age-time-millis=1800000

        # Invoke connection health check after checkout it from pool
        connection-pool.health-check.on-checkout.enabled=false

        # Interval to check connections in pool. Value is 3 minutes. Not used when onnection-pool.health-check.on-checkout.enabled=true
        connection-pool.health-check.interval-millis=180000

        # How long to wait during connection health check. Max wait 20 seconds
        connection-pool.health-check.max-response-time-millis=20000

        binaryAttributes=objectGUID
        certificateAttributes=userCertificate
        ```

**salt fields**

This file contain salt string to decode the encoded values from `gluu-ldap.properties` file. The path of this file is set to `salt` field in `oxd-server.yml`

        ```
        encodeSalt=<salt-string>
        ```

## Using any local or remote `ldap` server in oxd

To use any local or remote `ldap` as storage in oxd-server we need to follow below steps:

1. Create the persistance files with connection properties as described [here](#fields-details-of-configuration-files).

1. In /opt/oxd-server/conf/oxd-server.yml file of installed oxd-server set `ldap` as `storage`, `baseDn` as `o=gluu` and path of persistance configuration properties files as shown below. 

        ```
        storage: ldap
        storage_configuration:
            baseDn: o=gluu
            type: /opt/oxd-server/conf/gluu.properties
            connection: /opt/oxd-server/conf/gluu-ldap.properties
            salt: /opt/oxd-server/conf/salt
        ```


1. Restart oxd server. Once oxd is successfully restarted then it will start using the `ldap` storage configured in `oxd-server.yml`.

        ```
        systemctl restart oxd-server
        ```
