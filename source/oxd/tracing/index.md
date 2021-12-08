# Tracing in oxd
## Overview
oxd uses OpenTracing  to profile and monitor the end-points requested on oxd-server. [OpenTracing](https://opentracing.io) is comprised of an API specification, frameworks and libraries that have implemented the specification, and documentation for the project. OpenTracing allows developers to add tracing instrumentation to their application code using APIs that do not lock them into any one particular product or vendor.

## Supported tracers in oxd
OpenTracing abstracts away the differences among numerous tracer implementations. This means that instrumentation would remain the same irrespective of the tracer system being used by the developer. OXD server supports 2 tracers which are [Jaeger](https://www.jaegertracing.io) or [Zipkin](https://zipkin.io) to record the Spans and publish them on UI. To enable tracing in oxd first we need to install tracer either `Jaeger` or `Zipkin`.

### Jaeger Installation
Jaeger can be easily installed locally or on server using Docker.
```
docker run -d -p 5775:5775/udp -p 16686:16686 jaegertracing/all-in-one:latest
```
Another way to install Jaeger is by downloading binaries from [here](https://www.jaegertracing.io/download) and running it.

### Zipkin Installation
Zipkin installation procedure is available at following [link](https://zipkin.io/pages/quickstart.html).

## Enable Tracing
To enable tracing in oxd-server follow below steps:

1. In `oxd-server.yml` set following properties to enable tracing.

      **enable_tracing** - set this property to "true" to enable tracing in oxd-server. To disable it set this property to "false".

      **tracer** - mention tracer used for publishing traces whether "jaeger" or "zipkin".

      **tracer_host** - mention tracer host.

      **tracer_port** - mention tracer port. For "jaeger" tracer default port is "5775" and for "zipkin" tracer default port is "9411".

1. Restart oxd-server. 

If you are using `Jaeger` tracer then tracing metrics can be monitored at `http://<jaeger-host>:16686`. For `Zipkin` tracer tracing metrics are available at `http://<zipkin-host>:9411`.

