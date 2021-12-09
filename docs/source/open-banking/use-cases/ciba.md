# OpenID Connect Client Initiated Backchannel Authentication Flow (CIBA)

OpenID Connect Client Initiated Backchannel Authentication Flow is an authentication flow like OpenID Connect. However, unlike OpenID Connect, there is direct Relying Party to OpenID Provider communication without redirects through the user's browser.

[OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html) allows Relying Parties (RP) to authenticate their users for clients of all types, including browser-based JavaScript and native mobile apps, to launch sign-in flows and receive verifiable assertions about the identity of signed-in users.

In all of these flows initiated by the RP, the end-user interaction from the consumption device is required and, they are based on HTTP redirection mechanisms. However, some use cases not covered by these flows have been raised, where the RP needs to be the initiator of the user authentication flow and end-user interaction from the consumption device is not needed.

Client Initiated Backchannel Authentication (CIBA) is a new authentication flow in which RPs, that can obtain a valid identifier for the user they want to authenticate, will be able to initiate an interaction flow to authenticate their users without having end-user interaction from the consumption device. The flow involves direct communication from the Client to the OpenID Provider without redirect through the user's browser (consumption device).

This specification does not change the semantics of the OpenID Connect Authentication flow. It introduces a new endpoint to which the authentication request is posted. It introduces a new asynchronous method for authentication result notification or delivery. It does not introduce new scope values nor does it change the semantics of standard OpenID Connect parameters.

As the user does not provide authentication credentials directly to the consumption device, supporting this flow requires the to OP have some mechanism of initiating user authentication out-of-band from the interaction with the consumption device.

For more information, see [https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-ID1.html](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0-ID1.html)

## Protocol Overview

Client Initiated Backchannel Authentication (CIBA) enables a Client to initiate the authentication of an end-user by means of out-of-band mechanisms.

1. The Client makes an "HTTP POST" request to the Backchannel Authentication Endpoint to ask for end-user authentication.

1. The OP will respond immediately with a unique identifier that identifies that authentication while it tries to authenticate the user in the background.

1. The Client will receive the ID Token, Access Token and optionally Refresh Token by means of either the Poll, Ping or Push modes, this choice must be established by the Client at registration time.

    - *Poll Mode.* When configured in Poll mode, the Client will poll the token endpoint to get a response with the tokens.

    - *Ping Mode.* When configured in Ping mode, the OP will send a request to a callback URI previously registered by the Client with the unique identifier returned from the Backchannel Authentication Endpoint. Upon receipt of the notification, the Client makes a request to the token endpoint to obtain the tokens.

    - *Push Mode.* When configured in Push mode, the OP will send a request with the tokens to a callback URI previously registered by the Client.

It's handy to know some CIBA terminology:

- *Consumption Device (CD).* The Consumption Device is the device that helps the user consume the service. In the CIBA use case, the user is not necessarily in control of the CD. For example, the CD may be in the control of an RP agent (e.g. at a bank teller) or may be an RP controlled device (e.g. a petrol pump).

- *Authentication Device (AD).* The device on which the user will authenticate and authorize
the request, often a smartphone.

## Discovery Metadata

