# Managing scripts with CURL
 
## Prerequisites

- Gluu open banking distribution
- client-id
- client-secret
- client certificate
- client key

### Get the client-id and client-secret

Get a client and its associated password. Here, we will use the client id and secret created for config-api. In the commands below, please change the namespace to where Gluu was installed.
       
    ```bash
    TESTCLIENT=$(kubectl get cm cn -o json -n <gluu-namespace> | grep '"jca_client_id":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]')
    TESTCLIENTSECRET=$(kubectl get secret cn -o json -n <gluu-namespace> | grep '"jca_client_pw":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d)
    ```

### curl operations
    
1.  The curl commands to list, add, or update custom script requires a token, so first call the token end point to get the token using:

    ```bash
    curl -u $TESTCLIENT:$TESTCLIENTSECRET https://<FQDN>/jans-auth/restv1/token -d  "grant_type=client_credentials&scope=https://jans.io/oauth/config/scripts.readonly" --cert client.pem --key client.key
    ```
    
    Example:
    
    ```bash
    curl -u '1801.bdfae945-b31d-4d60-8e47-16518153215:rjHoLfjfsv2G2qzGEasd1651813aIXvCi61NU' https://bank.gluu.org/jans-auth/restv1/token -d  "grant_type=client_credentials&scope=https://jans.io/oauth/config/scripts.readonly" --cert apr22.pem --key apr22.key
    {"access_token":"ad34ac-8f2d-4bec-aed3-343adasda2","scope":"https://jans.io/oauth/config/scripts.readonly","token_type":"bearer","expires_in":299}
    ```
    
1. Save the `access_token` for use in subsequent commands.
    
1.  Use different scope values as per the requirement as:

    1.  View scripts information: https://jans.io/oauth/config/scripts.readonly

    1.  Manage scripts related information: https://jans.io/oauth/config/scripts.write

    1.  Delete scripts related information: https://jans.io/oauth/config/scripts.delete

1.  Use the obtained access token to perform further operations on custom scripts as given in subsequent text:

    1.  Use the following command to display details of all the available custom scripts:

        ```bash
        curl -X GET https://<FQDN>/jans-config-api/api/v1/config/scripts -H "Accept: application/json" -H "Authorization:Bearer <access_token>" -H "Content-Type: application/json"
        ```
        
        Example:
        
        ```bash
        curl -X GET https://bank.gluu.org/jans-config-api/api/v1/config/scripts -H "Accept: application/json" -H "Authorization:Bearer ad34ac-8f2d-4bec-aed3-343adasda2" -H "Content-Type: application/json"
        ```     
               
    1.  The following command will add a new custom script (Obtain token with write scope) and if it is successful it will display the added script in JSON format. The scriptformat.json file has script details according to the custom script schema. It should have the entire script inside the scriptformat.json as a string value under script field. To convert a multiline script into a string requires converting newlines into \n. So curl is not a suitable choice for adding new script, jans-cli is better options.    
    
        ```bash
        curl -X POST "https://<FQDN>/jans-config-api/api/v1/config/scripts" -H  "Accept: application/json" -H "Authorization:Bearer <access_token>" -H "Content-Type: application/json" --data @/home/user/scriptformat.json
        ```
        
        Example:
        
        ```bash
        curl -X POST "https://bank.gluu.org/jans-config-api/api/v1/config/scripts" -H  "Accept: application/json" -H "Authorization:Bearer ad34ac-8f2d-4bec-aed3-343adasda2" -H "Content-Type: application/json" --data @/home/user/scriptformat.json
        ```
