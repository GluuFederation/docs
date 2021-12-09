# Backup & Restore

## Overview
Cluster Manager stores all data under `~/.clustermgr4`. The process to backup and restore is described below. 

### Backup
To backup Cluster Manager, simply:

```
# clustermgr4-cli stop
# cd ~
# tar -zcf clustermgr4-backup.tgz .clustermgr4
```

!!! Attention
    Make sure to keep `clustermgr4-backup.tgz` in a safe palce. 

### Restore
To restore from backup, extract as follows:

```
# cd ~
# tar -zxf clustermgr4-backup.tgz
# clustermgr4-cli start
```
