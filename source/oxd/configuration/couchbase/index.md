# Using Couchbase storage in oxd

## Overview

The idea of using using `Couchbase` (or `ldap`) storage in oxd basically came so that oxd and Gluu Server can have common persistance. This is particularly useful when configuring high availability (HA) across multiple instances of the Gluu Server. 

oxd can also be configured to use any remote or local `Couchbase` (which is not used by Gluu server) as storage.

## Using Gluu server's `Couchbase` in oxd

To use Gluu server's `Couchbase` as storage in oxd-server we need to follow below steps:

1. [Login](https://www.gluu.org/docs/gluu-server/installation-guide/install-ubuntu/#start-the-server-and-log-in) to Gluu CE Server.

1. In /opt/oxd-server/conf/oxd-server.yml file of installed oxd-server set below parameters. Here, `gluu_server_configuration` storage tells oxd to use Gluu server persistance. In Gluu CE server the [persistance](https://www.gluu.org/docs/gluu-server/reference/persistence) configuration files are stored at location `/etc/gluu/conf`. Following 3 configuration files are used for couchbase connection: `/etc/gluu/conf/gluu.properties`, `/etc/gluu/conf/gluu-couchbase.properties` and `/etc/gluu/conf/salt`.

        ```
        storage: gluu_server_configuration
        storage_configuration:
          baseDn: o=gluu
          type: /etc/gluu/conf/gluu.properties
          connection: /etc/gluu/conf/gluu-couchbase.properties
          salt: /etc/gluu/conf/salt
        ```
  
1. Restart oxd server. Once oxd is successfully restarted then it will start using the `couchbase` storage configured in `oxd-server.yml`.

        ```
        systemctl restart oxd-server
        ```

### Fields details of configuration files

[Refer this](https://www.gluu.org/docs/gluu-server/reference/persistence) tutorials for more information on gluu persistance. You can also search [Gluu Server docs](https://www.gluu.org/docs/gluu-server) to learn more.

**gluu.properties fields**

oxd read `persistence.type` field from this file to find whether the storage is `ldap` or `couchbase`. The path of this file is set to `type` field in `oxd-server.yml`.

        ```
        persistence.type=couchbase
        ```

**gluu-couchbase.properties fields**

This file contains fields whose value is required for creating the connection with couchbase server. The path of this file is set to `connection` field in `oxd-server.yml`.

        ```
        servers: <hostname>

        connection.connect-timeout:10000
        connection.connection-max-wait-time: 20000
        connection.operation-tracing-enabled: false

        # If mutation tokens are enabled, they can be used for advanced durability requirements,
        # as well as optimized RYOW consistency.
        connection.mutation-tokens-enabled: false

        # Sets the pool size (number of threads to use) for all non blocking operations in the core and clients
        # (default value is the number of CPUs).
        # connection.computation-pool-size: 5

        # Default scan consistency. Possible values are: not_bounded, request_plus, statement_plus
        connection.scan-consistency: not_bounded

        auth.userName: <couchbase_server_user>
        auth.userPassword: <encoded_couchbase_server_pw>

        buckets: gluu, gluu_token, gluu_cache, gluu_user, gluu_site

        bucket.default: gluu
        bucket.gluu_user.mapping: people, groups, authorizations
        bucket.gluu_cache.mapping: cache
        bucket.gluu_site.mapping: cache-refresh
        bucket.gluu_token.mapping: tokens

        password.encryption.method: <encryption_method>

        ssl.trustStore.enable: <ssl_enabled>
        ssl.trustStore.file: <couchbaseTrustStoreFn>
        ssl.trustStore.pin: <encoded_couchbaseTrustStorePass>
        ssl.trustStore.format: pkcs12

        binaryAttributes=objectGUID
        certificateAttributes=userCertificate
        ```

**salt fields**

This file contain salt string to decode the encoded values from `gluu-couchbase.properties` file. The path of this file is set to `salt` field in `oxd-server.yml`

        ```
        encodeSalt=<salt-string>
        ```

## Using any local or remote `couchbase` server in oxd

To use any local or remote `couchbase` as storage in oxd-server we need to follow below steps:

1. Create the persistance files with connection properties as described [here](#fields-details-of-configuration-files).

1. In /opt/oxd-server/conf/oxd-server.yml file of installed oxd-server set `couchbase` as `storage`, `baseDn` as `o=gluu` and path of persistance configuration properties files as shown below. 

        ```
        storage: couchbase
        storage_configuration:
          baseDn: o=gluu
          type: /opt/oxd-server/conf/gluu.properties
          connection: /opt/oxd-server/conf/gluu-ldap.properties
          salt: /opt/oxd-server/conf/salt
        ```


1. Restart oxd server. Once oxd is successfully restarted then it will start using the `couchbase` storage configured in `oxd-server.yml`.

        ```
        systemctl restart oxd-server
        ```