- *Grant Type.* This specification introduces the CIBA grant type (an extension grant type as defined by [Section 4.5 of OAuth 2.0](https://tools.ietf.org/html/rfc6749#section-4.5)) with the value: ```urn:openid:params:grant-type:ciba```

- *OpenID Provider Metadata.* The following authorization server metadata parameters are introduced for OPs publishing their support of the CIBA flow:

    - *backchannel_authentication_endpoint*. URL of the OP's Backchannel Authentication Endpoint.

    - *backchannel_token_delivery_modes_supported.* JSON array containing one or more of the following values: poll, ping and push.

    - *backchannel_authentication_request_signing_alg_values_supported.* JSON array containing a list of the JWS signing algorithms (alg values) supported by the OP for signed authentication requests.

    - *backchannel_user_code_parameter_supported.* Boolean value specifying whether the OP supports use of the user_code parameter.

Example configuration request using oxauth-client:

```
OpenIdConfigurationClient client = new OpenIdConfigurationClient(configurationEndpoint);
OpenIdConfigurationResponse response = client.execOpenIdConfiguration();
```

Configuration Request:

```
GET /.well-known/openid-configuration HTTP/1.1
Host: idp.example.com
```

Configuration Response:

```
HTTP/1.1 200
Content-Length: 6758
Content-Type: application/json
Server: Jetty(9.4.11.v20180605)

{
  .....
  "backchannel_authentication_endpoint" : "https://idp.example.com:8443/restv1/bc-authorize",
  "backchannel_token_delivery_modes_supported" : [ "poll", "ping", "push" ],
  "backchannel_authentication_request_signing_alg_values_supported" : [
    "RS512",
    "ES256",
    "ES384",
    "ES512",
    "ES512",
    "PS256",
    "PS384",
    "PS512"
  ],
  "backchannel_user_code_parameter_supported" : true,
  "grant_types_supported" : [
    .....
    "urn:openid:params:grant-type:ciba"
  ],
  .....
}
```

## Dynamic Client Registration

Clients registering to use CIBA must indicate a token delivery mode. When using the *ping* or *poll* mode, the Client must include the CIBA grant type in the *grant_types* field. When using the *ping* or *push* mode, the Client must register a client notification endpoint. Clients intending to send signed authentication requests must register the signature algorithm that will be used.

The following parameters are introduced by this specification:

- *backchannel_token_delivery_mode.* One of the following values are required: poll, ping or push.

- *backchannel_client_notification_endpoint.* Required if the token delivery mode is set to ping or push. This is the endpoint to which the OP will post a notification after a successful or failed end-user authentication. It must be an HTTPS URL.

- *backchannel_authentication_request_signing_alg.* The JWS algorithm alg value that the Client will use for signing authentication request. When omitted, the Client will not send signed authentication requests.

- *backchannel_user_code_parameter.* Boolean value specifying whether the Client supports the user_code parameter. If omitted, the default value is false.

Example registration request using oxauth-client:

```
RegisterRequest registerRequest = new RegisterRequest(ApplicationType.WEB, "oxAuth test app", null);
registerRequest.setGrantTypes(Arrays.asList(GrantType.CIBA));

registerRequest.setBackchannelTokenDeliveryMode(BackchannelTokenDeliveryMode.PUSH);
registerRequest.setBackchannelClientNotificationEndpoint(backchannelClientNotificationEndpoint);
registerRequest.setBackchannelAuthenticationRequestSigningAlg(AsymmetricSignatureAlgorithm.RS256);
registerRequest.setBackchannelUserCodeParameter(true);

RegisterClient registerClient = new RegisterClient(registrationEndpoint);
registerClient.setRequest(registerRequest);
RegisterResponse registerResponse = registerClient.exec();
```

Registration Request:

```
POST /restv1/register HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: idp.example.com

{
  "grant_types" : [ "urn:openid:params:grant-type:ciba" ],
  "application_type" : "web",
  "backchannel_client_notification_endpoint" : "https://idp.example.com:8443/oxauth-ciba-client-test/client-notification-endpoint",
  "jwks_uri" : "https://idp.example.com:8443/oxauth/restv1/jwks",
  "backchannel_user_code_parameter" : true,
  "backchannel_authentication_request_signing_alg" : "RS256",
  "client_name" : "oxAuth test app",
  "backchannel_token_delivery_mode" : "push"
}
```

Registration Response:

```
HTTP/1.1 200
Cache-Control: no-store
Content-Length: 1561
Content-Type: application/json
Pragma: no-cache
Server: Jetty(9.4.11.v20180605)

{
    "application_type": "web",
    "registration_client_uri": "https://idp.example.com:8443/restv1/register?client_id=4251a8c4-69e3-4d3e-a807-758ecbc51118",
    "registration_access_token": "e9ecb1a1-001c-4d04-b2f2-b42e35664975",
    "client_id": "4251a8c4-69e3-4d3e-a807-758ecbc51118",
    "token_endpoint_auth_method": "client_secret_basic",
    "scope": "profile openid permission super_gluu_ro_session work_phone phone address org_name clientinfo email user_name test oxd uma_protection",
    "backchannel_user_code_parameter": true,
    "client_secret": "f101f27b-0f18-4bff-9470-c33361f28ff9",
    "client_id_issued_at": 1574831171,
    "backchannel_authentication_request_signing_alg": "RS256",
    "client_name": "oxAuth test app",
    "backchannel_token_delivery_mode": "push",
    "id_token_signed_response_alg": "RS256",
    "grant_types": ["urn:openid:params:grant-type:ciba"],
    "subject_type": "pairwise",
    "client_secret_expires_at": 1574917571,
    "jwks_uri" : "https://idp.example.com:8443/oxauth/restv1/jwks",
    "backchannel_client_notification_endpoint": "https://idp.example.com:8443/oxauth-ciba-client-test/client-notification-endpoint",
    "access_token_signing_alg": "RS256",
}
```

## Poll, Ping and Push Modes

This specification allows the Client to get the authentication result in three ways: poll, ping or push.

In the *Push* mode, the OP will post the full authentication result to the Client.

In the *Ping* mode, the OP will post the unique identifier of the authentication session to the Client, the Client will then retrieve the authentication result from the token endpoint using the new grant type.


In the *Poll* mode, the authentication result is retrieved by the Client by polling the OP's token endpoint using the new grant type.

## Authentication Request
CIBA authentication request contains a list of parameters that should be sent depending on the mode(ping, poll, push), however here is the main list of parameters:

- *scope (required)* The scope of the access request as described by Section 3.3 of [RFC6749](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html#RFC6749). OpenID Connect implements authentication as an extension to OAuth 2.0 by including the openid scope value in the authorization requests.
- *client_notification_token (required)* if the Client is registered to use Ping or Push modes. It is a bearer token provided by the Client that will be used by Gluu Server to authenticate the callback request to the Client.
- *acr_values (optional)* Requested Authentication Context Class Reference values. Space-separated string that specifies the acr values that Gluu Server is being requested to use for processing this Authentication Request, with the values appearing in order of preference.
- *login_hint_token (optional)* A token containing information identifying the end-user for whom authentication is being requested.
- *id_token_hint (optional)* An ID Token previously issued to the Client by Gluu Server being passed back as a hint to identify the end-user for whom authentication is being requested.
- *login_hint (optional)* The value may contain an email address, phone number, account number, subject identifier, username, etc., which identifies the end-user to the OP.
- *binding_message (optional)* A human readable identifier or message intended to be displayed on both the consumption device and the authentication device to interlock them together for the transaction by way of a visual cue for the end-user.
- *user_code (optional)* A secret code, such as password or pin, known only to the user but verifiable by Gluu Server. The code is used to authorize sending an authentication request to user's authentication device.
- *requested_expiry (optional)* A positive integer allowing the client to request the `expires_in` value for the `auth_req_id` the server will return.

Example:
```
POST /restv1/bc-authorize HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Host: test.gluu.org
Authorization: Basic MTIzLTEyMy0xMjM6WkE1aWxpTFFDYUR4

scope=openid&client_notification_token=12-12&acr_values=simple_password_auth&login_hint=test_user
```

#### Successful Authentication Response
Gluu Server is going to return an HTTP 200 OK response to the Client to indicate that the authentication request has been accepted and it is going to be processed. The body of this response will contain:

- *auth_req_id (required)* This is a unique identifier to identify the authentication request made by the Client.
- *expires_in (required)* A positive integer value indicating the expiration time of the `auth_req_id` in seconds since the authentication request was received.
- *interval (optional)* A positive integer value indicating the minimum amount of time in seconds that the Client MUST  wait between polling requests to the token endpoint.

Example:
```
HTTP/1.1 200
Cache-Control: no-store
Content-Length: 116
Content-Type: application/json
Server: Jetty(9.4.19.v20190610)

{
    "auth_req_id": "01754518964fba15ca786e0d82e1030c320733a10fddfd6d",
    "interval": 2,
    "expires_in": 3600
}
```

#### Authentication Error Response
Error response is sent using a HTTP code different than 200 and a json body containing some information about the error which could containg these fields:

- *error (required)* A single error code that could contain following values listed below.
- *error_description (optional)* Human-readable text providing additional information.

List of authentication error codes associated to HTTP Errors:

HTTP 400 Bad Request:
  - *invalid_request*
  - *invalid_scope*
  - *expired_login_hint_token*
  - *unknown_user_id*
  - *unauthorized_client*
  - *missing_user_code*
  - *invalid_user_code*
  - *invalid_binding_message*

HTTP 401 Unauthorized
  - *invalid_client*

HTTP 403 Forbidden
  - *access_denied*

Example:
```
HTTP/1.1 400
Content-Length: 245
Content-Type: application/json
Server: Jetty(9.4.19.v20190610)

{
    "error_description": "The request is missing a required parameter, includes an invalid parameter value, includes a parameter more than once, contains more than one of the hints, or is otherwise malformed.",
    "error": "invalid_request"
}
```

## Ping Callback
In case that the client is registered to use Ping mode, then Gluu Server will send an HTTP POST Request to the client notification endpoint after a successful or failed end-user authentication.

In this mode the OP sends the `client_notification_token` as a bearer token in the Authorization header field and sends only the `auth_req_id` in the body of the request. The request uses the `application/json` media type.

In case the request is expired, OP will send same ping callback and the expiration message will be received once client calls token endpoint.

Example:
```
Content-Type: application/json
Authorization: Bearer ebq/mzAm_2H2sqcnogfc=
Server: Jetty(9.4.19.v20190610)

{"auth_req_id": "2dc59a83b2318d2486c61a1c8015472f11711a5bba3ec40d"}
```
Response of this request is not processed by Gluu Server based on specs.

## Push Callback

#### Authorized Push Callback
If the client is registered in push mode and the end-user is authenticated correctly, then OP will deliver a payload that includes an ID Token, an Access Token and optionally, a Refresh Token to the client notification endpoint.

Example:
```
Content-Type: application/json
Authorization: Bearer ebq/mzAm_2H2sqcnogfc=
Server: Jetty(9.4.19.v20190610)

{
    "access_token": "1532284a-b357-462c-8749-517d3d5483e1",
    "refresh_token": "4219ebac-3e18-446b-bd17-f2dfdbfab405",
    "auth_req_id": "55da56321ca83b6d1dbc5fbab83adb50b941e5021521f135",
    "id_token": "eyJraWQiOiJlYTc4NDgxYy05OTJkLTRmN2UtYTkzMS03NjM2NTYyMzgwZjVfc2lnX3JzMjU2IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiVzdHVnlqTzVmLXh4dS1vQnRJRnRBUSIsImF1ZCI6IjEyMy0xMjMtMTIzIiwiYWNyIjoic2ltcGxlX3Bhc3N3b3JkX2F1dGgiLCJzdWIiOiJ0VmRiMUpFZnpLeHhkUE45RkU1TE0xQndaTjRaTHF0SF81Y0RIdkstaWxJIiwidXJuOm9wZW5pZDpwYXJhbXM6and0OmNsYWltOmF1dGhfcmVxX2lkIjoiNTVkYTU2MzIxY2E4M2I2ZDFkYmM1ZmJhYjgzYWRiNTBiOTQxZTUwMjE1MjFmMTM1IiwidXJuOm9wZW5pZDpwYXJhbXM6and0OmNsYWltOnJ0X2hhc2giOiJYYjg2V2t1TDdtb2FrUWc2ejg1aDFRIiwiYW1yIjpbIi0xIl0sImlzcyI6Imh0dHBzOi8vdGVzdC5nbHV1Lm9yZzo4NDQzIiwiZXhwIjoxNTkyOTI0MTIxLCJpYXQiOjE1OTI5MjA1MjEsIm94T3BlbklEQ29ubmVjdFZlcnNpb24iOiJvcGVuaWRjb25uZWN0LTEuMCJ9.0KBg06A43ujDAL2bw3855V1zWtrxcg7RML2CQRCU8rWGn-IB-mhTZgxvRMjlMnb8fq8VQE3F2Snpl1Te0bjQRrz71_-nUnt0VdCnxOCiIv5kr46kp6kiM2lQnCeRrPKIY2D05EYxtArPsQvsnA7-BetXpGD6K79b-Y05WCF4KzFinBSUyOWScE7jy0X0cgF2ns4lChotjFOD8tUnAleGGKa59W3t3KJJchoD6XFE9qOW6c5IqYHpTBhcQmYDtPsjW9DjJ-x3IuHBRC5PSkC7d0FEJBfrzFnNnsYC7D93rca9QQSfJFy6BF0INwpys6L5jg_QfoyEuKI1_Iq2uZU8UA",
    "token_type": "bearer",
    "expires_in": 299
}
```

#### Push Error Callback
In case the authentication fails for any reason, it means client doesn't response, he denies the authorization or any reason, OP will send an error payload to the client notification endpoint.

Body of the callback could contain these following parameteres:
- *error_description (optional)* Human-readable text providing additional information, used to assist the client developer in understanding the error.
- *error (required)* A single error code, values are listed below.
- *auth_req_id (required)* The authentication request identifier.

Error codes applicable to the push error payload:
- *access_denied*
- *expired_token*
- *transaction_failed*

Example:
```
Content-Type: application/json
Authorization: Bearer ebq/mzAm_2H2sqcnogfc=
Server: Jetty(9.4.19.v20190610)

{
    "auth_req_id": "05b64509ef9dbf9125783d0a23413e9917a5a006df2fc6d5",
    "error_description": "The end-user denied the authorization request.",
    "error": "access_denied"
}
```

## Token Request
Token request should be done using CIBA grant and is only used in `poll` and `ping` flows, so this endpoint should be used in this way:

- *poll mode* In this case, client should call every N seconds to this endpoint.
- *ping mode* client should call once he receives the callback from the OP, however it's also possible to call to the endpoint before, in that case, the behaviour would be very similar than `poll` mode.

Custom parameters for CIBA grant type are:
- *grant_type (required)* Value MUST be `urn:openid:params:grant-type:ciba`
- *auth_req_id (required)* It's the unique identifier to identify the authentication request made by the Client.

Example:
```
POST /restv1/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Host: test.gluu.org
Authorization: Basic MTIzLTEyMy0xMjM6WkE1aWxpTFFDYUR4

grant_type=urn%3Aopenid%3Aparams%3Agrant-type%3Aciba&authReqId=4ba35d535c8e99ea5d9aa14bd13d5d42607e362fae1df53a
```

#### Successful Token Response
If the authorization goes fine, then authorization server will return all tokens according to the configuration and a HTTP 200 status.

Example:
```
HTTP/1.1 200
Cache-Control: no-store
Content-Length: 1122
Content-Type: application/json
Pragma: no-cache
Server: Jetty(9.4.19.v20190610)

{"access_token":"8cc0cb03-efdb-4545-a1dd-a5568bff6aa9","id_token":"eyJraWQiOiJlYTc4NDgxYy05OTJkLTRmN2UtYTkzMS03NjM2NTYyMzgwZjVfc2lnX3JzMjU2IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiNllLcGVKUlhHNldDZWcxTnY5QUVJZyIsImF1ZCI6IjEyMy0xMjMtMTIzIiwiYWNyIjoic2ltcGxlX3Bhc3N3b3JkX2F1dGgiLCJzdWIiOiJpRDUyZlN4TVh5YjNFRnNjR1d4TlUxZnB5UU9qQWlMY3RkSldFQk55M1BVIiwidXJuOm9wZW5pZDpwYXJhbXM6and0OmNsYWltOmF1dGhfcmVxX2lkIjoiNGJhMzVkNTM1YzhlOTllYTVkOWFhMTRiZDEzZDVkNDI2MDdlMzYyZmFlMWRmNTNhIiwidXJuOm9wZW5pZDpwYXJhbXM6and0OmNsYWltOnJ0X2hhc2giOiJianFrYS1tOS1xZnpacE1rUXB5cURBIiwiYW1yIjpbIi0xIl0sImlzcyI6Imh0dHBzOi8vdGVzdC5nbHV1Lm9yZzo4NDQzIiwiZXhwIjoxNTkyODc0MDUyLCJpYXQiOjE1OTI4NzA0NTIsIm94T3BlbklEQ29ubmVjdFZlcnNpb24iOiJvcGVuaWRjb25uZWN0LTEuMCJ9.AtVs_PAsk8-O1jhPwsSIOqaCcDmc1lfE8gY2zgngyJf-ryC7HbhWuOQ_FcwVSHu9Og0Q9DqhTiOLAgeF6C2yHu88o72Bb6AFYJnn8Fyb-hEya3oggQU7j3jdNQB15S-p15ERvNwdT9nSWyxfezeruhBRtaC676iUOMLk61N8HyM4jnadWeGiDUC-7L4ZfLSkMnI0gy3I0dLQ6wKwyuRXPWbZcmqimCKTrVSmBuRRjQ-JLFyaWn2quyki7tSlDpVZ_o_9zwIYLkiFW4Mc1gOAbg-Gz7jqyVb-drarWLNQJWXsqfF0JERk19lTjA1CGW9nbcwhcEnmbFCtYavOW_X8YQ","token_type":"bearer","expires_in":299}
```

#### Token Error Response
If the authorization is not completed, then authorization server could return one of these error response:

- *authorization_pending* The authorization request is still pending as the end-user hasn't yet been authenticated.
- *slow_down* A variant of "authorization_pending", the authorization request is still pending and polling should continue, but the interval MUST be increased by at least 5 seconds for this and all subsequent requests.
- *expired_token* The auth_req_id has expired. The Client will need to make a new Authentication Request.
- *access_denied* The end-user denied the authorization request.
- *invalid_grant*
- *invalid_request*
- *unauthorized_client*

Example:

```
HTTP/1.1 400
Cache-Control: no-store
Content-Length: 90
Content-Type: application/json
Pragma: no-cache
Server: Jetty(9.4.19.v20190610)

{
    "error_description": "authorization_pending",
    "error": "authorization_pending"
}
```

