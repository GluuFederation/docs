# Security Considerations

The `oxd-server` is a RESTful server that accepts `HTTPS` calls based on the `dropwizard` framework. 

## Limit access

`oxd-server` is a web server which handles all requests. An attacker can use such an open server for their own needs or attack it (e.g. DDoS). Therefore, it is recommended to protect it by putting `oxd-server` in a private network. As an alternative, it is possible to proxy requests via a web server (e.g. Apache HTTP Server or nginx) and limit access via it.
