## Overview

We have included auto-migration functionality to easily transfer existing data files to the latest version of oxd. `oxd-server` now uses configurable data storage (`RDBMS`, `redis`, etc.) instead of JSON files.

## Legacy Compatibility
Before moving forward with an upgrade to oxd 4.2, review the following legacy compatibility notes:

- UMA 2.0: Supported in oxd 4.2 (since 3.1.4) and Gluu Server 4.2 (since 3.1.4)
- UMA 1.0.1: **Not** supported in oxd 4.2 (since 3.1.4) or Gluu Server 4.2 (since 3.1.4)
- OpenID Connect: Supported in all versions of oxd and Gluu Server         

## OpenID Connect Data Migration
Follow these simple steps to migrate your JSON files:

- Open `oxd-server.yml` 
- Modify `migration_source_folder_path` to point to the folder or directory that contains the JSON files (this step can be skipped if you use oxd 3.1.x or later)

    !!! Note 
        If you are using Windows OS, don't forget to include the escape path separator (e.g. `C:\\OXD_OLD\\oxd-server\\conf`)

- Restart `oxd-server` to import the files
- Data migration will only happen once and will not initiate for subsequent oxd-server restarts  

## UMA Data Migration
Auto-migration between UMA `1.0.1` and UMA `2` is not supported because of major changes between the specifications. To view the UMA `2` specifications follow this [link](https://docs.kantarainitiative.org/uma/ed/uma-core-2.0-01.html#without-rpt).

## Upgrade Script (oxd server upgrade 3.1.x -> 4.x)

Upgrades oxd server from 3.1.x to 4.x version. Download the upgrade script:

```
# wget https://raw.githubusercontent.com/GluuFederation/oxd/version_4.1/upgrade/oxd_updater.py
```

Run the upgrade script:

```
# python oxd_updater.py
```

The `oxd_updater.py` script:    

1. Adds Gluu repository (`repo.gluu.org`)       

1. Removes old oxd server (if applicable)       

1. Installs latest oxd server     

1. Moves json data to `/opt/oxd-server/json_data_backup` and sets `migration_source_folder_path: /opt/oxd-server/json_data_backup` in `oxd-server.yml` so that oxd migrates to h2 database       

1. Merges `oxd-conf.json`, `oxd-default-site-config.json`, and `log4j.xml` into the new, single configuration file: `oxd-server.yml`      

!!! Note  
    Do not install the latest version of oxd when using `oxd_updater.py` -- the script will perform everything needed. 
