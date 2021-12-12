# Using H2 storage in oxd

## Overview

`H2` is an open source and very fast database engine. It is written in java and has small footprint (around 2 MB) with low memory requirements. The storage used in oxd can be any relational database including `H2`. To use `H2` database as storage in oxd-server we need to follow below step:

- In `/opt/oxd-server/conf/oxd-server.yml` file of installed oxd-server set following parameters.

    ```
    storage: h2
    storage_configuration
      dbFileLocation: /opt/oxd-server/data/oxd_db  
    ```

By default, the oxd-server persists data inside H2 embedded database. On your disk, it should look like an `oxd_db.mv.db` file. In `dbFileLocation` parameter of `oxd-server.yml` the path is set where `oxd_db.mv.db` is generated.

## H2 username/password configuration

The username/password of H2 database can be configured in oxd by setting `username` and `password` parameters under `storage_configuration` in `/opt/oxd-server/conf/oxd-server.yml` file as shown below.

    ```
    storage: h2
    storage_configuration
      dbFileLocation: /opt/oxd-server/data/oxd_db 
      username: oxd_user
      password: secret
    ```

On starting oxd-server it creates H2 embedded database file if it already does not exist. When H2 username/password is already set in `oxd-server.yml` file, oxd sets the configured login details to H2 database (only during creation of embedded database file). In case, it is not set then oxd sets default login details to H2 database. The default login details are provided below:

    ```
    username: oxd
    password: oxd
    ```

## H2 tools to view/edit data in H2 DB


The oxd-server persists data inside H2 embedded database, it should look like an `oxd_db.mv.db` file on disk.
You can use any convenient database viewer to view/edit data inside the database. We recommend to use the browser-based viewer H2:

 - Download http://www.h2database.com/html/download.html
 - Run it (in "Platform-Independent zip" case it is as simple as hitting `h2.sh` or `h2.bat`)
 
 In the browser, you will see connection details; please specify details as in `oxd-conf.json` file.
 If all is filled correctly, upon "Test Connection" you should see a "Test successful" message like in the screenshot below:
 
 ![H2](../../img/faq_h2_connection_details.png)
 
 After hitting the "Connect" button, you will be able to view/modify data manually. Please be careful not to corrupt the data inside. Otherwise, oxd-server will not be able to operate in its normal mode.
 
## DBeaver to view/edit data in H2 DB

We can use Sql clients like `DBeaver` to view and edit data in database. The steps are:

1. Download, install and start [DBeaver](https://dbeaver.io/download/).

1. Click on `Database --> New Database Connection` option on top menu of `DBeaver`. This will open a popup window listing many DBs supported by `DBeaver`.


    ![dbeaver_connection](../../img/1_dbeaver_connection.png)


1. On appeared popup select `H2 Embedded` database and then click on `Next` button.


    ![dbeaver_select_h2](../../img/2_dbeaver_select_h2.png)


1. On next popup provide path of H2 embedded database (i.e. `oxd_db.mv.db` file) in `Database/Schema` textbox along with DB username/password. Then click on`Finish` button.


    ![dbeaver_test_connection](../../img/3_dbeaver_test_connection.png)


1. The newly created database connection will be shown on `Database Navigator`. To connect, right click on it and then click on connect option.


    ![dbeaver_db_connect](../../img/4_dbeaver_db_connect.png)


1. To view/edit data doulble click on tables under `PUBLIC --> Tables`. This will display the data in tables. The data can also be modified.


    ![dbeaver_data](../../img/5_dbeaver_data.png)
    
    
