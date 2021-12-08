# Using RDBMS storage in oxd

oxd can be configured with any RDBMS for saving data in own persistence. The RDMS configuration in oxd is same for all relational database.

## Relational database configuration in oxd

Follow below steps to use `Mysql` or `Postgres` or any other relational database as storage in oxd-server.

1. Copy the database driver jar file in `/opt/oxd-server/lib` directory of installed oxd-server. For exmaple to use `Mysql` database as storage in oxd add `mysql-connector-<version>.jar` in `/opt/oxd-server/lib`.

1. Set following fields in `/opt/oxd-server/conf/oxd-server.yml` file of installed oxd-server:

    - **storage** set this field `jdbc` to configure any relational database to oxd.

    ### storage_configuration Field Descriptions

    - **driver** set driver class name of the choosen database. Example `com.mysql.jdbc.Driver` is the driver class for `Mysql` database.

    - **jdbcUrl** set jdbc url of the database

    - **username** set database username

    - **password** set database password

    Mysql storage configuration sample:

        ```
        storage: jdbc
        storage_configuration
          driver: com.mysql.jdbc.Driver
          jdbcUrl: jdbc:mysql://<hostname>:3306/<database_name>
          username: oxd_username
          password: oxd_password
        ```

    Postgres storage configuration sample:

        ```
        storage: jdbc
        storage_configuration
          driver: org.postgresql.Driver
          jdbcUrl: jdbc:postgresql://<hostname>:5432/<database_name>
          username: oxd_username
          password: oxd_password
        ```
1. Restart `oxd-server`. After the server is restarted it will use configured database as storage.
