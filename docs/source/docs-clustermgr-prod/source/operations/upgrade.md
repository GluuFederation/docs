# Upgrades

## Auto-upgrades
Cluster Manager has a built-in upgrade feature which checks the GitHub repo for new versions twice a day. If a new version is available, CM will prompt you to upgrade. Simply accept the prompt to automatically upgrade your instance of Cluster Manager. 

## Manual Upgrades
To perform an upgrade manually, simply uninstall the current installation and install latest package. 

!!! Attention
    Although this process won't affect `~/.clustermgr4`, and is therefore safe, a [backup](./backup.md) is still recommended before proceeding. 

### Uninstall
To uninstall Cluster Manager:

```
clustermgr4-cli stop
pip3 uninstall clustermgr4
```

### Reinstall
To re-install latest package from Github.

```
pip3 install https://github.com/GluuFederation/cluster-mgr/archive/4.3.zip
clustermgr4-cli start
```
