## What's New in Version 4.2

oxd 4.2 includes architectural changes as well as different bug fixes and improvements:

### Fixes / Enhancements in 4.2.2
- [#565](https://github.com/GluuFederation/oxd/issues/565) Create `login initiation endpoint` in oxd to initiate Login from a Third Party
- [#560](https://github.com/GluuFederation/oxd/issues/560) Displaying oxd version in `/health-check` and `/opt/oxd-server/bin/oxd-server version` output
- [#557](https://github.com/GluuFederation/oxd/issues/557) Automation of swagger client generation in oxd
- [#555](https://github.com/GluuFederation/oxd/issues/555) Handle jwks from OP where keys are without `kid`
- [#550](https://github.com/GluuFederation/oxd/issues/550) Add `id_token_hint` parameter in LogoutUrl
- [#549](https://github.com/GluuFederation/oxd/issues/549) Encode client_id in authorization_url (from `/get-authorization-url`)
- [#543](https://github.com/GluuFederation/oxd/issues/543) Removed re-fetching of jwks from OP server during token validation
- [#542](https://github.com/GluuFederation/oxd/issues/542) FAPI: Audience, Issuer, nonce claim is mandatory in id_token
- [#541](https://github.com/GluuFederation/oxd/issues/541) FAPI: The iat value in the `id_token` should not be very old.
- [#537](https://github.com/GluuFederation/oxd/issues/537) The algorithm used to sign the `id_token` should match with `id_token_signed_response_alg` set during client registration.
- [#536](https://github.com/GluuFederation/oxd/issues/536) FAPI: If the ID Token contains multiple audiences, the Client SHOULD verify that an azp Claim is present.
- [#519](https://github.com/GluuFederation/oxd/issues/519) Validate `s_hash` in id_token
- [#518](https://github.com/GluuFederation/oxd/issues/518) For `private_key_jwt`, `tls_client_auth`, `self_signed_tls_client_auth` allow certificate-based client authentication.
- [#517](https://github.com/GluuFederation/oxd/issues/517) Add fields to select `tlsVersion` and `ciphers` in oxd configuration
- [#511](https://github.com/GluuFederation/oxd/issues/511) Add `client_assertion`, `TokenEndpointAuthSigningAlgorithm` params in ` /get-tokens-by-code`.
- [#476](https://github.com/GluuFederation/oxd/issues/476) Check if issuer from OpenID Provider Configuration Information matches with Webfinger issuer

### Fixes / Enhancements in 4.2.1
- [#538](https://github.com/GluuFederation/oxd/issues/538) Write test with state=base64urlencode(url)
- [#510](https://github.com/GluuFederation/oxd/issues/510) Save `client_id` and `client_secret` in oxd storage (in Rp table) when it is passed as paramater during client registration.

### Fixes / Enhancements in 4.2.0
- [#503](https://github.com/GluuFederation/oxd/issues/503) Add `bindhost` with default value localhost
- [#501](https://github.com/GluuFederation/oxd/issues/501) Correct security alert in test dependency
- [#499](https://github.com/GluuFederation/oxd/issues/499) Passing `Request Object by Value` and `Request Object by Reference` in Authorization Request
- [#495](https://github.com/GluuFederation/oxd/issues/498) Use WebFinger (RFC7033) and OpenID Provider Issuer Discovery to determine the location of the OpenID Provider
- [#57](https://github.com/GluuFederation/oxd/issues/57) UMA protection for oauth2 hack
- [#458](https://github.com/GluuFederation/oxd/issues/458) Add border around error logs to highlight the errors
- [#486](https://github.com/GluuFederation/oxd/issues/486) Improve error message when client_secret is not returned by OP
- [#490](https://github.com/GluuFederation/oxd/issues/490) `trust_all_certs` feature in oxd-server.yml not working
- [#484](https://github.com/GluuFederation/oxd/issues/484) Upgrade oxd to log4j version 2
- [#478](https://github.com/GluuFederation/oxd/issues/478) Read jedis version from `gluu-core-bom`
- [#474](https://github.com/GluuFederation/oxd/issues/474) Configuration changes for oxd Windows service installer
- [#471](https://github.com/GluuFederation/oxd/issues/471) Set default `sync_client_from_op` and `sync_client_period_in_seconds` in RP for clients created using oxd version <= 4.1
- [#466](https://github.com/GluuFederation/oxd/issues/466) Support different AS for `access_token` validation (other than the one processing API call)
- [#441](https://github.com/GluuFederation/oxd/issues/441) Identify the invalid `sub` value and reject the UserInfo Response
- [#464](https://github.com/GluuFederation/oxd/issues/464) Make `Bearer` case insensitive in oxd
- [#449](https://github.com/GluuFederation/oxd/issues/449) Adding `nonce` request parameter to explicity pass `nonce` value to Authentication Request
- [#453](https://github.com/GluuFederation/oxd/issues/453) Verify the `c_hash` presence in the returned ID token for "code id_token" and "code id_token token" hybrid flow
- [#454](https://github.com/GluuFederation/oxd/issues/454) Verify the `at_hash` presence in the ID_token for "id_token token" (implicit) and "code id_token token" (hybrid) flow
- [#451](https://github.com/GluuFederation/oxd/issues/451) Fix client registration request where response_types sent in ["code", "code id_token", "code token"] format instead of ["code", "id_token", "token"]
- [#439](https://github.com/GluuFederation/oxd/issues/439) Accept the ID Token after doing ID Token validation when `id_token_signed_response_alg` is `none`
- [#438](https://github.com/GluuFederation/oxd/issues/438) If `iat` value is missing from `ID_TOKEN` then `ID_TOKEN` should be rejected during validation
- [#440](https://github.com/GluuFederation/oxd/issues/440) Identify the missing `sub` value and reject the ID token
- [#442](https://github.com/GluuFederation/oxd/issues/442) If kid is absent in ID_TOKEN header then use the matching key out of the Issuer's published set
- [#374](https://github.com/GluuFederation/oxd/issues/374) Use cached mocked objects in OpClientFactoryMockImpl
- [#422](https://github.com/GluuFederation/oxd/issues/422) Upgrade oxd to use gluu-core-bomb (the same as oxauth)
- [#364](https://github.com/GluuFederation/oxd/issues/364) Add support for proxy configuration
- [#430](https://github.com/GluuFederation/oxd/issues/430) Add support for JDBC connection to be able to connect to any RDBMS
- [#372](https://github.com/GluuFederation/oxd/issues/372) Performance: oxd under high load has problem with `state` validation
- [#423](https://github.com/GluuFederation/oxd/issues/423) Fix oxd after httpsclient upgrade in oxauth
- [#165](https://github.com/GluuFederation/oxd/issues/165) UMA : add creation and expiration resource support to oxd
- [#91](https://github.com/GluuFederation/oxd/issues/91) UMA 2: add custom redirect parameters to get_claims_gathering_url command
- [#158](https://github.com/GluuFederation/oxd/issues/158) change op_host config param to "op_discovery_uri"
- [#195](https://github.com/GluuFederation/oxd/issues/195) Migrate to swagger 3.0 once swagger-codegen has stable release
- [#126](https://github.com/GluuFederation/oxd/issues/126) Setup script for oxd
- [#128](https://github.com/GluuFederation/oxd/issues/128) Windows setup file needed for oxd service
- [#409](https://github.com/GluuFederation/oxd/issues/409) Add spontaneous scopes to oxd
- [#400](https://github.com/GluuFederation/oxd/issues/400) Check and add to validation missed steps if identified
- [#362](https://github.com/GluuFederation/oxd/issues/362) We need `scopes` explicitly passed into `/uma-rs-check-access` to have granular access handling
- [#384](https://github.com/GluuFederation/oxd/issues/384) Remove ability to set/update Pre-Authorization flag from oxd
- [#363](https://github.com/GluuFederation/oxd/issues/363) Introduce new `/uma-rs-modify` command to be able to modify existing resource
- [#402](https://github.com/GluuFederation/oxd/issues/402) Rename `site -> rp` except persistence
- [#403](https://github.com/GluuFederation/oxd/issues/403) Introduce `Builder` for `Validator` and remove `JwsSignerObject`
- [#390](https://github.com/GluuFederation/oxd/issues/390) Sync client from OP : Update oxd database by reading client
- [#396](https://github.com/GluuFederation/oxd/issues/396) Upgrade `Dropwizard` dependency from version `1.3.1` to `2.0.0`
- [#389](https://github.com/GluuFederation/oxd/issues/389) HA: RpService should cache RP object for configurable amount of time (not indefinitely)
- [#388](https://github.com/GluuFederation/oxd/issues/388) Make h2 database username/password connection details configurable in yml file
- [#387](https://github.com/GluuFederation/oxd/issues/387) `StateService` keeps state and nonce in-memory which prevents HA of oxd
- [#182](https://github.com/GluuFederation/oxd/issues/182) Add tracing metrics to oxd server
- [#381](https://github.com/GluuFederation/oxd/issues/381) Refactor `/register-site` operation code
- [#379](https://github.com/GluuFederation/oxd/issues/379) Incorrect scopes are added when client is updated using `/update-site` command
- [#378](https://github.com/GluuFederation/oxd/issues/378) Rhel-7 package of oxd Does not purge the oxd db at /opt/oxd-server/data
- [#50](https://github.com/GluuFederation/oxd/issues/50) Provide fallback for all parameters
- [#210](https://github.com/GluuFederation/oxd/issues/210) Introduce ability to lock oxd to list of specific IDPs
- [#360](https://github.com/GluuFederation/oxd/issues/360) Create stress/load test which should cover all APIs with mocked OP
- [#162](https://github.com/GluuFederation/oxd/issues/162) Add description and oxdID to client metadata
- [#65](https://github.com/GluuFederation/oxd/issues/65) Return Signed JWT for get_user_info
- [#114](https://github.com/GluuFederation/oxd/issues/114) Hybrid flow : add ability to set response_type directly during authorization url request
