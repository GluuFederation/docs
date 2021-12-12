# Introspection Interception Script

## Overview
Introspection scripts allows to modify response of Introspection Endpoint (spec). Introspection script should be associated with client (used for obtaining the token) in order to be run. 

## Configuration Prerequisites
- A Janssen Authorization Server installation
- [Introspection script](https://github.com/JanssenProject/jans-setup/blob/openbank/static/extension/introspection/IntrospectionScript.py) - included in the default Janssen OpenBanking distribution
- Setting configuration Parameters

## Adding the custom script

1. To add or update custom scripts, you can use either jans-cli or curl. jans-cli in interactive mode, option 13 enables you manage custom scripts. For more info, see the [docs](https://github.com/JanssenProject/home/wiki/Custom-Scripts-using-jans-cli).
1. jans-cli in command line argument mode is more conducive to scripting and automation. To display the available operations for custom scripts, use config-cli.py --info CustomScripts. See the [docs](../api-cli.md) for more info.
1. To use `curl` see these [docs](../curl.md)

!!!Note
    You can normally find `jans-cli.py` in the `/opt/jans/jans-cli/` folder. 
 
## Steps to add / edit / delete configuration parameters**

1. Place a [JSON file] containing configuration parameters and the [custom script](https://github.com/JanssenProject/jans-setup/blob/openbank/static/extension/introspection/IntrospectionScript.py) in a folder. 

1. From this folder, run the following command: 

```
python3 jans-cli-linux-amd64.pyz --operation-id post-config-scripts --data /IntrospectionScript.json \
--cert-file jans_cli_client.crt --key-file jans_cli_client.key
```

### Methods

1. IntrospectionType class and initialization: 

    ```python3
    class Introspection(IntrospectionType):
        def __init__(self, currentTimeMillis):
            self.currentTimeMillis = currentTimeMillis

        def init(self, customScript, configurationAttributes):
            return True

        def destroy(self, configurationAttributes):
            return True

        def getApiVersion(self):
            return 11
    ```

2. This method is called after introspection response is ready. This method can modify the introspection response.

    ```python3
    # Returns boolean, true - apply introspection method, false - ignore it.
    # Note : responseAsJsonObject - is org.codehaus.jettison.json.JSONObject, you can use any method to manipulate json
    # context is reference of org.gluu.oxauth.service.external.context.ExternalIntrospectionContext (in https://github.com/GluuFederation/oxauth project)
    def modifyResponse(self, responseAsJsonObject, context):
        ...
        # get session, extract openbanking_intent_id 
        sessionIdService = CdiUtil.bean(SessionIdService)
        sessionId = sessionIdService.getSessionByDn(context.getTokenGrant().getSessionDn()) # fetch from persistence
        openbanking_intent_id = sessionId.getSessionAttributes().get("openbanking_intent_id")
        
        # modify response
        responseAsJsonObject.accumulate("openbanking_intent_id", openbanking_intent_id)

        return True

    ```
