# oxd 4.2 Documentation

!!! Attention
    Questions and feedback on oxd 4.2 can be directed to [Gluu support](https://support.gluu.org). View [known issues](https://github.com/GluuFederation/oxd/milestone/8). 


## Introduction
oxd exposes simple, static APIs web application developers can use to implement user authentication and authorization against an OAuth 2.0 authorization server like [Gluu](https://gluu.org/docs/ce/4.2/). 

## Architecture 
Starting with version 4.1, oxd is offered as one of the several components of the Gluu Server CE. To include oxd in CE instance, just ensure to hit Y when prompted at installation time. The oxd Linux package includes the `oxd-server` which is a simple REST application. `oxd-server` is designed to work over the web (via `https`), making it possible for many apps across many servers to leverage a central oxd service for OAuth 2.0 security.

oxd saves data in its own persistence (`RDMBS`, `redis`, etc.) and acts as RP for OP. It is possible that the admin goes to OP directly and change client data there. In that case, oxd will not know about it and can act on outdated data. To prevent this confusion user can configure client during registration so that oxd can automatically synchronize with the client data from OP whenever required. Check [Register site](./api/index.md#register-site) for more details.

![oxd-https-architecture](./img/oxd-https.jpg) 

## Tutorial

Follow one of our tutorials to learn how oxd works: 

- [Python](./tutorials/python/index.md)
- [Java](./tutorials/java/index.md) 
- [Spring](./tutorials/spring/index.md) 

## Get Started

To get started:

1. [Install](https://gluu.org/docs/ce/4.2/installation-guide) Gluu CE and ensure to hit Y when `Install Oxd?` is prompted while    running [setup scripts](https://gluu.org/docs/ce/4.2/installation-guide/setup_py/#setup-prompt).

1. [Configure](./configuration/oxd-configuration/index.md) the `oxd-server`           

1. Restart oxd server using below command.

    **Ubuntu 16.04 (xenial)**

    |Operation | Command|
    |------ |------ |
    |Restart oxd server | `/etc/init.d/oxd-server restart` |

    **Ubuntu 18.04 (bionic)/Debian 9 (stretch)/CentOS 7/RHEL 7**

    |Operation | Command|
    |------ |------ |
    |Restart oxd server | `systemctl restart oxd-server` |

1. After Gluu CE server installation is completed wait for about 10 minutes in total for the server to restart and finalize its configuration. After that period, to access Gluu CE server, sign in via a web browser to `hostname` provided during installation. For quick check whether oxd-server is alive use oxd `Health Check` endpoint `https://$HOSTNAME:8443/health-check`. This should return `{"status":"running"}` ensuring the successful installation of oxd.

Call the [oxd API](./api/index.md) to implement authentication and authorization against an external Authorization Server.
    
## API

oxd implements the [OpenID Connect](http://openid.net/specs/openid-connect-core-1_0.html) and [UMA 2.0](https://docs.kantarainitiative.org/uma/wg/oauth-uma-grant-2.0-05.html) profiles of OAuth 2.0.

!!! Attention
    By default oxd allows only `localhost` to access its apis. To make request from another server or VM add its ip-address to `bind_ip_addresses` array in `oxd-server.yml`. Check `bind_ip_addresses` in [configurations](./configuration/oxd-configuration/index.md#server-configuration-fields-descriptions) for details.
    
Before using oxd API you will need to obtain an access token to secure the interaction with `oxd-server`. You can follow the two steps below. 

 - [Register site](./api/index.md#register-site) (returns `client_id` and `client_secret`. Make sure the `uma_protection` scope is present in the request and `grant_type` has `client_credentials` value. If `add_client_credentials_grant_type_automatically_during_client_registration` field in `/opt/oxd-server/conf/oxd-server.yml` is set to `true` then `client_credentials` grant type will be automatically added to clients registered using oxd server.)
 - [Get client token](./api/index.md#get-client-token) (pass `client_id` and `client_secret` to obtain `access_token`. Note if `grant_type` does not have `client_credentials` value you will get error to check AS logs.)
 
Pass the obtained access token in `Authorization: Bearer <access_token>` header in all future calls to the `oxd-server`.

[oxd API References](./api/index.md) 

### OpenID Connect Authentication

OpenID Connect is a simple identity layer on top of OAuth 2.0. 

Technically OpenID Connect is not an authentication protocol--it enables a person to authorize the release of personal information from an "identity provider" to a separate application. In the process of authorizing the release of information, the person is authenticated (if no previous session exists).  

#### Authentication Flow
oxd supports the OpenID Connect [Hybrid Flow](http://openid.net/specs/openid-connect-core-1_0.html#HybridFlowAuth) and [Authorization Code Flow](http://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth) for authentication. 

Learn more about authentication flows in the [OpenID Connect spec](http://openid.net/specs/openid-connect-core-1_0.html). 

#### oxd Authorization Code Flow

You can think of the Authorization Code Flow as a three-step process: 

 - Redirect a person to the authorization URL and obtain a code [/get-authorization-url](./api/index.md#get-authorization-url)
 - Use the code to obtain tokens (access_token, id_token and refresh_token) [/get-tokens-id-access-by-code](./api/index.md#get-tokens-id-access-by-code)
 - Use the access token to obtain user claims [/get-user-info](./api/index.md#get-user-info)

### UMA 2 Authorization 

UMA 2 is a profile of OAuth 2.0 that defines RESTful, JSON-based, standardized flows and constructs for coordinating the protection of APIs and web resources. 

Using oxd, your application can delegate access management decisions, like who can access which resources, from what devices, to a central UMA Authorization Server (AS) like the [Gluu AS](https://gluu.org/docs/ce/admin-guide/uma/). 
 

## Native Libraries

oxd APIs are [swaggerized](https://github.com/GluuFederation/oxd/blob/version_4.2/oxd-server/src/main/resources/swagger.yaml)! Use the [Swagger Code Generator](https://swagger.io/tools/swagger-codegen/) to generate native libraries for your programming language of choice. 

For more information about generating native clients, [check our FAQ](https://gluu.org/docs/oxd/4.2/faq/#what-is-the-easiest-way-to-generate-native-library-for-oxd).

## Compatibility
oxd 4.2 has been tested against the following OAuth 2.0 Authorization Servers:

### OpenID Providers (OP)
- Gluu Server [4.2](https://gluu.org/docs/ce/4.2), [4.1](https://gluu.org/docs/ce/4.1), [3.1.6](https://gluu.org/docs/ce/3.1.6)


### UMA Authorization Servers (AS)
- Gluu Server [4.2](https://gluu.org/docs/ce/4.2), [4.1](https://gluu.org/docs/ce/4.1), [3.1.6](https://gluu.org/docs/ce/3.1.6)

## Source code
The oxd source code is [available on GitHub](https://github.com/GluuFederation/oxd). 

## License
oxd 4.2 is available under the AGPL open source license. 

## Support
Gluu offers support for oxd on the [Gluu Support Portal](https://support.gluu.org). In fact, we use oxd and a Gluu Server to provide single sign-on across our oxd portal and support app! 

For guaranteed response times, private support, and more, Gluu offers [VIP support](https://gluu.org/pricing). 
