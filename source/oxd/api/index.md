# oxd APIs
## Overview
oxd offers an easy API for [OAuth 2.0](https://tools.ietf.org/html/rfc6749), [OpenID Connect](http://openid.net/specs/openid-connect-core-1_0.html), and [UMA 2.0](https://docs.kantarainitiative.org/uma/wg/oauth-uma-grant-2.0-05.html). 

- The [oxd OAuth APIs](#oauth-20-apis) can be used to send a user to an OAuth 2.0 Authorization Server (AS) for authorization. 

- The [oxd OpenID Connect APIs](#openid-connect-apis) can be used to send a user to an OpenID Connect Provider (OP) for authentication and to gather identity information ("claims") about the user 

- The oxd UMA APIs can be used to send a user to an UMA Authorization Server (AS) for access policy enforcement, and are separated into two sections: [UMA 2.0 Resource Server APIs](#uma-2-resource-server-apis) and [UMA 2.0 Client APIs](#uma-2-client-apis). 

## OAuth 2.0 APIs 

### Register Site 
    
[API Link](#operations-developers-register-site)

The client must first register itself with the `oxd-server`. 

If the registration is successful, oxd will dynamically register an OpenID Connect client and return an identifier for the application which must be presented in subsequent API calls. This is the `oxd_id` (not to be confused with the OpenID Connect Client ID).

`register_site` has many optional parameters. 

The only required parameter is the `redirect_uris` which is list of Redirection URIs used by the Client. The first URL in this list is where the user will be redirected after successful authorization at the OpenID Connect Provider (OP).

The `op_host` parameter is optional, but it must be specified in either the [default configuration file](../configuration/#oxd-confjson) or the API call. This is the URL at the OP where users will be sent for authentication. 

oxd saves data in its own persistence (`RDBMS`, `redis`, etc.) and acts as RP for OP. It is possible that the admin goes to OP directly and change client data there. In that case, oxd will not know about it and can act on outdated data. To prevent this confusion user can set `sync_client_from_op` and `sync_client_period_in_seconds` parameters during client registration so that oxd can synchronize with the client data from OP whenever required.

- The `sync_client_from_op` parameter should be set to `true` to enable the synchronization of the client from OP to oxd persistence. The default value is `false` which means synchronization is disabled. 

- In `sync_client_period_in_seconds` users can specify the period after which the oxd can sync again with client data at OP. For example, if for a client `sync_client_period_in_seconds` is set to `60` then it means oxd can sync the client again only after 60 seconds from last sync time. The default value is `86400` seconds.


!!! Note
    `op_host` must point to a valid OpenID Connect Provider (OP) that supports [Client Registration](http://openid.net/specs/openid-connect-registration-1_0.html#ClientRegistration).    

### Update Site

[API Link](#operations-developers-update-site)

`Update site` modifies the client information on an OpenID Connect Provider (OP). The only required parameter for this operation is client's `oxd_id` (which is generated during site registration). The other parameters are the same as the `Register site` parameters, except that `op_host` cannot be updated using this operation.

The value of `sync_client_from_op` and `sync_client_period_in_seconds` parameters can be modified using this command to enabled/disable synchronization of RP with client data at OP.

### Remove Site

[API Link](#operations-developers-remove-site)

### Get Client Token

[API Link](#operations-developers-get-client-token)

Obtain an bearer access token from the oxd server.
[The OAuth 2.0 Authorization Framework: Bearer Token Usage](https://tools.ietf.org/html/rfc6750).

The token should be used to access a protected resources.

Gluu-gateway supports only [Authorization Request Header Field](https://tools.ietf.org/html/rfc6750#section-2.1).

Oxd server is also protected by [Authorization Request Header Field](https://tools.ietf.org/html/rfc6750#section-2.1) and the token must be used in all subsequent oxd queries.

The required parameters for `/get-client-token` are `op_host`, `client_id` and `client_secret`.

**Using Different AS for `access_token` validation**

oxd can also be configured to use a different Authorization Server (AS) for `access_token` validation other than the one processing API call. Follow below steps to configure another AS to protect APIs calls:

1. Register client (say AS1) in oxd using `/register-site`.

1. Register the AS (say AS2, to protect APIs) using `/register-site` end-point.

1. Generate access token using `/get-client-token` by passing `op_host`, `client_id` and `client_secret` of the registered AS2.

1. In subsequent apis call pass `AuthorizationOxdId: <oxd_id>` HTTP header along with `Authorization: <access_token>` HTTP header. In `AuthorizationOxdId` set `oxd_id` of Authorization Server (AS2) for protecting APIs.

`protect_commands_with_oxd_id` array in `/opt/oxd-server/conf/oxd-server.yml` is to limit oxd_id's that can be send via `AuthorizationOxdId` header. However if this field is missed from configuration then any oxd_id (i.e. AS registered to oxd) can be used to validate access token.

### Get Access Token by Refresh Token

[API Link](#operations-developers-get-access-token-by-refresh-token)

A Refresh Token can be used to obtain a renewed Access Token. 

### Introspect Access Token

[API Link](#operations-developers-introspect-access-token)

This operation introspect if the client OAuth2 bearer access token obtained from the [previous step](#get-client-token) is active or not.

### Get User Info

[API Link](#operations-developers-get-user-info)

Use the access token from the step above to retrieve a JSON object with the user claims.

### Get JSON Web Key Set

[API Link](#operations-developers-get-json-web-key-set)

This operation is used to get the JSON Web Key Set (JWKS) from OP host. The JWKS is a set of keys containing the public keys that should be used to verify any JSON Web Token (JWT) issued by the authorization server.

### Get OP Discovery Configuration

[API Link](#operations-developers-get-discovery)

This operation fetches OP Discovery Configuration from OP host.

### Get RP JSON Web Key Set

[API Link](#operations-developers-get-rp-jwks)

This operation is used to get the JSON Web Key Set (JWKS) of the Relying Party (RP). The JWKS is a set of keys containing the public keys that should be used by OP host to verify any JSON Web Token (JWT) issued by the RP.

### Get Request Object Uri

[API Link](#operations-developers-get-request-object-uri)

This operation is used to generate [request_uri](https://openid.net/specs/openid-connect-core-1_0.html#RequestUriParameter). The `request_uri` Authorization Request parameter enables OpenID Connect requests to be passed by reference, rather than by value.

## OpenID Connect APIs

### Get Authorization URL

[API Link](#operations-developers-get-authorization-url)

Returns the URL at the OpenID Connect Provider (OP) to which your application must redirect the person to authorize the release of personal data (and perhaps be authenticated in the process if no previous session exists).

The response from the OpenID Connect Provider (OP) will include the code and state values, which should be used to subsequently obtain tokens.

After redirecting to the above URL, the OpenID Connect Provider (OP) will return a response to the URL your application registered as the redirect URI (parse out the code and state). It will look like this:

```language-http
HTTP/1.1 302 Found
Location: https://client.example.org/cb?code=SplxlOBeZQQYbYS6WxSbIA&state=af0ifjsldkj&scopes=openid%20profile
```

The only required parameter for `/get-authorization-url` is `oxd_id`. `redirect_uri` is a non-mandatory parameter in this command, if not provided then after authorization it will redirect to the first URL from `redirect_uris` list provided during client registration.

The custom parameters (in key and value pair) can be passed to OpenID Connect Provider (OP) using `custom_parameters` parameter. The standard parameters (in key and value pair) can be passed to OP using `params` parameter.

### Get Tokens (ID & Access) by Code

[API Link](#operations-developers-get-tokens-by-code)

Use the code and state obtained in the previous step to call this API to retrieve tokens.

### Get Logout URI

The `get_logout_uri` command uses front-channel logout. A page is returned with iFrames, each of which contains the logout URL of the applications that have a session in that browser. 

These iFrames should be loaded automatically, enabling each application to get a notification of logout, and to hopefully clean up any cookies in the person's browser. If the person blocks [third-party cookies](https://en.wikipedia.org/wiki/HTTP_cookie#Third-party_cookie) in their browser, front-channel logout will not work.

## Initiating Login from a Third Party

In some cases, the login flow is initiated by an OpenID Provider or another party, rather than the Relying Party. In this case, the initiator redirects to the RP at its login initiation endpoint, which requests that the RP send an Authentication Request to a specified OP. 

The login initiation endpoint `https://<oxd_host>:<oxd_port>/initiate-third-party-login` is registered using `initiate_login_uri` [Registration](#register-site) parameter.

```
POST /register-site

{
	"redirect_uris": ["https://client.example.org/cb"],
	"initiate_login_uri": "https://oxd.gluu.org:8443/initiate-third-party-login",
	.
	.
	.
}
```

Successful response contains `initiate_login_uri` generated by oxd for the registered client.

```
HTTP 1.1 200 OK

{
	"oxd_id": "36f0b297-9763-4ea7-95ce-1eb496931a04",
  	"client_id": "22fa50d5-2a3a-4b87-ba6f-a6d3e39bc9d9",
  	"client_name": "test1",
  	...
  	"initiate_login_uri ": "https://oxd.gluu.org:8443/initiate-third-party-login/36f0b297-9763-4ea7-95ce-1eb496931a04"
}
```

The party initiating the login request does so by redirecting to the login initiation endpoint at the RP, passing the following query parameters. The authorization url returned from the endpoint can be used for login.

**Parameters**

- `iss` REQUIRED. Issuer Identifier for the OP that the RP is to send the Authentication Request to. Its value MUST be a URL using the https scheme.
- `login_hint` OPTIONAL. Hint to the Authorization Server about the login identifier the End-User might use to log in. If the client receives a value for this string-valued parameter, it MUST include it in the Authentication Request as the login_hint parameter value.
- `target_link_uri` OPTIONAL. URL that the RP is requested to redirect to after authentication. RPs MUST verify the value of the target_link_uri to prevent being used as an open redirector to external sites.



## UMA 2 Resource Server APIs

Your client, acting as an [OAuth2 Resource Server](https://tools.ietf.org/html/rfc6749#section-1.1), MUST:

- Register a protected resource (with the `uma_rs_protect` command)
- Intercept the HTTP call (before the actual REST resource call) and check the `uma_rs_check_access` command response to determine whether the requester is allowed to proceed or should be rejected:
    - Allow access: if the response from `uma_rs_check_access` is `allowed` or `not_protected`, an error is returned.
    - If `uma_rs_check_access` returns `denied` then return back HTTP response.
- client must have the `client_credentials` grant type. It's required for correct PAT obtaining.
        
The `uma_rs_check_access` operation checks access using the "or" rule when evaluating scopes.

For example, a resource like `/photo` protected with scopes `read`, `all` (by `uma_rs_protect` command) assumes that if either `read` or `all` is present, access is granted.

If the "and" rule is preferred, it can be achieved by adding an additional scope, for example:

`Resource1` scopes: `read`, `write` (follows the "or" rule).

`Resource2` scopes: `read_write` (and associate `read` *and* `write` policies with the `read_write` scope)

If access is not granted, an unauthorized HTTP code and registered ticket are returned (ticket is re-newed if `need_info` is returned on `/uma-rp-get-rpt`). For example: 

```language-http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: UMA realm="example",
      as_uri="https://as.example.com",
      ticket="016f84e8-f9b9-11e0-bd6f-0021cc6004de"
```

The `uma_rs_check_access` returns `denied` then returns back an HTTP response:

```language-http
HTTP/1.1 403 Forbidden
Warning: 199 - "UMA Authorization Server Unreachable"
```

### UMA RS Protect Resources

[API Link](#operations-developers-uma-rs-protect)

It's important to have a single HTTP method mentioned only one time within a given path in JSON, otherwise the operation will fail.

Request:

```
POST /uma-rs-protect

{
        "oxd_id":"6F9619FF-8B86-D011-B42D-00CF4FC964FF",   <- REQUIRED
        "overwrite":false,                                 <- OPTIONAL oxd_id registers resource, if send uma_rs_protect second time with same oxd_id and overwrite=false then it will fail with error uma_protection_exists. overwrite=true means remove existing UMA Resource and register new based on JSON Document.
        "resources":[        <-  REQUIRED
            {
                "path":"/photo",
                "conditions":[
                    {
                        "httpMethods":["GET"],
                        "scopes":[
                            "http://photoz.example.com/dev/actions/view"
                        ]
                    },
                    {
                        "httpMethods":["PUT", "POST"],
                        "scopes":[
                            "http://photoz.example.com/dev/actions/all",
                            "http://photoz.example.com/dev/actions/add"
                        ],
                        "ticketScopes":[
                            "http://photoz.example.com/dev/actions/add"
                        ]
                    }
                ]
            },
            {
                "path":"/document",
                "conditions":[
                    {
                        "httpMethods":["GET"],
                        "scopes":[
                            "http://photoz.example.com/dev/actions/view"
                        ]
                    }
                ]
            }
        ]
}
```
The creation (`iat`) and expiration (`exp`) timestamp (in seconds) of each resource can be also specified in JSON.

```
POST /uma-rs-protect

{
        "oxd_id":"6F9619FF-8B86-D011-B42D-00CF4FC964FF",   <- REQUIRED
        "overwrite":false,                                 <- OPTIONAL oxd_id registers resource, if send uma_rs_protect second time with same oxd_id and overwrite=false then it will fail with error uma_protection_exists. overwrite=true means remove existing UMA Resource and register new based on JSON Document.
        "resources":[        <-  REQUIRED
            {
                "path":"/photo",
                "conditions":[
                    {
                        "httpMethods":["GET"],
                        "scopes":[
                            "http://photoz.example.com/dev/actions/view"
                        ]
                    },
                    {
                        "httpMethods":["PUT", "POST"],
                        "scopes":[
                            "http://photoz.example.com/dev/actions/all",
                            "http://photoz.example.com/dev/actions/add"
                        ],
                        "ticketScopes":[
                            "http://photoz.example.com/dev/actions/add"
                        ]
                    }
                ],
		"iat": 1582890956,                         <- OPTIONAL
		"exp": 2079299799                          <- OPTIONAL
            },
            {
                "path":"/document",
                "conditions":[
                    {
                        "httpMethods":["GET"],
                        "scopes":[
                            "http://photoz.example.com/dev/actions/view"
                        ]
                    }
                ]
            }
        ]
}
```

Request with `scope_expression`. `scope_expression` is a Gluu-invented extension that allows a JsonLogic expression instead of a single list of scopes. Read more about `scope_expression` [here](https://gluu.org/docs/ce/admin-guide/uma).
```language-json
POST /uma-rs-protect

{
    "oxd_id": "6F9619FF-8B86-D011-B42D-00CF4FC964FF",  <- REQUIRED
    "overwrite":false,                                 <- OPTIONAL oxd_id registers resource, if send uma_rs_protect second time with same oxd_id and overwrite=false then it will fail with error uma_protection_exists. overwrite=true means remove existing UMA Resource and register new based on JSON Document.
    "resources": [                                     <- REQUIRED
      {
        "path": "/photo",
        "conditions": [
          {
            "httpMethods": [
              "GET"
            ],
            "scope_expression": {
              "rule": {
                "and": [
                  {
                    "or": [
                      {
                        "var": 0
                      },
                      {
                        "var": 1
                      }
                    ]
                  },
                  {
                    "var": 2
                  }
                ]
              },
              "data": [
                "http://photoz.example.com/dev/actions/all",
                "http://photoz.example.com/dev/actions/add",
                "http://photoz.example.com/dev/actions/internalClient"
              ]
            }
          },
          {
            "httpMethods": [
              "PUT",
              "POST"
            ],
            "scope_expression": {
              "rule": {
                "and": [
                  {
                    "or": [
                      {
                        "var": 0
                      },
                      {
                        "var": 1
                      }
                    ]
                  },
                  {
                    "var": 2
                  }
                ]
              },
              "data": [
                "http://photoz.example.com/dev/actions/all",
                "http://photoz.example.com/dev/actions/add",
                "http://photoz.example.com/dev/actions/internalClient"
              ]
            }
          }
        ]
      }
    ]
}
```


### UMA RS Modify Resource

[API Link](#operations-developers-uma-rs-modify)

To modify any particular resource from resource set `/uma-rs-modify` should be used.

Request:

```
POST /uma-rs-modify

{
        "oxd_id": "ffe704de-3e71-4231-9c80-94a69d6c6218",   <- REQUIRED
        "path": "/photo",   <- REQUIRED
	"http_method": "POST",   <- REQUIRED
	"scopes":[
                     "http://photoz.example.com/prod/live/all",
                     "http://photoz.example.com/prod/live/add"
                 ]  					      <- REQUIRED if `scope_expression` is not present
       
}
```

Request with `scope_expression`.

```
POST /uma-rs-modify

{
        "oxd_id": "ffe704de-3e71-4231-9c80-94a69d6c6218",   <- REQUIRED
        "path": "/photo",   <- REQUIRED
	"http_method": "POST",   <- REQUIRED
	"scope_expression": "{'rule':{'or':[{'var':0},{'var':1}]},'data':['http://photoz.example.com/prod/live/a1','http://photoz.example.com/prod/live/a2']}" <- REQUIRED if `scopes` is not present
       
}
```

### UMA RS Check Access

[API Link](#operations-developers-uma-rs-check-access)

Operation to check whether access can be granted or not. 

In `scopes` parameter user can explicitly specify the scope(s) to check.

Request:

```language-json
POST /uma-rs-check-access
{
    "oxd_id":"6F9619FF-8B86-D011-B42D-00CF4FC964FF",
    "rpt":"eyJ0 ... NiJ9.eyJ1c ... I6IjIifX0.DeWt4Qu ... ZXso",    <-- REQUIRED - RPT or blank value if not sent by RP
    "path":"<path of resource>",                                   <-- REQUIRED - Resource Path (e.g. http://rs.com/phones), /phones should be passed
    "http_method":"<http method of RP request>",                    <-- REQUIRED - HTTP method of RP request (GET, POST, PUT, DELETE)
    "scopes": ["http://photoz.example.com/prod/live/all", "http://photoz.example.com/prod/live/add"]
}
```

Sample of RP Request:
```language-http
GET /users/alice/album/photo HTTP/1.1
Authorization: Bearer vF9dft4qmT
Host: photoz.example.com
```

Parameters:
```language-yaml
rpt: 'vF9dft4qmT'
path: /users/alice/album/photo
http_method: GET
```

Access Granted Response:

```language-json
HTTP/1.1 200 OK
{
    "access":"granted"
}
```

Access Denied with Ticket Response:

```language-json
HTTP/1.1 200 OK
{
    "access":"denied"
    "www-authenticate_header":"UMA realm=\"example\",
                               as_uri=\"https://as.example.com\",
                               error=\"insufficient_scope\",
                               ticket=\"016f84e8-f9b9-11e0-bd6f-0021cc6004de\"",
    "ticket":"016f84e8-f9b9-11e0-bd6f-0021cc6004de"
}
```

Access Denied without Ticket Response:

```language-json
HTTP/1.1 200 OK
{
    "access":"denied"
}
```

Resource is not Protected Error Response:
```language-json
HTTP/1.1 400 Bad request
{
    "error":"invalid_request",
    "error_description":"Resource is not protected. Please protect your resource first with uma_rs_protect command."
}
```

### UMA Introspect RPT

[API Link](#operations-developers-introspect-rpt)

Example of successful response:

```language-json
HTTP/1.1 200 OK
{
        "active":true,
        "exp":1256953732,
        "iat":1256912345,
        "permissions":[  
            {  
                "resource_id":"112210f47de98100",
                "resource_scopes":[  
                    "view",
                    "http://photoz.example.com/dev/actions/print"
                ],
                "exp":1256953732
            }
        ]
}
```

## UMA 2 Relying Party APIs 

### UMA RP - Get RPT

If your application is calling UMA 2 protected resources, use these APIs to obtain an RPT token.

[API Link](#operations-developers-uma-rp-get-rpt)

Successful Response:

```language-json
HTTP 1.1 200 OK
{
     "access_token":"SSJHBSUSSJHVhjsgvhsgvshgsv",
     "token_type":"Bearer",
     "pct":"c2F2ZWRjb25zZW50",
     "upgraded":true
}
```

If Need Info Error reponse is returned, then old ticket is invalidated and new ticket is returned inside Need Info Reponse. Make sure always new ticket is used.

Needs Info Error Response:
```language-json
HTTP 1.1 403 Forbidden
{
  "error": "need_info",
  "ticket": "38569d82-6e4a-4287-aac8-1d9ea2b8c439",
  "required_claims": [
    {
      "issuer": [
        "https://gluu.local.org"
      ],
      "name": "country",
      "claim_token_format": [
        "http://openid.net/specs/openid-connect-core-1_0.html#IDToken"
      ],
      "claim_type": "string",
      "friendly_name": "country"
    },
    {
      "issuer": [
        "https://gluu.local.org"
      ],
      "name": "city",
      "claim_token_format": [
        "http://openid.net/specs/openid-connect-core-1_0.html#IDToken"
      ],
      "claim_type": "string",
      "friendly_name": "city"
    }
  ],
  "redirect_user": "https://gluu.local.org/oxauth/restv1/uma/gather_claims?customUserParam2=value2&customUserParam1=value1&client_id=@!B28D.DF29.C16D.8E6F!0001!5489.C322!0008!7946.30C2.ACFC.73D8&ticket=38569d82-6e4a-4287-aac8-1d9ea2b8c439"
}
```

### UMA RP - Get Claims-Gathering URL

[API Link](#operations-developers-uma-rp-get-claims-gathering-url)

`ticket` parameter for this command MUST be newest, in 90% cases it is from `need_info` error.

After being redirected to the Claims Gathering URL, the user goes through the claims gathering flow. If successful, the user is redirected back to `claims_redirect_uri` with a new ticket which should be provided with the next `uma_rp_get_rpt` call.

Example of Response:

```
https://client.example.com/cb?ticket=e8e7bc0b-75de-4939-a9b1-2425dab3d5ec
```


## API References

oxd has defined swagger specification [here](https://github.com/GluuFederation/oxd/blob/version_4.2.0/oxd-server/src/main/resources/swagger.yaml).

It is possible to generated native library in your favorite language by [Swagger Code Generator](https://swagger.io/tools/swagger-codegen/)

Check our FAQ about easiest way to generate native client [here](../faq/index.md#what-is-the-easiest-way-to-generate-native-library-for-oxd).


<link rel="stylesheet" type="text/css" href="../swagger/swagger-ui.css">

<div id="swagger-ui"></div>

<script src="../swagger/swagger-ui-bundle.js"></script>
<script src="../swagger/swagger-ui-standalone-preset.js"></script>

<script>

const DisableTryItOutPlugin = function() {
  return {
    statePlugins: {
      spec: {
        wrapSelectors: {
          allowTryItOutFor: () => () => false
        }
      }
    }
  }
}

function goToHash(){
	if(window.location.hash) {
	    //$(document).scrollTop( $('a[href$="'+window.location.hash+'"]').offset().top ); 	   
	}
}

function waitAndGoToHash() {
	window.setTimeout(goToHash,3000);
}

window.onload = function() {
  const ui = SwaggerUIBundle({
    url: "https://raw.githubusercontent.com/GluuFederation/oxd/version_4.2.0/oxd-server/src/main/resources/swagger.yaml",
    dom_id: '#swagger-ui',
    docExpansion: 'full',
    deepLinking: true,
    defaultModelRendering: 'model',
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
        DisableTryItOutPlugin
    ],
    onComplete: waitAndGoToHash
  })

  window.ui = ui
}

$(document).ready(function () {
    $('html, body').animate({
        scrollTop: $(window.location.hash).offset().top
    }, 'slow');
});
</script>



## References

- [UMA 2.0 Grant for OAuth 2.0 Authorization Specification](https://docs.kantarainitiative.org/uma/ed/oauth-uma-grant-2.0-06.html)
- [Federated Authorization for UMA 2.0 Specification](https://docs.kantarainitiative.org/uma/ed/oauth-uma-federated-authz-2.0-07.html)
- [Java Resteasy HTTP interceptor of uma-rs](https://github.com/GluuFederation/uma-rs/blob/master/uma-rs-resteasy/src/main/java/org/xdi/oxd/rs/protect/resteasy/RptPreProcessInterceptor.java)
