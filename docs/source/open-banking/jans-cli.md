### Introduction and underlying mechanism
Jans-cli is a command line interface to configure the Janssen software and it supports both interactive and command-line options for configuration. 

Jans-cli calls the [Jans Config API](https://github.com/JanssenProject/jans-config-api) to perform various operations. During Janssen installation, the installer creates a client to use Jans Config API. Jans-cli uses this client to call Jans Config API. The client ID (id) and the encrypted client secret is stored in the config.ini file of jans-cli. 

### Quick overview of supported operations 
  
Jans-cli supports the following six operations on custom scripts: 

1. `get-config-scripts`, gets a list of custom scripts.
2. `post-config-scripts`, adds a new custom script.
3. `put-config-scripts`, updates a custom script.
4. `get-config-scripts-by-type`, requires an argument `--url-suffix TYPE: ______`.  You can specify the following types: PERSON_AUTHENTICATION, INTROSPECTION, RESOURCE_OWNER_PASSWORD_CREDENTIALS, APPLICATION_SESSION, CACHE_REFRESH, UPDATE_USER, USER_REGISTRATION, CLIENT_REGISTRATION, ID_GENERATOR, UMA_RPT_POLICY, UMA_RPT_CLAIMS, UMA_CLAIMS_GATHERING, CONSENT_GATHERING, DYNAMIC_SCOPE, SPONTANEOUS_SCOPE, END_SESSION, POST_AUTHN, SCIM, CIBA_END_USER_NOTIFICATION, PERSISTENCE_EXTENSION, IDP, or UPDATE_TOKEN. 
5. `get-config-scripts-by-inum`, requires an argument `--url-suffix inum: _____`
6. `delete-config-scripts-by-inum`, requires an argument `--url-suffix inum: _____`

### Using jans-cli

1.  Download [`jans-cli.pyz`](https://github.com/JanssenProject/jans-cli/releases). This package can be built [manually](https://github.com/JanssenProject/jans-cli#build-jans-clipyz-manually).

1.  Get a client and its associated password. Here, we will use the client id and secret created for config-api.
       
    ```bash
    TESTCLIENT=$(kubectl get cm cn -o json -n gluu | grep '"jca_client_id":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]')
    TESTCLIENTSECRET=$(kubectl get secret cn -o json -n gluu | grep '"jca_client_pw":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d)
    ```
                
1.  Run the jans-cli in interactive mode and try it out: 
       
    ```bash
    python3 jans-cli-linux-amd64.pyz --host <FQDN> --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --CC jans_cli_client.crt --CK jans_cli_client.key
    ```

### Overview
    
The post-config-scripts and put-config-scripts require various details about the scripts. The following command gives the basic schema of the custom scripts to pass to these operations. 

```bash
python3 jans-cli-linux-amd64.pyz --host <FQDN> --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --schema /components/schemas/CustomScript 
```

The output of the above command will be similar as: 

```json
{
  "dn": null,
  "inum": null,
  "name": "string",
  "aliases": [],
  "description": null,
  "script": "string",
  "scriptType": "IDP",
  "programmingLanguage": "PYTHON",
  "moduleProperties": {
    "value1": null,
    "value2": null,
    "description": null
  },
  "configurationProperties": {
    "value1": null,
    "value2": null,
    "description": null,
    "hide": true
  },
  "level": "integer",
  "revision": 0,
  "enabled": false,
  "scriptError": {
    "raisedAt": null,
    "stackTrace": null
  },
  "modified": false,
  "internal": false
}
```

To add or modify a script first, we need to create the script's python file (e.g. /tmp/sample.py) and then create a JSON file by following the above schema and update the fields as :

/tmp/sample.json
```json
{
  "name": "mySampleScript",
  "aliases": null,
  "description": "This is a sample script",
  "script": "_file /tmp/sample.py",
  "scriptType": "PERSON_AUTHENTICATION",
  "programmingLanguage": "PYTHON",
  "moduleProperties": [
    {
      "value1": "mayvalue1",
      "value2": "myvalues2",
      "description": "description for property"
    }
  ],
  "configurationProperties": null,
  "level": 1,
  "revision": 0,
  "enabled": false,
  "scriptError": null,
  "modified": false,
  "internal": false
}
```

In next few commands, `jans_cli_client.crt`, `jans_cli_client.key` are the certificate and key files respectively for MTLS. We need to pass this certificate, key as the token endpoint is under MTLS and jans-cli obtains an appropriate token before performing the operation. You will replace these with your actual certificate and key files. 

### Add a new custom script, update and delete existing custom script

The following command will add a new script with details given in /tmp/sampleadd.json file. __The jans-cli will generate a unique inum of this new script if we skip inum in the json file.__
 
```bash 
python3 jans-cli-linux-amd64.pyz --host <FQDN> --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --operation-id post-config-scripts --data /tmp/sampleadd.json \
--CC jans_cli_client.crt --CK jans_cli_client.key
```

The following command will modify/update the existing script with details given in /tmp/samplemodify.json file. __Remember to set inum field in samplemodify.json to the inum of the script to update.__ 

```bash 
python3 jans-cli-linux-amd64.pyz --host <FQDN> --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --operation-id put-config-scripts --data /tmp/samplemodify.json \
--CC jans_cli_client.crt --CK jans_cli_client.key
```

To delete a custom script by its inum, use the following command: 

```bash
python3 jans-cli-linux-amd64.pyz --host <FQDN> --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --operation-id delete-config-scripts-by-inum --url-suffix inum:HKM-TEST \
--CC jans_cli_client.crt --CK jans_cli_client.key
```

### Print details of existing custom scripts

These commands to print the details are important, as using them we can get the inum of these scripts which is required to perform update or delete operation.

1.  The following command will display the details of all the existing custom scripts. This will be helpful to get the inum of scripts to perform the update and delete operation.
 
    ```bash
    python3 jans-cli-linux-amd64.pyz --host <FQDN> --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --operation-id get-config-scripts --CC jans_cli_client.crt --CK jans_cli_client.key
    ```

1.  Following command displays the details of selected custom script (by inum). 

    ```bash 
    python3 jans-cli-linux-amd64.pyz --host <FQDN> --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --operation-id get-config-scripts-by-inum --url-suffix inum:_____  \
    --CC jans_cli_client.crt --CK jans_cli_client.key
    ```

1.  Use the following command to display the details of existing custom scripts of a given type (for example: INTROSPECTION).
 
    ```bash
    python3 jans-cli-linux-amd64.pyz --host <FQDN> --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --operation-id get-config-scripts-by-type --url-suffix type:INTROSPECTION \
    --CC jans_cli_client.crt --CK jans_cli_client.key
    ```

