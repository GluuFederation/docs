# Using Redis storage in oxd

## Overview

[Redis](https://redis.io/) is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker. It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes with radius queries and streams. oxd can be configured to use `Redis` as storage to maintain a copy of client details registered in `OpenID Connect provider`. There are some easy steps to use `Redis` in standalone and cluster mode with oxd which will be covered in detail in this section.

## Redis in `Standalone` mode

When Redis is configured in `Standalone` mode, oxd stores client details in single Redis server. To configure Redis in `Standalone` mode we need to follow below steps:

1. Install [Gluu Server bundled with oxd](../../install/index.md).

1. Download and install [Redis](https://redis.io/topics/quickstart) on local server.  

1. Start Redis server using command:

    ```
    redis-server
    ```

1. In `/opt/oxd-server/conf/oxd-server.yml` (of Gluu Server chroot) set following `storage_configuration`.

    ```
    storage: redis
    storage_configuration:
        servers: "localhost:6379"
        redisProviderType: STANDALONE
    ```
    
1. Start oxd server and execute client registration command. This will store client information in Redis storage.
    
## Redis in `Cluster` mode

In `Cluster` mode oxd stores client details in multiple running Redis server. To configure Redis in `Cluster` mode we need to follow below steps:

1. Install [Gluu Server bundled with oxd](../../install/index.md).

1. Download and install [Redis](https://redis.io/topics/quickstart) on different virtual machines (VMs).  

1. Start Redis server on different VMs using below command:

    ```
    redis-server
    ```

1. In `/opt/oxd-server/conf/oxd-server.yml` (of Gluu Server chroot) set following `storage_configuration`.

    ```
    storage: redis
    storage_configuration:
        servers: "redis-host1-IP:6379,redis-host2-IP:6380,redis-host3-IP:6381,redis-host4-IP:6382"
        redisProviderType: CLUSTER
    ```
    
1. Start oxd server and execute client registration command. This will store client information in any one of the Redis server instance.
