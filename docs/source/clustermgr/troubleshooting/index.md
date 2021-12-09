## Default Components

Cluster Manager utilizes the following components:

1. **Gluu Server:** free open source software package for identity and access management 

1. **Redis-Server:** a value key-store known for it's high performance, installed outside the chroot on all servers. This is used a cache storage mechanism for tokens, session data and general caching of all the oxAuth and oxTrust/Identity services. The configuration file is located on the servers with Gluu at /etc/redis/redis.conf or /etc/redis.conf

1. **Stunnel:** used to protect communications between oxAuth, oxTrust and Redis. The configuration file is located at `/etc/stunnel/stunnel.conf` on **all** servers. It runs on port 16379 of all Gluu Server nodes and Cache Server . **For security Redis runs on localhost.** Stunnel faciliates SSL communication over the Internet for Redis, which doesn't come default with encrypted traffic

1. **NGINX:** (Optional) used to proxy communication between Gluu instances. The configuration file is located on the proxy server (if used) at `/etc/nginx/nginx.conf`. If you are using an external HTTP load-balancer, this is not a necessary component. Session stickiness will need to be handled for all paths with the exception of `/oxAuth`

## Logging for Errors and Troubleshooting

Cluster Manager displays logs in the GUI about what's happening on the system it's interacting with.

There is also additional logging information in the `$HOME/.clustermgr/logs` directory of the user who installed Cluster Manager.

If you have any other issues or concerns, please open a ticket at [support.gluu.org](https://support.gluu.org/).
