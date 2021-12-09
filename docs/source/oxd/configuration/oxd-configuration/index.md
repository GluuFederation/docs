# Configuration (oxd-server.yml)

oxd configuration is located at `/opt/oxd-server/conf/oxd-server.yml` inside Gluu Server chroot. It consists of three major parts:

- `server configuration` - oxd specific configuration
- `defaultSiteConfig` - fallback configuration values for the OpenID Connect `/register-site` command. Learn more on the [oxd API page](../../api/index.md#register-site)
- Everything else that is inside comes from the Dropwizard framework. For a complete list of server-related parameters, click [here](https://www.dropwizard.io/en/stable/manual/configuration.html)

Here we will explain `server configuration` and `defaultSiteConfig`. Dropwizard configuration parameters can be checked in the Dropwizard [configuration documentation](https://www.dropwizard.io/en/stable/manual/configuration.html).

The content of the `/opt/oxd-server/conf/oxd-server.yml` file is as follows:

```
oxd-server.yml

# server configuration
use_client_authentication_for_pat: true
trust_all_certs: true
trust_store_path: ''
trust_store_password: ''
crypt_provider_key_store_path: ''
crypt_provider_key_store_password: ''
crypt_provider_dn_name: ''
fapi_enabled: false
mtls_enabled: false
mtls_client_key_store_path: ''
mtls_client_key_store_password: ''
tls_version: ['TLSv1.2']
tls_secure_cipher: ['TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384']
support-google-logout: true
state_expiration_in_minutes: 5
nonce_expiration_in_minutes: 5
encode_state_from_request_parameter: true
encode_nonce_from_request_parameter: true
encode_client_id_in_authorization_url: true
encode_state_from_request_parameter: true
encode_nonce_from_request_parameter: true
rp_cache_expiration_in_minutes: 60
public_op_key_cache_expiration_in_minutes: 60
protect_commands_with_access_token: true
accept_id_token_without_signature: false
id_token_validation_c_hash_required: true
id_token_validation_at_hash_required: true
uma2_auto_register_claims_gathering_endpoint_as_redirect_uri_of_client: true
add_client_credentials_grant_type_automatically_during_client_registration: true
migration_source_folder_path: ''
allowed_op_hosts: []
bind_ip_addresses: []
protect_commands_with_oxd_id: []
storage: h2
storage_configuration:
  dbFileLocation: /opt/oxd-server/data/oxd_db
proxy_configuration:
  host: 'localhost'
  port: 8888
  protocol: 'http'

# Dropwizard configurations
# Connectors
server:
  applicationConnectors:
    - type: https
      port: 8443
      keyStorePath: /opt/oxd-server/conf/oxd-server.keystore
      keyStorePassword: example
      validateCerts: false
  adminConnectors:
    - type: https
      port: 8444
      keyStorePath: /opt/oxd-server/conf/oxd-server.keystore
      keyStorePassword: example
      validateCerts: false

# Logging settings.
logging:

  # The default level of all loggers. Can be OFF, ERROR, WARN, INFO, DEBUG, TRACE, or ALL.
  level: INFO

  # Logger-specific levels.
  loggers:
    org.gluu: TRACE
    org.xdi: TRACE

# Logback's Time Based Rolling Policy - archivedLogFilenamePattern: /tmp/application-%d{yyyy-MM-dd}.log.gz
# Logback's Size and Time Based Rolling Policy -  archivedLogFilenamePattern: /tmp/application-%d{yyyy-MM-dd}-%i.log.gz
# Logback's Fixed Window Rolling Policy -  archivedLogFilenamePattern: /tmp/application-%i.log.gz

  appenders:
    - type: console
    - type: file
      threshold: INFO
      logFormat: "%-6level [%d{HH:mm:ss.SSS}] [%t] %logger{5} - %X{code} %msg %n"
      currentLogFilename: /var/log/oxd-server/oxd-server.log
      archivedLogFilenamePattern: /var/log/oxd-server/oxd-server-%d{yyyy-MM-dd}-%i.log.gz
      archivedFileCount: 7
      timeZone: UTC
      maxFileSize: 10MB

defaultSiteConfig:
  op_configuration_endpoint: ''
  response_types: ['code']
  grant_type: ['authorization_code']
  acr_values: ['']
  scope: ['openid', 'profile', 'email']
  ui_locales: ['en']
  claims_locales: ['en']
  contacts: []
  redirect_uris: []
  logout_redirect_uris: []
  client_name: ''
  client_jwks_uri: ''
  token_endpoint_auth_method: ''
  token_endpoint_auth_signing_alg: ''
  request_uris: []
  front_channel_logout_uris: []
  sector_identifier_uri: ''
  claims_redirect_uri: []
  client_id: ''
  client_secret: ''
  access_token_as_jwt: false
  access_token_signing_alg: ''
  rpt_as_jwt: false
  logo_uri: ''
  client_uri: ''
  policy_uri: ''
  front_channel_logout_session_required: false
  tos_uri: ''
  jwks: ''
  id_token_binding_cnf: ''
  tls_client_auth_subject_dn: ''
  run_introspection_script_beforeaccess_token_as_jwt_creation_and_include_claims: false
  id_token_signed_response_alg: ''
  id_token_encrypted_response_alg: ''
  id_token_encrypted_response_enc: ''
  user_info_signed_response_alg: ''
  user_info_encrypted_response_alg: ''
  user_info_encrypted_response_enc: ''
  request_object_signing_alg: ''
  request_object_encryption_alg: ''
  request_object_encryption_enc: ''
  default_max_age: null
  require_auth_time: false
  initiate_login_uri: ''
  authorized_origins: []
  access_token_lifetime: null
  software_id: ''
  software_version: ''
  software_statement: ''
  custom_attributes: {}

```
### Server configuration fields descriptions

- **use_client_authentication_for_pat:** If set to `true`, client authentication is required. If `false`, user authentication requires `user_id` and `user_secret` to be specified during the `register_site` command

- **trust_all_certs:** `true` to trust all certificates, if `false` then `trust_store_path` must be specified to store with valid certificates

- **trust_store_path:** Path to Java `.jks` trust store to be used for an SSL connections

- **trust_store_password:** Password to access the trust store

- **crypt_provider_key_store_path:** Path to the cryptologic service provider's key store. This key store is used for storing client side jwks. 
  
- **crypt_provider_key_store_password:** Password to access the cryptologic service provider's key store
 
- **crypt_provider_dn_name:** Cryptologic service provider's domain name

- **fapi_enabled:** If set to `true` then FAPI related validation are enabled in oxd. The default value of this property is `false`.

- **mtls_enabled:** If set to `true` then mtls authentication is enabled in oxd. For mtls authentication the values of `mtls_client_key_store_path` and `mtls_client_key_store_password` are also mandatory. The default value of this property is `false`.

- **mtls_client_key_store_path:** Path to client's key store for mtls authentication.

- **mtls_client_key_store_password:** Password to access the client's key store.

- **tls_version:** Array containing list of supported tls versions for communicating with OP server.

- **tls_secure_cipher:** Array containing list of supported tls ciphers for communicating with OP server.

- **support-google-logout:** Choose whether to support Google logout or not. Only use this if you are using Google as your OP

- **state_expiration_in_minutes:** Expiration time of `state` parameter in minutes

- **nonce_expiration_in_minutes:** Expiration time of `nonce` parameter in minutes

- **encode_state_from_request_parameter:** Encode the `state` passed with api-request if set to `true`. The default value of this property is `false` which means `state` will not be encoded.

- **encode_nonce_from_request_parameter:** Encode the `nonce` passed with api-request if set to `true`. The default value of this property is `false` which means `nonce` will not be encoded.

- **encode_client_id_in_authorization_url:** Encode the `client_id` passed with `authorization-url` if set to `true`. The default value of this property is `false` which means `client_id` will not be encoded.

- **rp_cache_expiration_in_minutes:** Expiration time of registered Client metadata stored in cache (in minutes). Default value is 60 minutes

- **public_op_key_cache_expiration_in_minutes:** OP keys are put into cache after fetching. This value controls how long to keep it in cache (after expiration on first attempt keys are fetched again from OP)

- **protect_commands_with_access_token:** In order to protect communication between `oxd-server` and the client application (RP) this value MUST be set to `true`.

- **accept_id_token_without_signature** In order to allow `id_token` without any signature, set this field to `true`. The default value of this property is `false` which means `id_token` should be signed with algorithm.

- **id_token_validation_c_hash_required** If this property is set to `true` then `c_hash` validation in id_token will be done in `code id_token` and `code id_token token` hybrid flows. The default value of this property is `true`.

- **id_token_validation_at_hash_required** If this property is set to `true` then `at_hash` validation in id_token will be done in 'id_token token' (Implicit) and `code id_token token` (Hybrid) flows. The default value of this property is `true`.

- **uma2_auto_register_claims_gathering_endpoint_as_redirect_uri_of_client:** Notifies the `oxd-server` whether to automatically register the `Claims Gathering Endpoint` as the `claims_redirect_uri` for a given client. It is useful for UMA 2 clients that wish to force authorization against the Gluu Server. To provide custom `claims_redirect_uri`, set this property to `false`

- **add_client_credentials_grant_type_automatically_during_client_registration:** If set to `true` then `client_credentials` grant type is automatically added to clients registered by oxd. If `false`, then `client_credentials` will not be automatically added to clients, but user can still add this grant type while registering clients in AS.

- **migration_source_folder_path:** Migration from previous versions is built into the `oxd-server`. To migrate old JSON files from previous versions, specify the path to folder/directory that contains those JSON files in this property. Those files will be read and imported once (during restart `oxd-server`, will not import them again). If using Windows OS, don't forget to escape the path separator, e.g. `C:\\OXD_OLD\\oxd-server\\conf`

- **allowed_op_hosts:** Array containing a list of the `op_host` urls. oxd can only access the `op_hosts` from this list and all other calls (to IDPs not present in this list ) will be rejected. If the list is empty then oxd is allowed to access any OpenID Connect Provider.

- **bind_ip_addresses:** Array containing list of `ip-address` which are allowed to make request to oxd end-points (Example: `bind_ip_addresses: ['192.465.10.113', '192.215.10.213']`). If this field is empty or not added in `oxd-server.yml` then oxd will allow only localhost to access oxd apis. Adding `'*'` to this array will allow all caller ip-addresses to make request to oxd (Example: `bind_ip_addresses: ['*']`).

- **protect_commands_with_oxd_id** RP can use different Authorization Servers (AS) for protecting oxd API’s with access token. This field contains array of `oxd_id` of AS registered with oxd which are allowed to protect oxd API’s. Eg: `protect_commands_with_oxd_id: ['<oxd_id1>', '<oxd_id2>', '<oxd_id3>' ...]`. If it is missed from the configuration then any AS registered with oxd can be used for protecting oxd end-points.

- **storage:** This value can be [h2](../h2/index.md) or [jdbc](../jdbc/index.md) or [redis](../redis/index.md) or [ldap](../ldap/ldap.md#using-any-local-or-remote-ldap-server-in-oxd) or [couchbase](../couchbase/index.md#using-any-local-or-remote-couchbase-server-in-oxd). oxd can also be configured to use storage of Gluu server by setting this field to `gluu_server_configuration`. Refer [ldap](../ldap/index.md#using-gluu-servers-ldap-in-oxd) and [couchbase](../couchbase/index.md#using-gluu-servers-couchbase-in-oxd) for configuration details.

- **storage_configuration:** Storage configuration details of the storage set in `storage` field. For more details check [H2](../h2/index.md), [Redis](../redis/index.md), [JDBC](../jdbc/index.md), [ldap](../ldap/index.md) and [couchbase](../couchbase/index.md) configuration page.

Redis storage configuration sample:

```
  storage: redis
  storage_configuration
    host: localhost
    port: 6379  
```

H2 storage configuration sample:

```
    storage: h2
    storage_configuration
      dbFileLocation: /opt/oxd-server/data/oxd_db    
```

JDBC storage configuration sample:

```
storage: jdbc
storage_configuration:
    driver: com.mysql.jdbc.Driver
    jdbcUrl: jdbc:mysql://hostname:port/database
    username: user
    password: secret
```
#### Proxy server setting

- **proxy_configuration:** oxd can be configured so that it connects to `OP_HOST` through the `forward proxy`. In order to configure proxy server to oxd `host`, `port` and `protocol` should be set.

- **host** Provide `hostname` of the proxy server. This field is mandatory to configure proxy server.

- **port** Provide `port` of the proxy server. This field is not mandatory.

- **protocol** Provide `protocol` of the proxy server either `http` or `https`. This field is not mandatory. The default protocol is `http`.

Proxy server configuration sample:

```
proxy_configuration:
  host: `localhost`
  port: 8888
  protocol: `http`
```

### defaultSiteConfig Field Descriptions

- **op_configuration_endpoint:** Provide the openid configuration endpoint URL. (Example: "op_configuration_endpoint": "`https://op.example.com/.well-known/openid-configuration`")

- **logout_redirect_uris:** Provide the URLs supplied by the RP to request that the user be redirected to this location after a logout has been performed.

- **redirect_uris:** Provide the list of redirection URIs. The first URL is where the user will be redirected after successful authorization at the OpenID Connect Provider (OP).

- **response_types:** JSON array containing a list of the OAuth 2.0 response_type values that the site is declaring that it will restrict itself to using

- **grant_type:** JSON array containing a list of the OAuth 2.0 Grant Types that the Client is declaring that it will restrict itself to using

- **acr_values:** Preferred authentication method the client will receive from the OP (e.g. basic, Duo, U2F). The specified acr value must be enabled at the OP. If no value is specified, the client will receive the default authentication mechanism specified by the OP. Learn more about how Gluu Server uses acr's in [the docs](https://gluu.org/docs/ce/4.1/authn-guide/intro/).

- **scope:** JSON array containing a list of the scopes that the Client is declaring that it will restrict itself to using

- **ui_locales:** End-User's preferred languages and scripts for the user interface, represented as a space-separated list of BCP47 [RFC5646] language tag values, ordered by preference

- **claims_locales:** End-User's preferred languages and scripts for Claims being returned, represented as a space-separated list of BCP47 [RFC5646] language tag values, ordered by preference

- **contacts:** Array of e-mail addresses for people responsible for this client

- **client_name:** Provide name of the client registered in OpenID Connect Provider

- **client_jwks_uri:** Provide the URL for the Client’s JSON Web Key Set (JWK) document containing key(s) that are used for signing requests to the OP. The JWK Set may also contain the Client’s encryption keys(s) that are used by the OP to encrypt the responses to the Client. When both signing and encryption keys are made available, a use (Key Use) parameter value is required for all keys in the document to indicate each key’s intended usage

- **token_endpoint_auth_method:** Provide the requested authentication method for the Token Endpoint. Valid values are none, client_secret_basic, client_secret_post, client_secret_jwt, private_key_jwt, access_token, tls_client_auth, self_signed_tls_client_auth

- **token_endpoint_auth_signing_alg:** Provide the Requested Client Authentication method for the Token Endpoint. Valid values are none, HS256, HS384, HS512, RS256, RS384, RS512, ES256, ES384, ES512, PS256, PS384, PS512

- **request_uris:** JSON array of request_uri values that are pre-registered by the Client for use at the Authorization Server

- **front_channel_logout_uris:** JSON array of frontchannel logout uris.

- **sector_identifier_uri:** Provide the URL using the https scheme to be used in calculating Pseudonymous Identifiers by the OP. The URL references a file with a single JSON array of redirect_uri values

- **claims_redirect_uri:** JSON array of claims redirect uris

- **client_id:** Provide the client id of existing client, ignores all other parameters and skips new client registration forcing to use existing client (client_secret is required if this parameter is set)

- **client_secret:** Provide the client secret of existing client, must be used together with client_id

- **access_token_as_jwt:** Specifies whether access_token should be return as JWT or not. Default value is false

- **access_token_signing_alg:** Provide signing algorithm used for JWT signing. Valid values are none, HS256, HS384, HS512, RS256, RS384, RS512, ES256, ES384, ES512, PS256, PS384, PS512

- **rpt_as_jwt:** Specifies whether RPT should be return as JWT or not. Default value is false

- **logo_uri:** Provide an URL that references a logo for the Client application

- **client_uri:** Provide an URL of the home page of the Client

- **policy_uri:** Provide an URL that the Relying Party Client provides to the End-User to read about the how the profile data will be used

- **front_channel_logout_session_required:** Specifies if front channel logout session required. Default value is false

- **tos_uri:** Specifies an URL that the Relying Party Client provides to the End-User to read about the Relying Party’s terms

- **jwks:** Client’s JSON Web Key Set (JWK) document, passed by value. The semantics of the jwks parameter are the same as the jwks_uri parameter, other than that the JWK Set is passed by value, rather than by reference. This parameter is intended only to be used by Clients that, for some reason, are unable to use the jwks_uri parameter, for instance, by native applications that might not have a location to host the contents of the JWK Set. If a Client can use jwks_uri, it must not use jwks. One significant downside of jwks is that it does not enable key rotation. The jwks_uri and jwks parameters must not be used together

- **id_token_binding_cnf:** Specifies Token Binding of ID Tokens

- **tls_client_auth_subject_dn:** Specifies tls_client_auth_subject_dn, which the OAuth client will use in mutual-TLS authentication

- **run_introspection_script_beforeaccess_token_as_jwt_creation_and_include_claims:** Choose to run introspection script before access_token_as_jwt creation and include claims. Default value is false

- **id_token_signed_response_alg:** Choose the JWS alg algorithm (JWA) required for the ID Token issued to this client_id. Valid values are none, HS256, HS384, HS512, RS256, RS384, RS512, ES256, ES384, ES512, PS256, PS384, PS512

- **id_token_encrypted_response_alg:** Choose the JWE alg algorithm (JWA) required for encrypting the ID Token issued to this client_id. Valid values are RSA1_5, RSA-OAEP, A128KW, A256KW

- **id_token_encrypted_response_enc:** Choose the JWE enc algorithm (JWA) required for symmetric encryption of the ID Token issued to this client_id. Valid values are A128CBC+HS256, A256CBC+HS512, A128GCM, A256GCM

- **user_info_signed_response_alg:** Choose the JWS alg algorithm (JWA) required for UserInfo responses. Valid values are none, HS256, HS384, HS512, RS256, RS384, RS512, ES256, ES384, ES512, PS256, PS384, PS512

- **user_info_encrypted_response_alg:** Choose the JWE alg algorithm (JWA) required for encrypting UserInfo responses. Valid values are RSA1_5, RSA_OAEP, A128KW, A256KW

- **user_info_encrypted_response_enc:** Choose the JWE enc algorithm (JWA) required for symmetric encryption of UserInfo responses. Valid values are A128CBC+HS256, A256CBC+HS512, A128GCM, A256GCM

- **request_object_signing_alg:** Choose the JWS alg algorithm (JWA) that must be required by the Authorization Server. Valid values are none, HS256, HS384, HS512, RS256, RS384, RS512, ES256, ES384, ES512, PS256, PS384, PS512

- **request_object_encryption_alg:** Choose the JWE alg algorithm (JWA) the RP is declaring that it may use for encrypting Request Objects sent to the OP. Valid values are RSA1_5, RSA_OAEP, A128KW, A256KW

- **request_object_encryption_enc:** Choose the JWE enc algorithm (JWA) the RP is declaring that it may use for encrypting Request Objects sent to the OP. Valid values are A128CBC+HS256, A256CBC+HS512, A128GCM, A256GCM

- **default_max_age:** Provide the Default Maximum Authentication Age (in Integer)

- **require_auth_time:** Specifies the Boolean value specifying whether the auth_time claim in the id_token is required. It is required when the value is true. The auth_time claim request in the request object overrides this setting

- **initiate_login_uri:** Provide the URI using the https scheme that the authorization server can call to initiate a login at the client

- **authorized_origins:** JSON array of authorized JavaScript origins example: List [ "beem://www.test.com", "fb://app.local.url" ]

- **access_token_lifetime:** Provide the Client-specific access token expiration (in Integer)

- **software_id:** Provide a unique identifier string (UUID) assigned by the client developer or software publisher used by registration endpoints to identify the client software to be dynamically registered

- **software_version:** Provide a version identifier string for the client software identified by `software_id`. The value of the `software_version` should change on any update to the client software identified by the same `software_id`

- **software_statement:** Provide a software statement containing client metadata values about the client software as claims. This is a string value containing the entire signed JWT

- **custom_attributes:** Json object to provide custom attribute to registration client
