# Logs

oxd logs are written to `/var/log/oxd-server/oxd-server.log` (location is set inside `/opt/oxd-server/conf/oxd-server.yml` file) in chroot of Gluu server. 

To configure the `oxd-server` logging configuration, edit the `/opt/oxd-server/conf/oxd-server.yml` file. 
For a complete list of available parameters, please refer to the `dropwizard` documentation [here](http://www.dropwizard.io/1.3.1/docs/manual/configuration.html#logging).
