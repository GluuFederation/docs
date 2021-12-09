# Person Authentication Interception Script

## Overview
This document will explain how to use open banking's interception script to configure the Jans-Auth Server to configure authentication steps - receive the /authorize endpoint request, redirect to the consent app and return back to the authorization server which finally generates access tokens / id tokens.

### Configuration Prerequisites
* A Janssen Authorization Server installation
* [Person authentication script](https://github.com/JanssenProject/jans-setup/blob/openbank/static/extension/person_authentication/OpenBanking.py)  - included in the default Janssen OpenBanking distribution
* Setting configuration Parameters

## Adding the custom script
1. To add or update custom scripts, you can use either jans-cli or curl. jans-cli in interactive mode, option 13 enables you manage custom scripts. For more info, see the [docs](https://github.com/JanssenProject/home/wiki/Custom-Scripts-using-jans-cli).
1. jans-cli in command line argument mode is more conducive to scripting and automation. To display the available operations for custom scripts, use config-cli.py --info CustomScripts. See the [docs](../jans-cli.md) for more info.
1. To use `curl` see these [docs](../curl.md)

!!! Note
    You can normally find `jans-cli.py` in the `/opt/jans/jans-cli/` folder. 

## Configuring URL for consent app
The person authentication custom script will use configuration parameters like redirect_url which signifies the URL of the consent app.

|	Property	|	Description	|	Example		|
|-----------------------|---------------|-----------------------|
|redirect_url           |Redirect to the consent app | https://bank-op.gluu.org/oxauth/authorize.htm?scope=openid....|
|tpp_jwks_url           |Used for encoding jwt | https://keystore......org.uk/00333H0000@#FE7dQAG/0014H00001lFE7dQAG.jwks|

**Steps to add / edit / delete configuration parameters**
1. Place a [JSON file](https://github.com/JanssenProject/jans-setup/blob/openbank/static/extension/person_authentication/personauthentication.json) containing the above configuration parameters and the [custom script](https://github.com/JanssenProject/jans-setup/blob/openbank/static/extension/person_authentication/OpenBanking.py) in a folder. 

1. From this folder, run the following command: 

```
python3 jans-cli-linux-amd64.pyz --operation-id post-config-scripts --data /personauthentication.json \
--cert-file jans_cli_client.crt --key-file jans_cli_client.key
```

### Methods
You can get the [Person Authentication script](https://github.com/JanssenProject/jans-setup/blob/openbank/static/extension/person_authentication/OpenBanking.py)

Following are the ***mandatory*** functions which need to be implemented in order to perform authentication - 

1. Initialization and mandatory methods

    ```python3
    class PersonAuthentication(PersonAuthenticationType):
        def __init__(self, currentTimeMillis):
            self.currentTimeMillis = currentTimeMillis   

        def init(self, customScript, configurationAttributes):
        
            if (not configurationAttributes.containsKey("tpp_jwks_url")):
	            print "Person Authentication. Initialization. Property tpp_jwks_url is not specified"
	            return False
            else: 
        	    self.tpp_jwks_url = configurationAttributes.get("tpp_jwks_url").getValue2() 
            .....
            return True   

        def destroy(self, configurationAttributes):
            return True

        def getApiVersion(self):
            return 11

        def getAuthenticationMethodClaims(self, requestParameters):
            return None
    
        def isValidAuthenticationMethod(self, usageType, configurationAttributes):
            return True

        def getAlternativeAuthenticationMethod(self, usageType, configurationAttributes):
            return None

        def logout(self, configurationAttributes, requestParameters):
            return True
    ```
    
2. The first function which is invoked in a person authentication script is getPageForStep. Typically we use it to present a login screen to the user. Now that we want to re-direct to a 3rd party for login and consent, we should ensure that ``` getPageForStep ``` returns ``` /redirect.xhtml ```. The ``` redirect.xhtml ``` is responsible for taking the flow to step 3.

    ```python3
    def getPageForStep(self, configurationAttributes, step):
            print "Person Authentication. getPageForStep... %s" % step
            if step == 1:
                 return "/redirect.xhtml"
            return ""
    ```
    
3. PrepareForStep (Redirecting to third party): This is where we put the business logic for redirection to a 3rd party consent app. Parse request object, build URL of 3rd party of consent app and redirect to that app.

    ```python3
     def prepareForStep(self, configurationAttributes, requestParameters, step):
        
            jwkSet = JWKSet.load( URL(self.tpp_jwks_url));
            signedRequest = ServerUtil.getFirstValue(requestParameters, "request")
            for key in jwkSet.getKeys() : 
                result = self.isSignatureValid(signedRequest, key)
                if (result == True):
                    signedJWT = SignedJWT.parse(signedRequest)
                    claims = JSONObject(signedJWT.getJWTClaimsSet().getClaims().get("claims"))
                    print "Person Authentication. claims : %s " % claims.toString()
                    id_token = claims.get("id_token");
                    openbanking_intent_id = id_token.getJSONObject("openbanking_intent_id").getString("value")
                    print "Person Authentication. openbanking_intent_id %s " % openbanking_intent_id

                    redirectURL = self.redirect_url+"&state="+UUID.randomUUID().toString()+"&intent_id="+openbanking_intent_id
                    identity = CdiUtil.bean(Identity)
                    identity.setWorkingParameter("openbanking_intent_id",openbanking_intent_id)
                    print "OpenBanking. Redirecting to ... %s " % redirectURL 

                    # redirection to a third party app
                    facesService = CdiUtil.bean(FacesService)
                    facesService.redirectToExternalURL(redirectURL)
                    return True
            print "Person Authentication. Call to Jans-auth server's /authorize endpoint should contain openbanking_intent_id as an encoded JWT"
            return False

    ```

3. Authenticate method:
At this stage, lets treat the consent app as a black box. After the consent flow, the consent app should return to https://<hostname>/jans-auth/postlogin.htm. This takes us to the authenticate() method in the Person Authentication Script

This is what needs to be done here - 
* To access request parameters use:

  ```python3  
  signedRequest = ServerUtil.getFirstValue(requestParameters, "request") 
  ```
    
* Add claims to session (those which you hope to find in access_token, refresh_token and id_token. The Introspection and UpdateToken script reads these session variables) 

  ```python3
  sessionIdService = CdiUtil.bean(SessionIdService)
  sessionId = sessionIdService.getSessionId() # fetch from persistence
  sessionId.getSessionAttributes().put("openbanking_intent_id",openbanking_intent_id )
  sessionId.getSessionAttributes().put("acr_ob", acr_ob )
  ```

4. Miscellaneous mandatory methods: 

   Signifies that this Person Authentication has only 1 step. Typically wherever 2FA methods are involved, there will be 2 steps.
    
   ```python3
   def getCountAuthenticationSteps(self, configurationAttributes):
       return 1
   ```

   By setting the step number, this method is used to restart a step in the event of something.

   ```python3
   def getNextStep(self, configurationAttributes, requestParameters, step):
       return -1
   ``` 

5. All **session variables** should be returned from this method

   ```python3
   def getExtraParametersForStep(self, configurationAttributes, step):
       return Arrays.asList("openbanking_intent_id", "acr_ob")
   ```

