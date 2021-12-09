# Update Token Interception Script

This script can be used to add custom claims to the id_token. As per the open banking standard, the token should contain claim openbanking_intent_id and the same value should also reflect in the sub claim. A similar expectation is required to be fulfilled by the FAPI-RW standard where the sub claim should have the user id.

## Configuration Prerequisites
- A Janssen Authorization Server installation
- [Update Token script](https://github.com/JanssenProject/jans-setup/blob/openbank/static/extension/update_token/UpdateToken.py) - included in the default Janssen OpenBanking distribution
- Setting configuration Parameters

## Adding the custom script

1. To add or update custom scripts, you can use either jans-cli or curl. jans-cli in interactive mode, option 13 enables you manage custom scripts. For more info, see the [docs](https://github.com/JanssenProject/home/wiki/Custom-Scripts-using-jans-cli).
1. jans-cli in command line argument mode is more conducive to scripting and automation. To display the available operations for custom scripts, use config-cli.py --info CustomScripts. See the [docs](../jans-cli.md) for more info.
1. To use `curl` see these [docs](../curl.md)

!!! Note
    You can normally find `jans-cli.py` in the `/opt/jans/jans-cli/` folder. 
 
## Steps to add / edit / delete configuration parameters:
1. Place a [JSON file] containing configuration parameters and the [custom script](https://github.com/JanssenProject/jans-setup/blob/openbank/static/extension/update_token/updatetoken.json) in a folder. 

1. From this folder, run the following command: 

```
python3 jans-cli-linux-amd64.pyz --operation-id post-config-scripts --data /updatetoken.json \
--cert-file jans_cli_client.crt --key-file jans_cli_client.key
```

## Methods

1.  UpdateTokenType class and default methods

    ```python3
    class UpdateToken(UpdateTokenType):
    
        def __init__(self, currentTimeMillis):
            self.currentTimeMillis = currentTimeMillis
    
        def init(self, customScript, configurationAttributes):
            return True
    
        def destroy(self, configurationAttributes):
            return True
    
        def getApiVersion(self):
            return 11
    ```

2.  modifyIdToken () : the crucial business logic. This script overrides the header and claims. 

    ```python3
        # Returns boolean, true - indicates that script applied changes
        # Note :
        # jsonWebResponse - is JwtHeader, you can use any method to manipulate JWT
        # context is reference of io.jans.oxauth.service.external.context.ExternalUpdateTokenContext (in https://github.com/GluuFederation/oxauth project, )
        def modifyIdToken(self, jsonWebResponse, context):
                  
             #read from session 
        sessionIdService = CdiUtil.bean(SessionIdService)
        sessionId = sessionIdService.getSessionByDn(context.getGrant().getSessionDn()) # fetch from persistence
            openbanking_intent_id = sessionId.getSessionAttributes().get("openbanking_intent_id")
        acr = sessionId.getSessionAttributes().get("acr_ob")
    
                # header claims
        jsonWebResponse.getHeader().setClaim("custom_header_name", "custom_header_value")
                
        #custom claims
        jsonWebResponse.getClaims().setClaim("openbanking_intent_id", openbanking_intent_id)
                
        #regular claims        
        jsonWebResponse.getClaims().setClaim("sub", openbanking_intent_id)
    
        return True
        
    ```
3. The getRefreshTokenLifetimeInSeconds method: This method adds the ability to specify refersh_token lifetime via update_token script. If this method return 0 then built-in configuration property of AS is used to define RT lifetime refreshTokenLifetime.  

   ```python3
        def getRefreshTokenLifetimeInSeconds(self, context):
            return 0
   ```
4. Other usefull methods. 


    ```python3
        # Returns boolean, true - indicates that script applied changes. If false is returned token will not be created.
        # refreshToken is reference of io.jans.as.server.model.common.RefreshToken (note authorization grant can be taken as context.getGrant())
        # context is reference of io.jans.as.server.service.external.context.ExternalUpdateTokenContext (in https://github.com/JanssenProject/jans-auth-server project, )
        def modifyRefreshToken(self, refreshToken, context):
            return True

        # Returns boolean, true - indicates that script applied changes. If false is returned token will not be created.
        # accessToken is reference of io.jans.as.server.model.common.AccessToken (note authorization grant can be taken as context.getGrant())
        # context is reference of io.jans.as.server.service.external.context.ExternalUpdateTokenContext (in https://github.com/JanssenProject/jans-auth-server project, )
        def modifyAccessToken(self, accessToken, context):
            return True

        # context is reference of io.jans.as.server.service.external.context.ExternalUpdateTokenContext (in https://github.com/JanssenProject/jans-auth-server project, )
        def getRefreshTokenLifetimeInSeconds(self, context):
            return 0

        # context is reference of io.jans.as.server.service.external.context.ExternalUpdateTokenContext (in https://github.com/JanssenProject/jans-auth-server project, )
        def getIdTokenLifetimeInSeconds(self, context):
            return 0

        # context is reference of io.jans.as.server.service.external.context.ExternalUpdateTokenContext (in https://github.com/JanssenProject/jans-auth-server project, )
        def getAccessTokenLifetimeInSeconds(self, context):
            return 0
    ```
