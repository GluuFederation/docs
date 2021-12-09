# Installation Guide

## Cloud Native Distribution


## Getting Started with Kubernetes


## System Requirements for cloud deployments

!!!note
    For local deployments like `minikube` and `microk8s`  or cloud installations for demoing Gluu may set the resources to the minimum and hence can have `8GB RAM`, `4 CPU`, and `50GB disk` in total to run all services.
  
Please calculate the minimum required resources as per services deployed. The following table contains default recommended resources to start with. Depending on the use of each service the resources may be increased or decreased. 

|Service           | CPU Unit   |    RAM      |   Disk Space     | Processor Type | Required                                    |
|------------------|------------|-------------|------------------|----------------|---------------------------------------------|
|Auth-server            | 2.5        |    2.5GB    |   N/A            |  64 Bit        | Yes                                         |
|config - job      | 0.5        |    0.5GB    |   N/A            |  64 Bit        | Yes on fresh installs                       |
|persistence - job | 0.5        |    0.5GB    |   N/A            |  64 Bit        | Yes on fresh installs                       |
|nginx             | 1          |    1GB      |   N/A            |  64 Bit        | Yes if not ALB or Istio                             |


## Configure cloud or local kubernetes cluster with database:

=== "AWS"
    ### Amazon Web Services (AWS) - EKS
      
    #### Setup Cluster
    
    -  Follow this [guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
     to install a cluster with worker nodes. Please make sure that you have all the `IAM` policies for the AWS user that will be creating the cluster and volumes.
    
    #### Requirements
    
    -   The above guide should also walk you through installing `kubectl` , `aws-iam-authenticator` and `aws cli` on the VM you will be managing your cluster and nodes from. Check to make sure.
    
            aws-iam-authenticator help
            aws-cli
            kubectl version
    
    - **Optional[alpha]:** If using Istio please [install](https://istio.io/latest/docs/setup/install/standalone-operator/) it prior to installing Gluu. You may choose to use any installation method Istio supports. If you have insalled istio ingress , a loadbalancer will have been created. Please save the address of loadblancer for use later during installation.
      
    ### Amazon Aurora
    
    [Amazon Aurora](https://aws.amazon.com/rds/aurora/?aurora-whats-new.sort-by=item.additionalFields.postDateTime&aurora-whats-new.sort-order=desc) is a MySQL and PostgreSQL-compatible relational database built for the cloud, that combines the performance and availability of traditional enterprise databases with the simplicity and cost-effectiveness of open source databases. Gluu fully supports Amazon Aurora, and recommends it in production.
     
    1.  Create an Amazon Aurora database with MySQL compatibility version >= `Aurora(MySQL 5.7) 2.07.1` and capacity type `Serverless`. Make sure the EKS cluster can reach the database endpoint. You may choose to use the same VPC as the EKS cluster. Save the master user, master password, and initial database name for use in Gluus helm chart.
    
    1.  Inject the Aurora endpoint, master user, master password, and initial database name for use in Gluus helm chart. 
 
        |Helm values configuration                | Description                                                                     | default      |
        |-----------------------------------------|---------------------------------------------------------------------------------|--------------|
        |config.configmap.cnSqlDbHost             | Aurora database endpoint i.e `gluu.cluster-xxxxxxx.eu-central.rds.amazonaws.com`|    empty     |
        |config.configmap.cnSqlDbPort             | Aurora database port                                                            |    `3306`    |
        |config.configmap.cnSqlDbName             | Aurora initial database name                                                    |    `jans`    |
        |config.configmap.cnSqlDbUser             | Aurora master user                                                              |    `jans`    |
        |config.configmap.cnSqldbUserPassword     | Aurora master password                                                          |   `Test1234#`|

=== "Quick start with Microk8s"
    ### MicroK8s
    
    #### Requirements
    
    1.  Create a fresh Ubuntu 20.04 on AWS.
    
    1.  Run the following command: 
       
        ```bash
        sudo su -
        wget https://raw.githubusercontent.com/GluuFederation/cloud-native-edition/master/automation/startopenabankingdemo.sh && chmod u+x startopenabankingdemo.sh && ./startopenabankingdemo.sh  
        ```
    
    1.  [Map](#non-registered-fqdn) your vm ip to the fqdn `demoexample.gluu.org`
      
## Install Gluu using Helm

1.  **Optional if not using istio ingress:** Install [nginx-ingress](https://github.com/kubernetes/ingress-nginx) Helm [Chart](https://github.com/helm/charts/tree/master/stable/nginx-ingress).

    ```bash
    kubectl create ns <nginx-namespace>
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm install <nginx-release-name> ingress-nginx/ingress-nginx --namespace=<nginx-namespace>
    ```

1.  Copy the [values.yaml](#helm-valuesyaml) below into a file named `override-values.yaml`

1.  Modify the values to fit the deployment. This is the time to inject your database connection parameters. You will find the file marked where you need to change the values.

1.  Create a namespace and install:    
   
    ```bash
    kubectl create ns gluu
    helm repo add gluu https://gluufederation.github.io/cloud-native-edition/pygluu/kubernetes/templates/helm
    helm repo update
    helm install <release-name> gluu/gluu -n <namespace> -f override-values.yaml --version=5.0.0
    ```
          
## Non registered FQDN      

If the provided FQDN for Gluu is not globally resolvable map Gluus FQDN at `/etc/hosts` file  to the IP of the lb or microk8s vm as shown below.

  ```bash
  ##
  # Host Database
  #
  # localhost is used to configure the loopback interface
  # when the system is booting.  Do not change this entry.
  ##
  192.168.99.100	demo.openbanking.org # IP and example domain
  127.0.0.1	localhost
  255.255.255.255	broadcasthost
  ::1             localhost
  ```

## Enabling mTLS in ingress-nginx 
         
1.  Please note that enabling the following annotations in the values.yaml will enable  [client certificate authentication](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#client-certificate-authentication). Uncomment the following from the helm charts [`override-values.yaml`](#helm-valuesyaml)

    ```yaml
        additionalAnnotations:
          # Enable client certificate authentication. Keep this optional. We force it on the path level for /token and /register endpoints.
          nginx.ingress.kubernetes.io/auth-tls-verify-client: "optional"
          # Create the secret containing the trusted ca certificates
          nginx.ingress.kubernetes.io/auth-tls-secret: "gluu/tls-ob-ca-certificates"
          # Specify the verification depth in the client certificates chain
          nginx.ingress.kubernetes.io/auth-tls-verify-depth: "1"
          # Specify if certificates are passed to upstream server
          nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream: "true"
    ```
    
1.  Set `nginx-ingress.ingress.authServerProtectedToken` and `nginx-ingress.ingress.authServerProtectedRegister` in the helm charts [`override-values.yaml`](#helm-valuesyaml) to `true`.

1.  Create a secret containing the OB CA certificates (issuing, root, and signing CAs) and the OB AS transport crt. For more information read [here](https://kubernetes.github.io/ingress-nginx/examples/auth/client-certs/).

    ```bash
    cat web_https_ca.crt issuingca.crt rootca.crt signingca.crt >> ca.crt
    kubectl create secret generic tls-ob-ca-certificates -n gluu --from-file=tls.crt=web_https.crt --from-file=tls.key=web_https.key --from-file=ca.crt=ca.crt
    ```
        
1.  Inject OBIE signed certs, keys and uri: 

    1.  When using OBIE signed certificates and keys, there are  many objects that can be injected. The certificate signing pem file i.e `obsigning.pem`, the signing key i.e `obsigning-oajsdij8927123.key`, the certificate transport pem file i.e `obtransport.pem`, the transport key i.e `obtransport-sdfe4234234.key`, the transport truststore p12 i.e `ob-transport-truststore.p12`, and the jwks uri `https://mykeystore.openbanking.wow/xxxxx/xxxxx.jwks`.
    
    1.  base64 encrypt all `.pem` and `.key` files as they will be injected as base64 strings inside the helm [`override-values.yaml`](#helm-valuesyaml).
    
        ```bash
        cat obsigning.pem | base64 | tr -d '\n' > obsigningbase64.pem
        cat obsigning-oajsdij8927123.key | base64 | tr -d '\n' > obsigningbase64.key
        cat obtransport.pem | base64 | tr -d '\n' > obtransportbase64.pem
        cat obtransport-sdfe4234234.key | base64 | tr -d '\n' > obtransportbase64.key
        ```
        
    1.  Copy the base64 string in `obsigningbase64.pem` into the helm chart [`override-values.yaml`](#helm-valuesyaml) at `global.cnObExtSigningJwksCrt`
    
    1.  Copy the base64 string in `obsigningbase64.key` into the helm chart [`override-values.yaml`](#helm-valuesyaml)  at `global.cnObExtSigningJwksKey`

    1.  Inject the base64 string passphrase of `obsigningbase64.key` into the helm chart [`override-values.yaml`](#helm-valuesyaml)  at `global.cnObExtSigningJwksKeyPassPhrase`

    1.  Copy the base64 string in `obtransportbase64.pem` into the helm chart [`override-values.yaml`](#helm-valuesyaml) at `global.cnObTransportCrt`
    
    1.  Copy the base64 string in `obtransportbase64.key` into the helm chart [`override-values.yaml`](#helm-valuesyaml)  at `global.cnObTransportKey`
    
    1.  Inject the base64 string passphrase of `obtransportbase64.key` into the helm chart [`override-values.yaml`](#helm-valuesyaml)  at `global.cnObTransportKeyPassPhrase`
    
    1.  Generate your transport truststore or convert it to `.p12` format. Please name it as `ob-transport-truststore.p12` 
    
        ```bash
        cat obissuingca.pem obrootca.pem obsigningca.pem > transport-truststore.crt
        keytool -importcert -file transport-truststore.crt -keystore ob-transport-truststore.p12 -alias obkeystore
        ```
        
    1.  base64 encrypt the `ob-transport-truststore.p12`
    
        ```bash
        cat ob-transport-truststore.p12 | base64 | tr -d '\n' > obtransporttruststorebase64.pem
        ```
            
    1.  Copy the base64 string in `obtransporttruststorebase64.pem` into the helm chart [`override-values.yaml`](#helm-valuesyaml) at `global.cnObTransportTrustStore`
        
    1.  Add the jwks uri to the helm chart [`override-values.yaml`](#helm-valuesyaml) at `global.cnObExtSigningJwksUri`
    
    1.  Add the kid as the alias for the JKS used for the OB AS external signing crt. This is a kid value.Used in SSA Validation, kid used while encoding a JWT sent to token URL i.e XkwIzWy44xWSlcWnMiEc8iq9s2G. This kid value should exist inside the jwks uri endpoint.

    1.  Specify the signing key that will be used by the AS [`override-values.yaml`](#helm-valuesyaml) at `global.cnObStaticSigningKeyKid`.
    
    |Helm values configuration           | Description                                                                                                                      | default      | Associated files created in auth-server pod at `/etc/certs`                                            |
    |------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|--------------|--------------------------------------------------------------------------------------------------------|
    |global.cnObExtSigningJwksUri        | external signing jwks uri string                                                                                                 |    empty     | `obextjwksuri.crt` parsed from the URI and added to the JVM                                            |
    |global.cnObExtSigningJwksCrt        | Used in SSA Validation. base64 string for the external signing jwks crt. Activated when .global.cnObExtSigningJwksUri is set     |    empty     | `ob-ext-signing.crt`                                                                                   |
    |global.cnObExtSigningJwksKey        | Used in SSA Validation. base64 string for the external signing jwks key . Activated when .global.cnObExtSigningJwksUri is set    |    empty     | `ob-ext-signing.key`. With the above crt `ob-ext-signing.jks`, and `ob-ext-signing.pkcs12` get created.|
    |global.cnObExtSigningJwksKeyPassPhrase | Needed if global.cnObExtSigningJwksKey has a passphrase . Activated when .global.cnObExtSigningJwksUri is set                    |    empty     | `ob-ext-signing.pin`.                                                                                  |
    |global.cnObExtSigningAlias          | This is a kid value.Used in SSA Validation, kid used while encoding a JWT sent to token URL i.e XkwIzWy44xWSlcWnMiEc8iq9s2G      |    empty     |  Alias of the entry inside the keystore `ob-ext-signing.jks`.                                          |
    |global.cnObStaticSigningKeyKid      | This is a kid value.Used to force the AS to use a specific signing key i.e XkwIzWy44xWSlcWnMiEc8iq9s2G                           |    empty     |  Alias of the entry inside the keystore `ob-ext-signing.jks`.                                          |                            
    |global.cnObTransportCrt             | Used in SSA Validation. base64 string for the transport crt. Activated when .global.cnObExtSigningJwksUri is set                 |    empty     | `ob-transport.crt`                                                                                     |
    |global.cnObTransportKey             | Used in SSA Validation. base64 string for the transport key. Activated when .global.cnObExtSigningJwksUri is set                 |    empty     | `ob-transport.key`. With the above crt `ob-transport.jks`, and `ob-transport.pkcs12` get created.      |
    |global.cnObTransportKeyPassPhrase   | Needed if global.cnObTransportKey has a passphrase . Activated when .global.cnObExtSigningJwksUri is set                         |    empty     | `ob-transport.pin`.                                                                                    |        
    |global.cnObTransportTrustStore      | Used in SSA Validation. base64 string for the transport truststore crt. Activated when .global.cnObExtSigningJwksUri is set      |    empty     | `ob-transport-truststore.p12`                                                                                    |
        
    Please note that the password for the keystores created can be fetched by executing the following command:
     
     ```bash
     AUTH_JKS_PASS=$(kubectl get secret cn -o json -n gluu | grep '"auth_openid_jks_pass":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d)
     ```
    The above password is needed in custom scripts such as in [client registeration](https://gluu.org/docs/openbanking/scripts/client-registration/#configuring-keys-certificates-and-ssa-validation-endpoints).

## Changing the  signing key kid for the AS dynamically

Specify a the signing key that will be used by the AS:

1.  Get a client and its associated password. Here, we will use the client id and secret created for config-api.
   
    ```bash
    TESTCLIENT=$(kubectl get cm cn -o json -n gluu | grep '"jca_client_id":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]')
    TESTCLIENTSECRET=$(kubectl get secret cn -o json -n gluu | grep '"jca_client_pw":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d)
    ```
    
1.  Get a token , here the crt and key used need to be a crt and key that can pass mTLS:

    ```bash
    curl -k -u $TESTCLIENT:$TESTCLIENTSECRET https://<FQDN>/jans-auth/restv1/token -d "grant_type=client_credentials&scope=https://jans.io/oauth/jans-auth-server/config/properties.write" --cert mtls.pem --key mtls.key
    ```
    
1.  Add the entry `staticKid` to force the AS to use a specific signing key. Please modify `XhCYDfFM7UFXHfykNaLk1aLCnZM` to the kid to be used:          

    ```bash
    curl -k -X PATCH "https://<FQDN>/jans-config-api/api/v1/jans-auth-server/config" -H  "accept: application/json" -H  "Content-Type: application/json-patch+json" -H "Authorization:Bearer 170e8412-1d55-4b19-ssss-8fcdeaafb954" -d "[{\"op\":\"add\",\"path\":\"/staticKid\",\"value\":\"XhCYDfFM7UFXHfykNaLk1aLCnZM\"}]"
    ```

1.  Preform a rolling restart for the auth-server and config-api

    ```bash
    kubectl rollout restart deployment <gluu-relase-name>-auth-server -n <gluu-namespace>
    kubectl rollout restart deployment <gluu-relase-name>-config-api -n <gluu-namespace>
    #kubectl rollout restart deployment gluu-auth-server -n gluu
    ```
        
## Enable https.

| certificates and keys of interest in https | Notes                                      |
| ----------------------------------------  | ------------------------------------------ |
| web_https.crt         | (nginx) web server certificate. This is commonly referred to as server.crt |
| web_https.key         | (nginx) web server key. This is commonly referred to as server.key |
| web_https.csr         | (nginx) web server certificate signing request. This is commonly referred to as server.csr |
| web_https_ca.crt      | Certificate authority certificate that signed/signs the web server certificate. |
| web_https_ca.key      | Certificate authority key that signed/signs the web server certificate.|

Please note you might be using cert-manager here by specifying your issuer as an annotation at [`nginx-ingress.ingress.additionalAnnotations`](#helm-valuesyaml) . By default self-signed certs for https get automatically generated and used. 

## Uninstalling the Chart

To uninstall/delete `my-release` deployment:

`helm delete <my-release>`

If during installation the release was not defined, release name is checked by running `$ helm ls` then deleted using the previous command and the default release name.

## Loading web https certs and keys.

| certificates and keys of interest for https | Notes                                      |
| ----------------------------------------  | ------------------------------------------ |
| web_https.crt         | (nginx) web server certificate. This is commonly referred to as server.crt |
| web_https.key         | (nginx) web server key. This is commonly referred to as server.key |
| web_https.csr         | (nginx) web server certificate signing request. This is commonly referred to as server.csr |
| web_https_ca.crt                | Certificate authority certificate that signed/signs the web server certificate. |
| web_https_ca.key                | Certificate authority key that signed/signs the web server certificate.|
    

!!! Note
    This will load `web_https.crt`, `web_https.key`, `web_https.csr`, `web_https_ca.crt`, and `web_https_ca.key` to `/etc/certs`. This step is important in order for mTLS to fully work as nginx-ingress will pass the client certificate down to the auth-server and the auth-server will validate the client certificate.
    
1.  Create a secret with `web_https.crt`, `web_https.key`, `web_https.csr`, `web_https_ca.crt`, and `web_https_ca.key`. Note that this may already exist in your deployment.

    ```bash
        kubectl create secret generic web-cert-key --from-file=web_https.crt --from-file=web_https.key --from-file=web_https.csr --from-file=ca.crt=web_https_ca.crt --from-file=ca.key=web_https_ca.key -n <gluu-namespace> 
    ```
    
1.  Create a file named `load-web-key-rotation.yaml` with the following contents :
                   
    ```yaml
    # License terms and conditions for Gluu Cloud Native Edition:
    # https://www.apache.org/licenses/LICENSE-2.0
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: load-web-key-rotation
    spec:
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"                  
        spec:
          restartPolicy: Never
          volumes:
          - name: web-cert
            secret:
              secretName: web-cert-key
              items:
                - key: web_https.crt
                  path: web_https.crt
          - name: web-key
            secret:
              secretName: web-cert-key
              items:
                - key: web_https.key
                  path: web_https.key
          - name: web-csr
            secret:
              secretName: web-cert-key
              items:
                - key: web_https.csr
                  path: web_https.csr
          - name: web-ca-cert
            secret:
              secretName: web-cert-key
              items:
                - key: ca.crt
                  path: ca.crt
          - name: web-ca-key
            secret:
              secretName: web-cert-key
              items:
                - key: ca.key
                  path: ca.key                              
          containers:
            - name: load-web-key-rotation
              image: janssenproject/certmanager:1.0.0_b11
              envFrom:
              - configMapRef:
                  name: gluu-config-cm  #This may be different in your Helm setup
              volumeMounts:
                - name: web-cert
                  mountPath: /etc/certs/web_https.crt
                  subPath: web_https.crt
                - name: web-key
                  mountPath: /etc/certs/web_https.key
                  subPath: web_https.key
                - name: web-csr
                  mountPath: /etc/certs/web_https.csr
                  subPath: web_https.csr
                - name: web-ca-cert
                  mountPath: /etc/certs/ca.crt
                  subPath: ca.crt
                - name: web-ca-key
                  mountPath: /etc/certs/ca.key
                  subPath: ca.key   
              args: ["patch", "web", "--opts", "source:from-files"]
    ```
    
1.  Apply job

    ```bash
        kubectl apply -f load-web-key-rotation.yaml -n <gluu-namespace>
    ```

### Example using self signed certs and keys:

1.  Follow the above [steps](#enabling-mtls-in-ingress-nginx) to enable the annotations and protected endpoints before running the [`helm install`](#install-gluu-using-helm) command. 

1.  Wait for services to be in a running state.

1.  Get self signed certs and generate client crt and key. This assumes the namespace Gluu has been installed in is `gluu`.

    ```bash
    mkdir certs
    cd certs
    kubectl get secret cn -o json -n gluu | grep '"ssl_ca_cert":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d > web_https_ca.crt
    kubectl get secret cn -o json -n gluu | grep '"ssl_ca_key":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d > web_https_ca.key
    kubectl get secret cn -o json -n gluu | grep '"ssl_cert":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d > web_https.crt
    kubectl get secret cn -o json -n gluu | grep '"ssl_key":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d > web_https.key
    openssl req -new -newkey rsa:4096 -keyout jans_cli_client.key -out jans_cli_client.csr -nodes -subj '/CN=Openbanking'
    openssl x509 -req -sha256 -days 365 -in jans_cli_client.csr -CA ca.crt -CAkey ca.key -set_serial 02 -out jans_cli_client.crt
    kubectl create secret generic ca-secret -n gluu --from-file=tls.crt=server.crt --from-file=tls.key=server.key --from-file=ca.crt=ca.crt
    cd ..
    ```

1.  Try curling a protected endpoint. 

    1.  Get a client and its associated password. Here, we will use the client id and secret created for config-api.
       
        ```bash
        TESTCLIENT=$(kubectl get cm cn -o json -n gluu | grep '"jca_client_id":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]')
        TESTCLIENTSECRET=$(kubectl get secret cn -o json -n gluu | grep '"jca_client_pw":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d)
        ```
    
    1.  Curl the protected `/token` endpoint.
    
        ```bash
        curl -X POST -k --cert jans_cli_client.crt --key jans_cli_client.key -u $TESTCLIENT:$TESTCLIENTSECRET https://demo.openbanking.org/jans-auth/restv1/token -d grant_type=client_credentials
        {"access_token":"07688c3e-69ea-403b-a35a-fa3877982c7a","token_type":"bearer","expires_in":299}
        ```
         
1.  Try using the `jans-cli`:

    1.  Download [`jans-cli.pyz`](https://github.com/JanssenProject/jans-cli/releases). This package can be built [manually](https://github.com/JanssenProject/jans-cli#build-jans-clipyz-manually).
        
    1.  Run the jans-cli in interactive mode and try it out: 
       
        ```bash
        python3 jans-cli-linux-amd64.pyz --host demo.openbanking.org --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --cert-file jans_cli_client.crt --key-file jans_cli_client.key -noverify
        ```
           

### Example using self provided certs and keys:

1.  Follow the above [steps](#enabling-mtls-in-ingress-nginx) to enable the annotations and protected endpoints before running the [`helm install`](#install-gluu-using-helm) command. 

1.  Wait for services to be in a running state.

1.  Move all your certs and keys inside one folder called `certs` or any name that is convenient . The necessary certs and keys are highlighted in the [table](#loading-web-https-certs-and-keys). This assumes the namespace Gluu has been installed in is `gluu`.

1.  Follow [instructions](#loading-web-https-certs-and-keys) to rotate all associated certs and keys. This is normally done right after installation. Please note that the fqdn inside the crts and keys must be the same as the one provided during installation.

1.  Move all your certs and keys inside one folder. Generate jans cli client side crt, key and create the secret for nginx ingress. This assumes the namespace Gluu has been installed in is `gluu`.

    ```bash
    cd certs
    openssl req -new -newkey rsa:4096 -keyout jans_cli_client.key -out jans_cli_client.csr -nodes -subj '/CN=Openbanking'
    openssl x509 -req -sha256 -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 02 -out jans_cli_client.crt
    kubectl create secret generic ca-secret -n gluu --from-file=tls.crt=web_https.crt --from-file=tls.key=web_https.key --from-file=ca.crt=ca.crt
    cd ..
    ```

1.  By default secret used for TLS `tls-certificate` is created upon installation. This secret must be updated with with the server cert and key `tls.crt=web_https.crt` and `tls.key=web_https.key`.

    ```bash
    kubectl delete secret tls-certificate -n gluu
    kubectl create secret generic tls-certificate --from-file=tls.crt=server.crt --from-file=tls.key=server.key -n gluu
    ```

1.  Try curling a protected endpoint. 

    1.  Get a client and its associated password. Here, we will use the client id and secret created for config-api.
       
        ```bash
        TESTCLIENT=$(kubectl get cm cn -o json -n gluu | grep '"jca_client_id":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]')
        TESTCLIENTSECRET=$(kubectl get secret cn -o json -n gluu | grep '"jca_client_pw":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d)
        ```
    
    1.  Curl the protected `/token` endpoint.
    
        ```bash
        curl -X POST --cert jans_cli_client.crt --key jans_cli_client.key -u $TESTCLIENT:$TESTCLIENTSECRET https://demo.openbanking.org/jans-auth/restv1/token -d grant_type=client_credentials
        {"access_token":"07688c3e-69ea-403b-a35a-fa3877982c7a","token_type":"bearer","expires_in":299}
        ```

1.  Try using the `jans-cli`:

    1.  Download [`jans-cli.pyz`](https://github.com/JanssenProject/jans-cli/releases). This package can be built [manually](https://github.com/JanssenProject/jans-cli#build-jans-clipyz-manually).
        
    1.  Run the jans-cli in interactive mode and try it out: 
       
        ```bash
        python3 jans-cli-linux-amd64.pyz --host demo.openbanking.org --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET --cert-file jans_cli_client.crt --key-file jans_cli_client.key
        ```

## Using jans-cli

`jans-cli` is a Command Line Interface for Gluu Configuration. It also has menu-driven interface that makes it easier to understand how to use Gluu Server through the Interactive Mode.
          
1.  Download [`jans-cli.pyz`](https://github.com/JanssenProject/jans-cli/releases). This package can be built [manually](https://github.com/JanssenProject/jans-cli#build-jans-clipyz-manually).

1.  Get a client and its associated password. Here, we will use the client id and secret created for config-api.
   
    ```bash
    TESTCLIENT=$(kubectl get cm cn -o json -n gluu | grep '"jca_client_id":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]')
    TESTCLIENTSECRET=$(kubectl get secret cn -o json -n gluu | grep '"jca_client_pw":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' | base64 -d)
    ```
            
1.  Run the jans-cli in interactive mode and try it out: 
   
    ```bash
    python3 jans-cli-linux-amd64.pyz --host demo.openbanking.org --client-id $TESTCLIENT --client_secret $TESTCLIENTSECRET -CC jans_cli_client.crt -CK jans_cli_client.key
    ```

## Adding custom scopes upon installation

1. Download the original scopes file

	```
	wget https://raw.githubusercontent.com/JanssenProject/docker-jans-persistence-loader/master/templates/scopes.ob.ldif
    ```

1. Adjust that file to add the custom scopes needed.

1. Create a configmap to hold the file:

	```
	kubectl create cm custom-scopes -n gluu --from-file=scopes.ob.ldif
	```

1. Inside your override yaml you have the ability to inject additional volumes and volume mounts. Inside the `persistence` key add the following: 

	```yaml
	persistence:
		volumes:
			- name: custom-scopes
				configMap:
					name: custom-scopes
		volumeMounts:
			- name: custom-scopes
				mountPath: "/app/templates/scopes.ob.ldif"
				subPath: scopes.ob.ldif
	```

1. Now you are ready to install with the custom scopes added.

## Helm values.yaml

=== "auth-server"
    | Key | Type | Default | Description |
    |-----|------|---------|-------------|
    | auth-server | object | `{"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","repository":"janssenproject/auth-server","tag":"1.0.0_b11"},"livenessProbe":{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"readinessProbe":{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"2500m","memory":"2500Mi"},"requests":{"cpu":"2500m","memory":"2500Mi"}},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | OAuth Authorization Server, the OpenID Connect Provider, the UMA Authorization Server--this is the main Internet facing component of Gluu. It's the service that returns tokens, JWT's and identity assertions. This service must be Internet facing. |
    | auth-server.dnsConfig | object | `{}` | Add custom dns config |
    | auth-server.dnsPolicy | string | `""` | Add custom dns policy |
    | auth-server.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
    | auth-server.hpa.behavior | object | `{}` | Scaling Policies |
    | auth-server.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
    | auth-server.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
    | auth-server.image.repository | string | `"janssenproject/auth-server"` | Image  to use for deploying. |
    | auth-server.image.tag | string | `"1.0.0_b11"` | Image  tag to use for deploying. |
    | auth-server.livenessProbe | object | `{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the liveness healthcheck for the auth server if needed. |
    | auth-server.livenessProbe.exec | object | `{"command":["python3","/app/scripts/healthcheck.py"]}` | Executes the python3 healthcheck. https://github.com/JanssenProject/docker-jans-auth-server/blob/master/scripts/healthcheck.py |
    | auth-server.readinessProbe | object | `{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5}` | Configure the readiness healthcheck for the auth server if needed. https://github.com/JanssenProject/docker-jans-auth-server/blob/master/scripts/healthcheck.py |
    | auth-server.replicas | int | `1` | Service replica number. |
    | auth-server.resources | object | `{"limits":{"cpu":"2500m","memory":"2500Mi"},"requests":{"cpu":"2500m","memory":"2500Mi"}}` | Resource specs. |
    | auth-server.resources.limits.cpu | string | `"2500m"` | CPU limit. |
    | auth-server.resources.limits.memory | string | `"2500Mi"` | Memory limit. |
    | auth-server.resources.requests.cpu | string | `"2500m"` | CPU request. |
    | auth-server.resources.requests.memory | string | `"2500Mi"` | Memory request. |
    | auth-server.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
    | auth-server.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
    | auth-server.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
    | auth-server.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
    | auth-server.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |

=== "config"
    | Key | Type | Default | Description |
    |-----|------|---------|-------------|
    | config | object | `{"city":"Austin","configmap":{"cnCacheType":"NATIVE_PERSISTENCE","cnConfigGoogleSecretNamePrefix":"gluu","cnConfigGoogleSecretVersionId":"latest","cnConfigKubernetesConfigMap":"cn","cnGoogleProjectId":"google-project-to-save-config-and-secrets-to","cnGoogleSecretManagerPassPhrase":"Test1234#","cnGoogleSecretManagerServiceAccount":"SWFtTm90YVNlcnZpY2VBY2NvdW50Q2hhbmdlTWV0b09uZQo=","cnGoogleSpannerDatabaseId":"","cnGoogleSpannerInstanceId":"","cnJettyRequestHeaderSize":8192,"cnMaxRamPercent":"75.0","cnPassportEnabled":false,"cnRedisSentinelGroup":"","cnRedisSslTruststore":"","cnRedisType":"STANDALONE","cnRedisUrl":"redis.redis.svc.cluster.local:6379","cnRedisUseSsl":false,"cnSamlEnabled":false,"cnSecretGoogleSecretNamePrefix":"gluu","cnSecretGoogleSecretVersionId":"latest","cnSecretKubernetesSecret":"cn","cnSqlDbDialect":"mysql","cnSqlDbHost":"my-release-mysql.default.svc.cluster.local","cnSqlDbName":"jans","cnSqlDbPort":3306,"cnSqlDbTimezone":"UTC","cnSqlDbUser":"jans","cnSqlPasswordFile":"/etc/jans/conf/sql_password","cnSqldbUserPassword":"Test1234#","lbAddr":""},"countryCode":"US","dnsConfig":{},"dnsPolicy":"","email":"support@gluu.org","image":{"repository":"janssenproject/configuration-manager","tag":"1.0.0_b11"},"orgName":"Gluu","redisPassword":"P@assw0rd","resources":{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}},"state":"TX","usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Configuration parameters for setup and initial configuration secret and config layers used by Gluu services. |
    | config.city | string | `"Austin"` | City. Used for certificate creation. |
    | config.configmap.cnCacheType | string | `"NATIVE_PERSISTENCE"` | Cache type. `NATIVE_PERSISTENCE`, `REDIS`. or `IN_MEMORY`. Defaults to `NATIVE_PERSISTENCE` . |
    | config.configmap.cnConfigKubernetesConfigMap | string | `"cn"` | The name of the Kubernetes ConfigMap that will hold the configuration layer |
    | config.configmap.cnJettyRequestHeaderSize | int | `8192` | Jetty header size in bytes in the auth server |
    | config.configmap.cnSecretKubernetesSecret | string | `"cn"` | Kubernetes secret name holding configuration keys. Used when global.configSecretAdapter is set to kubernetes which is the default. |
    | config.configmap.cnSqlDbDialect | string | `"mysql"` | SQL database dialect. `mysql` or `pgsql` |
    | config.configmap.cnSqlDbHost | string | `"my-release-mysql.default.svc.cluster.local"` | SQL database host uri. |
    | config.configmap.cnSqlDbName | string | `"jans"` | SQL database name. |
    | config.configmap.cnSqlDbPort | int | `3306` | SQL database port. |
    | config.configmap.cnSqlDbTimezone | string | `"UTC"` | SQL database timezone. |
    | config.configmap.cnSqlDbUser | string | `"jans"` | SQL database username. |
    | config.configmap.cnSqlPasswordFile | string | `"/etc/jans/conf/sql_password"` | SQL password file holding password from config.configmap.cnSqldbUserPassword . |
    | config.configmap.cnSqldbUserPassword | string | `"Test1234#"` | SQL password  injected as config.configmap.cnSqlPasswordFile . |
    | config.configmap.lbAddr | string | `""` | Loadbalancer address for AWS if the FQDN is not registered. |
    | config.countryCode | string | `"US"` | Country code. Used for certificate creation. |
    | config.dnsConfig | object | `{}` | Add custom dns config |
    | config.dnsPolicy | string | `""` | Add custom dns policy |
    | config.email | string | `"support@gluu.org"` | Email address of the administrator usually. Used for certificate creation. |
    | config.image.repository | string | `"janssenproject/configuration-manager"` | Image  to use for deploying. |
    | config.image.tag | string | `"1.0.0_b11"` | Image  tag to use for deploying. |
    | config.orgName | string | `"Gluu"` | Organization name. Used for certificate creation. |
    | config.resources | object | `{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}}` | Resource specs. |
    | config.resources.limits.cpu | string | `"300m"` | CPU limit. |
    | config.resources.limits.memory | string | `"300Mi"` | Memory limit. |
    | config.resources.requests.cpu | string | `"300m"` | CPU request. |
    | config.resources.requests.memory | string | `"300Mi"` | Memory request. |
    | config.state | string | `"TX"` | State code. Used for certificate creation. |
    | config.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service. |
    | config.usrEnvs.normal | object | `{}` | Add custom normal envs to the service. variable1: value1 |
    | config.usrEnvs.secret | object | `{}` | Add custom secret envs to the service. variable1: value1 |
    | config.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
    | config.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |

=== "config-api"
    | Key | Type | Default | Description |
    |-----|------|---------|-------------|
    | config-api | object | `{"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","repository":"janssenproject/config-api","tag":"1.0.0_b11"},"livenessProbe":{"httpGet":{"path":"/health-check/live","port":8074},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"readinessProbe":{"httpGet":{"path":"/health-check/ready","port":8074},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"1000m","memory":"400Mi"},"requests":{"cpu":"1000m","memory":"400Mi"}},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Config Api endpoints can be used to configure the auth-server, which is an open-source OpenID Connect Provider (OP) and UMA Authorization Server (AS). |
    | config-api.dnsConfig | object | `{}` | Add custom dns config |
    | config-api.dnsPolicy | string | `""` | Add custom dns policy |
    | config-api.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
    | config-api.hpa.behavior | object | `{}` | Scaling Policies |
    | config-api.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
    | config-api.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
    | config-api.image.repository | string | `"janssenproject/config-api"` | Image  to use for deploying. |
    | config-api.image.tag | string | `"1.0.0_b11"` | Image  tag to use for deploying. |
    | config-api.livenessProbe | object | `{"httpGet":{"path":"/jans-config-api/api/v1/health/live","port":8074},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the liveness healthcheck for the auth server if needed. |
    | config-api.livenessProbe.httpGet | object | `{"path":"/jans-config-api/api/v1/health/live","port":8074}` | http liveness probe endpoint |
    | config-api.readinessProbe.httpGet | object | `{"path":"/jans-config-api/api/v1/health/ready","port":8074}` | http readiness probe endpoint |
    | config-api.replicas | int | `1` | Service replica number. |
    | config-api.resources | object | `{"limits":{"cpu":"1000m","memory":"400Mi"},"requests":{"cpu":"1000m","memory":"400Mi"}}` | Resource specs. |
    | config-api.resources.limits.cpu | string | `"1000m"` | CPU limit. |
    | config-api.resources.limits.memory | string | `"400Mi"` | Memory limit. |
    | config-api.resources.requests.cpu | string | `"1000m"` | CPU request. |
    | config-api.resources.requests.memory | string | `"400Mi"` | Memory request. |
    | config-api.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
    | config-api.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
    | config-api.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
    | config-api.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
    | config-api.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |

=== "global"
    | Key | Type | Default | Description |
    |-----|------|---------|-------------|
    | global | object | `{"alb":{"ingress":false},"auth-server":{"appLoggers":{"auditStatsLogLevel":"INFO","auditStatsLogTarget":"FILE","authLogLevel":"INFO","authLogTarget":"STDOUT","httpLogLevel":"INFO","httpLogTarget":"FILE","ldapStatsLogLevel":"INFO","ldapStatsLogTarget":"FILE","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scriptLogLevel":"INFO","scriptLogTarget":"FILE"},"authServerServiceName":"auth-server","enabled":true},"auth-server-key-rotation":{"enabled":false},"awsStorageType":"io1","azureStorageAccountType":"Standard_LRS","azureStorageKind":"Managed","casa":{"casaServiceName":"casa"},"client-api":{"appLoggers":{"clientApiLogLevel":"INFO","clientApiLogTarget":"STDOUT"},"clientApiServerServiceName":"client-api","enabled":false},"cloud":{"testEnviroment":false},"cnGoogleApplicationCredentials":"/etc/jans/conf/google-credentials.json","cnJackrabbitCluster":true,"cnObExtSigningAlias":"","cnObExtSigningJwksCrt":"","cnObExtSigningJwksKey":"","cnObExtSigningJwksKeyPassPhrase":"","cnObExtSigningJwksUri":"","cnObStaticSigningKeyKid":"","cnObTransportAlias":"","cnObTransportCrt":"","cnObTransportKey":"","cnObTransportKeyPassPhrase":"","cnObTransportTrustStore":"","cnPersistenceType":"ldap","config":{"enabled":true},"config-api":{"appLoggers":{"configApiLogLevel":"INFO","configApiLogTarget":"STDOUT"},"configApiServerServiceName":"config-api","enabled":true},"configAdapterName":"kubernetes","configSecretAdapter":"kubernetes","cr-rotate":{"enabled":false},"distribution":"default","fido2":{"appLoggers":{"fido2LogLevel":"INFO","fido2LogTarget":"STDOUT","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE"},"enabled":false,"fido2ServiceName":"fido2"},"fqdn":"demoexample.gluu.org","gcePdStorageType":"pd-standard","isFqdnRegistered":false,"istio":{"enabled":false,"ingress":false,"namespace":"istio-system"},"jackrabbit":{"enabled":false,"jackRabbitServiceName":"jackrabbit"},"lbIp":"","nginx-ingress":{"enabled":true},"opendj":{"enabled":false,"ldapServiceName":"opendj"},"oxpassport":{"oxPassportServiceName":"oxpassport"},"oxshibboleth":{"enabled":false,"oxShibbolethServiceName":"oxshibboleth"},"persistence":{"enabled":true},"scim":{"appLoggers":{"ldapStatsLogLevel":"INFO","ldapStatsLogTarget":"FILE","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scimLogLevel":"INFO","scimLogTarget":"STDOUT","scriptLogLevel":"INFO","scriptLogTarget":"FILE"},"enabled":false,"scimServiceName":"scim"},"storageClass":{"allowVolumeExpansion":true,"allowedTopologies":[],"mountOptions":["debug"],"parameters":{},"provisioner":"microk8s.io/hostpath","reclaimPolicy":"Retain","volumeBindingMode":"WaitForFirstConsumer"},"upgrade":{"enabled":false},"usrEnvs":{"normal":{},"secret":{}}}` | Parameters used globally across all services helm charts. |
    | global.alb.ingress | bool | `false` | Activates ALB ingress |
    | global.auth-server-key-rotation.enabled | bool | `false` | Boolean flag to enable/disable the auth-server-key rotation cronjob chart. |
    | global.auth-server.appLoggers | object | `{"auditStatsLogLevel":"INFO","auditStatsLogTarget":"FILE","authLogLevel":"INFO","authLogTarget":"STDOUT","httpLogLevel":"INFO","httpLogTarget":"FILE","ldapStatsLogLevel":"INFO","ldapStatsLogTarget":"FILE","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scriptLogLevel":"INFO","scriptLogTarget":"FILE"}` | App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed. |
    | global.auth-server.appLoggers.auditStatsLogLevel | string | `"INFO"` | jans-auth_audit.log level |
    | global.auth-server.appLoggers.auditStatsLogTarget | string | `"FILE"` | jans-auth_script.log target |
    | global.auth-server.appLoggers.authLogLevel | string | `"INFO"` | jans-auth.log level |
    | global.auth-server.appLoggers.authLogTarget | string | `"STDOUT"` | jans-auth.log target |
    | global.auth-server.appLoggers.httpLogLevel | string | `"INFO"` | http_request_response.log level |
    | global.auth-server.appLoggers.httpLogTarget | string | `"FILE"` | http_request_response.log target |
    | global.auth-server.appLoggers.ldapStatsLogLevel | string | `"INFO"` | jans-auth_persistence_ldap_statistics.log level |
    | global.auth-server.appLoggers.ldapStatsLogTarget | string | `"FILE"` | jans-auth_persistence_ldap_statistics.log target |
    | global.auth-server.appLoggers.persistenceDurationLogLevel | string | `"INFO"` | jans-auth_persistence_duration.log level |
    | global.auth-server.appLoggers.persistenceDurationLogTarget | string | `"FILE"` | jans-auth_persistence_duration.log target |
    | global.auth-server.appLoggers.persistenceLogLevel | string | `"INFO"` | jans-auth_persistence.log level |
    | global.auth-server.appLoggers.persistenceLogTarget | string | `"FILE"` | jans-auth_persistence.log target |
    | global.auth-server.appLoggers.scriptLogLevel | string | `"INFO"` | jans-auth_script.log level |
    | global.auth-server.appLoggers.scriptLogTarget | string | `"FILE"` | jans-auth_script.log target |
    | global.auth-server.authServerServiceName | string | `"auth-server"` | Name of the auth-server service. Please keep it as default. |
    | global.auth-server.enabled | bool | `true` | Boolean flag to enable/disable auth-server chart. You should never set this to false. |
    | global.cloud.testEnviroment | bool | `false` | Boolean flag if enabled will strip resources requests and limits from all services. |
    | global.cnGoogleApplicationCredentials | string | `"/etc/jans/conf/google-credentials.json"` | Base64 encoded service account. The sa must have roles/secretmanager.admin to use Google secrets and roles/spanner.databaseUser to use Spanner. |
    | global.cnObExtSigningAlias | string | `""` | Open banking external signing AS Alias. This is a kid value.Used in SSA Validation, kid used while encoding a JWT sent to token URL i.e XkwIzWy44xWSlcWnMiEc8iq9s2G |
    | global.cnObExtSigningJwksCrt | string | `""` | Open banking external signing jwks AS certificate authority string. Used in SSA Validation. This must be encoded using base64.. Used when `.global.cnObExtSigningJwksUri` is set. |
    | global.cnObExtSigningJwksKey | string | `""` | Open banking external signing jwks AS key string. Used in SSA Validation. This must be encoded using base64. Used when `.global.cnObExtSigningJwksUri` is set. |
    | global.cnObExtSigningJwksKeyPassPhrase | string | `""` | Open banking external signing jwks AS key passphrase to unlock provided key. This must be encoded using base64. Used when `.global.cnObExtSigningJwksUri` is set. |
    | global.cnObExtSigningJwksUri | string | `""` | Open banking external signing jwks uri. Used in SSA Validation. |
    | global.cnObStaticSigningKeyKid | string | `""` | Open banking  signing AS kid to force the AS to use a specific signing key. i.e Wy44xWSlcWnMiEc8iq9s2G |
    | global.cnObTransportAlias | string | `""` | Open banking transport Alias used inside the JVM. |
    | global.cnObTransportCrt | string | `""` | Open banking AS transport crt. Used in SSA Validation. This must be encoded using base64. |
    | global.cnObTransportKey | string | `""` | Open banking AS transport key. Used in SSA Validation. This must be encoded using base64. |
    | global.cnObTransportKeyPassPhrase | string | `""` | Open banking AS transport key passphrase to unlock AS transport key. This must be encoded using base64. |
    | global.cnObTransportTrustStore | string | `""` | Open banking AS transport truststore crt. This is normally generated from the OB issuing CA, OB Root CA and Signing CA. Used when .global.cnObExtSigningJwksUri is set. Used in SSA Validation. This must be encoded using base64. |
    | global.cnPersistenceType | string | `"sql"` | Persistence backend to run Gluu with ldap|couchbase|hybrid|sql|spanner. |
    | global.config-api.appLoggers | object | `{"configApiLogLevel":"INFO","configApiLogTarget":"STDOUT"}` | App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed. |
    | global.config-api.appLoggers.configApiLogLevel | string | `"INFO"` | configapi.log level |
    | global.config-api.appLoggers.configApiLogTarget | string | `"STDOUT"` | configapi.log target |
    | global.config-api.configApiServerServiceName | string | `"config-api"` | Name of the config-api service. Please keep it as default. |
    | global.config-api.enabled | bool | `true` | Boolean flag to enable/disable the config-api chart. |
    | global.config.enabled | bool | `true` | Boolean flag to enable/disable the configuration chart. This normally should never be false |
    | global.configAdapterName | string | `"kubernetes"` | The config backend adapter that will hold Gluu configuration layer. google|kubernetes |
    | global.configSecretAdapter | string | `"kubernetes"` | The config backend adapter that will hold Gluu secret layer. google|kubernetes |
    | global.distribution | string | `"openbanking"` | Gluu distributions supported are: default|openbanking. |
    | global.fqdn | string | `"demoexample.gluu.org"` | Fully qualified domain name to be used for Gluu installation. This address will be used to reach Gluu services. |
    | global.isFqdnRegistered | bool | `false` | Boolean flag to enable mapping global.lbIp  to global.fqdn inside pods on clouds that provide static ip for loadbalancers. On cloud that provide only addresses to the LB this flag will enable a script to actively scan config.configmap.lbAddr and update the hosts file inside the pods automatically. |
    | global.istio.enabled | bool | `false` | Boolean flag that enables using istio side cars with Gluu services. |
    | global.istio.ingress | bool | `false` | Boolean flag that enables using istio gateway for Gluu. This assumes istio ingress is installed and hence the LB is available. |
    | global.istio.namespace | string | `"istio-system"` | The namespace istio is deployed in. The is normally istio-system. |
    | global.lbIp | string | `""` | The Loadbalancer IP created by nginx or istio on clouds that provide static IPs. This is not needed if `global.fqdn` is globally resolvable. |
    | global.nginx-ingress.enabled | bool | `true` | Boolean flag to enable/disable the nginx-ingress definitions chart. |
    | global.persistence.enabled | bool | `true` | Boolean flag to enable/disable the persistence chart. |
    | global.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service. Envs defined in global.userEnvs will be globally available to all services |
    | global.usrEnvs.normal | object | `{}` | Add custom normal envs to the service. variable1: value1 |
    | global.usrEnvs.secret | object | `{}` | Add custom secret envs to the service. variable1: value1 |

=== "nginx-ingress"
    | Key | Type | Default | Description |
    |-----|------|---------|-------------|
    | nginx-ingress | object | `{"ingress":{"additionalAnnotations":{},"additionalLabels":{},"adminUiEnabled":true,"adminUiLabels":{},"authServerEnabled":true,"authServerLabels":{},"authServerProtectedRedisterLabels":{},"authServerProtectedRegister":false,"authServerProtectedToken":false,"authServerProtectedTokenLabels":{},"configApiEnabled":true,"configApiLabels":{},"fido2ConfigEnabled":false,"fido2ConfigLabels":{},"hosts":["demoexample.gluu.org"],"openidConfigEnabled":true,"openidConfigLabels":{},"path":"/","scimConfigEnabled":false,"scimConfigLabels":{},"scimEnabled":false,"scimLabels":{},"tls":[{"hosts":["demoexample.gluu.org"],"secretName":"tls-certificate"}],"u2fConfigEnabled":true,"u2fConfigLabels":{},"uma2ConfigEnabled":true,"uma2ConfigLabels":{},"webdiscoveryEnabled":true,"webdiscoveryLabels":{},"webfingerEnabled":true,"webfingerLabels":{}}}` | Nginx ingress definitions chart |
    | nginx-ingress.ingress.additionalAnnotations | object | `{}` | Additional annotations that will be added across all ingress definitions in the format of {cert-manager.io/issuer: "letsencrypt-prod"} Enable client certificate authentication nginx.ingress.kubernetes.io/auth-tls-verify-client: "optional" Create the secret containing the trusted ca certificates nginx.ingress.kubernetes.io/auth-tls-secret: "gluu/tls-certificate" Specify the verification depth in the client certificates chain nginx.ingress.kubernetes.io/auth-tls-verify-depth: "1" Specify if certificates are passed to upstream server nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream: "true" |
    | nginx-ingress.ingress.additionalLabels | object | `{}` | Additional labels that will be added across all ingress definitions in the format of {mylabel: "myapp"} |
    | nginx-ingress.ingress.authServerEnabled | bool | `true` | Enable Auth server endpoints /jans-auth |
    | nginx-ingress.ingress.authServerLabels | object | `{}` | Auth server config ingress resource labels. key app is taken |
    | nginx-ingress.ingress.authServerProtectedRedisterLabels | object | `{}` | Auth server protected token ingress resource labels. key app is taken |
    | nginx-ingress.ingress.authServerProtectedRegister | bool | `false` | Enable mTLS onn Auth server endpoint /jans-auth/restv1/register |
    | nginx-ingress.ingress.authServerProtectedToken | bool | `false` | Enable mTLS on Auth server endpoint /jans-auth/restv1/token |
    | nginx-ingress.ingress.authServerProtectedTokenLabels | object | `{}` | Auth server protected token ingress resource labels. key app is taken |
    | nginx-ingress.ingress.configApiLabels | object | `{}` | configAPI ingress resource labels. key app is taken |
    | nginx-ingress.ingress.openidConfigEnabled | bool | `true` | Enable endpoint /.well-known/openid-configuration |
    | nginx-ingress.ingress.openidConfigLabels | object | `{}` | openid-configuration ingress resource labels. key app is taken |
    | nginx-ingress.ingress.tls | list | `[{"hosts":["demoexample.gluu.org"],"secretName":"tls-certificate"}]` | Secrets holding HTTPS CA cert and key. |
    | nginx-ingress.ingress.u2fConfigEnabled | bool | `true` | Enable endpoint /.well-known/fido-configuration |
    | nginx-ingress.ingress.u2fConfigLabels | object | `{}` | u2f config ingress resource labels. key app is taken |
    | nginx-ingress.ingress.uma2ConfigEnabled | bool | `true` | Enable endpoint /.well-known/uma2-configuration |
    | nginx-ingress.ingress.uma2ConfigLabels | object | `{}` | uma2 config ingress resource labels. key app is taken |
    | nginx-ingress.ingress.webdiscoveryEnabled | bool | `true` | Enable endpoint /.well-known/simple-web-discovery |
    | nginx-ingress.ingress.webdiscoveryLabels | object | `{}` | webdiscovery ingress resource labels. key app is taken |
    | nginx-ingress.ingress.webfingerEnabled | bool | `true` | Enable endpoint /.well-known/webfinger |
    | nginx-ingress.ingress.webfingerLabels | object | `{}` | webfinger ingress resource labels. key app is taken |

=== "persistence"
    | Key | Type | Default | Description |
    |-----|------|---------|-------------|
    | persistence | object | `{"dnsConfig":{},"dnsPolicy":"","image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"janssenproject/persistence-loader","tag":"1.0.0_b12"},"resources":{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Job to generate data and intial config for Gluu Server persistence layer. |
    | persistence.dnsConfig | object | `{}` | Add custom dns config |
    | persistence.dnsPolicy | string | `""` | Add custom dns policy |
    | persistence.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
    | persistence.image.pullSecrets | list | `[]` | Image Pull Secrets |
    | persistence.image.repository | string | `"janssenproject/persistence-loader"` | Image  to use for deploying. |
    | persistence.image.tag | string | `"1.0.0_b12"` | Image  tag to use for deploying. |
    | persistence.resources | object | `{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}}` | Resource specs. |
    | persistence.resources.limits.cpu | string | `"300m"` | CPU limit |
    | persistence.resources.limits.memory | string | `"300Mi"` | Memory limit. |
    | persistence.resources.requests.cpu | string | `"300m"` | CPU request. |
    | persistence.resources.requests.memory | string | `"300Mi"` | Memory request. |
    | persistence.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
    | persistence.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
    | persistence.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
    | persistence.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
    | persistence.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |

```yaml
# -- OAuth Authorization Server, the OpenID Connect Provider, the UMA Authorization Server--this is the main Internet facing component of Gluu. It's the service that returns tokens, JWT's and identity assertions. This service must be Internet facing.
auth-server:
  # -- Configure the HorizontalPodAutoscaler
  hpa:
    enabled: true
    minReplicas: 1
    maxReplicas: 10
    targetCPUUtilizationPercentage: 50
    # -- metrics if targetCPUUtilizationPercentage is not set
    metrics: []
    # -- Scaling Policies
    behavior: {}
  # -- Add custom normal and secret envs to the service
  usrEnvs:
    # -- Add custom normal envs to the service
    # variable1: value1
    normal: {}
    # -- Add custom secret envs to the service
    # variable1: value1
    secret: {}
  # -- Add custom dns policy
  dnsPolicy: ""
  # -- Add custom dns config
  dnsConfig: {}
  image:
    # -- Image pullPolicy to use for deploying.
    pullPolicy: IfNotPresent
    # -- Image  to use for deploying.
    repository: janssenproject/auth-server
    # -- Image  tag to use for deploying.
    tag: 1.0.0_b12
    # -- Image Pull Secrets
    pullSecrets: [ ]
  # -- Service replica number.
  replicas: 1
  # -- Resource specs.
  resources:
    limits:
      # -- CPU limit.
      cpu: 2500m
      # -- Memory limit.
      memory: 2500Mi
    requests:
      # -- CPU request.
      cpu: 2500m
      # -- Memory request.
      memory: 2500Mi
  # -- Configure the liveness healthcheck for the auth server if needed.
  livenessProbe:
    # -- Executes the python3 healthcheck.
    # https://github.com/JanssenProject/docker-jans-auth-server/blob/master/scripts/healthcheck.py
    exec:
      command:
        - python3
        - /app/scripts/healthcheck.py
    initialDelaySeconds: 30
    periodSeconds: 30
    timeoutSeconds: 5
  # -- Configure the readiness healthcheck for the auth server if needed.
  # https://github.com/JanssenProject/docker-jans-auth-server/blob/master/scripts/healthcheck.py
  readinessProbe:
    exec:
      command:
        - python3
        - /app/scripts/healthcheck.py
    initialDelaySeconds: 25
    periodSeconds: 25
    timeoutSeconds: 5
  # -- Configure any additional volumes that need to be attached to the pod
  volumes: []
  # -- Configure any additional volumesMounts that need to be attached to the containers
  volumeMounts: []

# -- Configuration parameters for setup and initial configuration secret and config layers used by Gluu services.
config:
  # -- Add custom normal and secret envs to the service.
  usrEnvs:
    # -- Add custom normal envs to the service.
    # variable1: value1
    normal: {}
    # -- Add custom secret envs to the service.
    # variable1: value1
    secret: {}
  # -- City. Used for certificate creation.
  city: Austin
  configmap:
    # -- Jetty header size in bytes in the auth server
    cnJettyRequestHeaderSize: 8192
    # -- SQL database dialect. `mysql` or `pgsql`
    cnSqlDbDialect: mysql
    # -- SQL database host uri.
    cnSqlDbHost: my-release-mysql.default.svc.cluster.local
    # -- SQL database port.
    cnSqlDbPort: 3306
    # -- SQL database name.
    cnSqlDbName: jans
    # -- SQL database username.
    cnSqlDbUser: jans
    # -- SQL database timezone.
    cnSqlDbTimezone: UTC
    # -- SQL password file holding password from config.configmap.cnSqldbUserPassword .
    cnSqlPasswordFile: /etc/jans/conf/sql_password
    # -- SQL password  injected as config.configmap.cnSqlPasswordFile .
    cnSqldbUserPassword: Test1234#
    # -- Cache type. `NATIVE_PERSISTENCE`, `REDIS`. or `IN_MEMORY`. Defaults to `NATIVE_PERSISTENCE` .
    cnCacheType: NATIVE_PERSISTENCE
    # -- The name of the Kubernetes ConfigMap that will hold the configuration layer
    cnConfigKubernetesConfigMap: cn
    # [google_envs] Envs related to using Google
    # -- Service account with roles roles/secretmanager.admin base64 encoded string. This is used often inside the services to reach the configuration layer. Used only when global.configAdapterName and global.configSecretAdapter is set to google.
    cnGoogleSecretManagerServiceAccount: SWFtTm90YVNlcnZpY2VBY2NvdW50Q2hhbmdlTWV0b09uZQo=
    # -- Project id of the google project the secret manager belongs to. Used only when global.configAdapterName and global.configSecretAdapter is set to google.
    cnGoogleProjectId: google-project-to-save-config-and-secrets-to
    # [google_spanner_envs] Envs related to using Google Secret Manager to store config and secret layer
    # -- Google Spanner ID. Used only when global.cnPersistenceType is spanner.
    cnGoogleSpannerInstanceId: ""
    # -- Google Spanner Database ID. Used only when global.cnPersistenceType is spanner.
    cnGoogleSpannerDatabaseId: ""
    # [google_spanner_envs] END
    # [google_secret_manager_envs] Envs related to using Google Secret Manager to store config and secret layer
    # -- Secret version to be used for secret configuration. Defaults to latest and should normally always stay that way. Used only when global.configAdapterName and global.configSecretAdapter is set to google.
    cnSecretGoogleSecretVersionId: "latest"
    # -- Prefix for Gluu secret in Google Secret Manager. Defaults to gluu. If left gluu-secret secret will be created. Used only when global.configAdapterName and global.configSecretAdapter is set to google.
    cnSecretGoogleSecretNamePrefix: gluu
    # -- Passphrase for Gluu secret in Google Secret Manager. This is used for encrypting and decrypting data from the Google Secret Manager. Used only when global.configAdapterName and global.configSecretAdapter is set to google.
    cnGoogleSecretManagerPassPhrase: Test1234#
    # -- Secret version to be used for configuration. Defaults to latest and should normally always stay that way. Used only when global.configAdapterName and global.configSecretAdapter is set to google. Used only when global.configAdapterName and global.configSecretAdapter is set to google.
    cnConfigGoogleSecretVersionId: "latest"
    # -- Prefix for Gluu configuration secret in Google Secret Manager. Defaults to gluu. If left intact gluu-configuration secret will be created. Used only when global.configAdapterName and global.configSecretAdapter is set to google.
    cnConfigGoogleSecretNamePrefix: gluu
    # [google_secret_manager_envs] END
    # [google_envs] END
    # -- Value passed to Java option -XX:MaxRAMPercentage
    cnMaxRamPercent: "75.0"
    # -- Kubernetes secret name holding configuration keys. Used when global.configSecretAdapter is set to kubernetes which is the default.
    cnSecretKubernetesSecret: cn
    # -- Loadbalancer address for AWS if the FQDN is not registered.
    lbAddr: ""
  # -- Country code. Used for certificate creation.
  countryCode: US
  # -- Email address of the administrator usually. Used for certificate creation.
  email: support@gluu.org
  image:
    # -- Image  to use for deploying.
    repository: janssenproject/configurator
    # -- Image  tag to use for deploying.
    tag: 1.0.0_b12
    # -- Image Pull Secrets
    pullSecrets: [ ]
  # -- Organization name. Used for certificate creation.
  orgName: Gluu
  # -- Resource specs.
  resources:
    limits:
      # -- CPU limit.
      cpu: 300m
      # -- Memory limit.
      memory: 300Mi
    requests:
      # -- CPU request.
      cpu: 300m
      # -- Memory request.
      memory: 300Mi
  # -- State code. Used for certificate creation.
  state: TX
  # -- Configure any additional volumes that need to be attached to the pod
  volumes: []
  # -- Configure any additional volumesMounts that need to be attached to the containers
  volumeMounts: []
  # -- Add custom dns policy
  dnsPolicy: ""
  # -- Add custom dns config
  dnsConfig: {}

# -- Config Api endpoints can be used to configure the auth-server, which is an open-source OpenID Connect Provider (OP) and UMA Authorization Server (AS).
config-api:
  # -- Configure the HorizontalPodAutoscaler
  hpa:
    enabled: true
    minReplicas: 1
    maxReplicas: 10
    targetCPUUtilizationPercentage: 50
    # -- metrics if targetCPUUtilizationPercentage is not set
    metrics: []
    # -- Scaling Policies
    behavior: {}
  # -- Add custom normal and secret envs to the service
  usrEnvs:
    # -- Add custom normal envs to the service
    # variable1: value1
    normal: {}
    # -- Add custom secret envs to the service
    # variable1: value1
    secret: {}
  # -- Add custom dns policy
  dnsPolicy: ""
  # -- Add custom dns config
  dnsConfig: {}
  image:
    # -- Image pullPolicy to use for deploying.
    pullPolicy: IfNotPresent
    # -- Image  to use for deploying.
    repository: janssenproject/config-api
    # -- Image  tag to use for deploying.
    tag: 1.0.0_b12
    # -- Image Pull Secrets
    pullSecrets: [ ]
  # -- Service replica number.
  replicas: 1
  # -- Resource specs.
  resources:
    limits:
      # -- CPU limit.
      cpu: 1000m
      # -- Memory limit.
      memory: 400Mi
    requests:
      # -- CPU request.
      cpu: 1000m
      # -- Memory request.
      memory: 400Mi
  # -- Configure the liveness healthcheck for the auth server if needed.
  livenessProbe:
    # -- http liveness probe endpoint
    httpGet:
      path: /jans-config-api/api/v1/health/live
      port: 8074
    initialDelaySeconds: 30
    periodSeconds: 30
    timeoutSeconds: 5
  readinessProbe:
    # -- http readiness probe endpoint
    httpGet:
      path: /jans-config-api/api/v1/health/ready
      port: 8074
    initialDelaySeconds: 25
    periodSeconds: 25
    timeoutSeconds: 5
  # -- Configure any additional volumes that need to be attached to the pod
  volumes: []
  # -- Configure any additional volumesMounts that need to be attached to the containers
  volumeMounts: []

# -- Parameters used globally across all services helm charts.
global:
  # -- Add custom normal and secret envs to the service.
  # Envs defined in global.userEnvs will be globally available to all services
  usrEnvs:
    # -- Add custom normal envs to the service.
    # variable1: value1
    normal: {}
    # -- Add custom secret envs to the service.
    # variable1: value1
    secret: {}
  alb:
    # -- Activates ALB ingress
    ingress: false

  auth-server:
    # -- Name of the auth-server service. Please keep it as default.
    authServerServiceName: auth-server
    # -- Boolean flag to enable/disable auth-server chart. You should never set this to false.
    enabled: true
    # -- App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed.
    appLoggers:
      # -- jans-auth.log target
      authLogTarget: "STDOUT"
      # -- jans-auth.log level
      authLogLevel: "INFO"
      # -- http_request_response.log target
      httpLogTarget: "FILE"
      # -- http_request_response.log level
      httpLogLevel: "INFO"
      # -- jans-auth_persistence.log target
      persistenceLogTarget: "FILE"
      # -- jans-auth_persistence.log level
      persistenceLogLevel: "INFO"
      # -- jans-auth_persistence_duration.log target
      persistenceDurationLogTarget: "FILE"
      # -- jans-auth_persistence_duration.log level
      persistenceDurationLogLevel: "INFO"
      # -- jans-auth_persistence_ldap_statistics.log target
      ldapStatsLogTarget: "FILE"
      # -- jans-auth_persistence_ldap_statistics.log level
      ldapStatsLogLevel: "INFO"
      # -- jans-auth_script.log target
      scriptLogTarget: "FILE"
      # -- jans-auth_script.log level
      scriptLogLevel: "INFO"
      # -- jans-auth_script.log target
      auditStatsLogTarget: "FILE"
      # -- jans-auth_audit.log level
      auditStatsLogLevel: "INFO"
  awsStorageType: io1
  cloud:
    # -- Boolean flag if enabled will strip resources requests and limits from all services.
    testEnviroment: false
  # -- Persistence backend to run Gluu with ldap|couchbase|hybrid|sql|spanner.
  cnPersistenceType: sql
  # -- Open banking external signing jwks uri. Used in SSA Validation.
  cnObExtSigningJwksUri: ""
  # -- Open banking external signing jwks AS certificate authority string. Used in SSA Validation. This must be encoded using base64.. Used when `.global.cnObExtSigningJwksUri` is set.
  cnObExtSigningJwksCrt: ""
  # -- Open banking external signing jwks AS key string. Used in SSA Validation. This must be encoded using base64. Used when `.global.cnObExtSigningJwksUri` is set.
  cnObExtSigningJwksKey: ""
  # -- Open banking external signing jwks AS key passphrase to unlock provided key. This must be encoded using base64. Used when `.global.cnObExtSigningJwksUri` is set.
  cnObExtSigningJwksKeyPassPhrase: ""
  # -- Open banking external signing AS Alias. This is a kid value.Used in SSA Validation, kid used while encoding a JWT sent to token URL i.e XkwIzWy44xWSlcWnMiEc8iq9s2G
  cnObExtSigningAlias: ""
  # -- Open banking  signing AS kid to force the AS to use a specific signing key. i.e Wy44xWSlcWnMiEc8iq9s2G
  cnObStaticSigningKeyKid: ""
  # -- Open banking AS transport crt. Used in SSA Validation. This must be encoded using base64.
  cnObTransportCrt: ""
  # -- Open banking AS transport key. Used in SSA Validation. This must be encoded using base64.
  cnObTransportKey: ""
  # -- Open banking AS transport key passphrase to unlock AS transport key. This must be encoded using base64.
  cnObTransportKeyPassPhrase: ""
  # -- Open banking transport Alias used inside the JVM.
  cnObTransportAlias: ""
  # -- Open banking AS transport truststore crt. This is normally generated from the OB issuing CA, OB Root CA and Signing CA. Used when .global.cnObExtSigningJwksUri is set. Used in SSA Validation. This must be encoded using base64.
  cnObTransportTrustStore: ""
  config:
    # -- Boolean flag to enable/disable the configuration chart. This normally should never be false
    enabled: true
  # -- The config backend adapter that will hold Gluu configuration layer. google|kubernetes
  configAdapterName: kubernetes
  # -- The config backend adapter that will hold Gluu secret layer. google|kubernetes
  configSecretAdapter: kubernetes
  # -- Base64 encoded service account. The sa must have roles/secretmanager.admin to use Google secrets and roles/spanner.databaseUser to use Spanner.
  cnGoogleApplicationCredentials: /etc/jans/conf/google-credentials.json
  config-api:
    # -- Name of the config-api service. Please keep it as default.
    configApiServerServiceName: config-api
    # -- Boolean flag to enable/disable the config-api chart.
    enabled: true
    # -- App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed.
    appLoggers:
      # -- configapi.log target
      configApiLogTarget: "STDOUT"
      # -- configapi.log level
      configApiLogLevel: "INFO"
  # -- Fully qualified domain name to be used for Gluu installation. This address will be used to reach Gluu services.
  fqdn: demoexample.gluu.org
  # -- GCE storage kind if using Google disks
  gcePdStorageType: pd-standard
  # -- Boolean flag to enable mapping global.lbIp  to global.fqdn inside pods on clouds that provide static ip for loadbalancers. On cloud that provide only addresses to the LB this flag will enable a script to actively scan config.configmap.lbAddr and update the hosts file inside the pods automatically.
  isFqdnRegistered: false
  istio:
    # -- Boolean flag that enables using istio side cars with Gluu services.
    enabled: false
    # -- Boolean flag that enables using istio gateway for Gluu. This assumes istio ingress is installed and hence the LB is available.
    ingress: false
    # -- The namespace istio is deployed in. The is normally istio-system.
    namespace: istio-system
  # -- The Loadbalancer IP created by nginx or istio on clouds that provide static IPs. This is not needed if `global.fqdn` is globally resolvable.
  lbIp: ""
  nginx-ingress:
    # -- Boolean flag to enable/disable the nginx-ingress definitions chart.
    enabled: true
  # --  Gluu distributions supported are: default|openbanking.
  distribution: openbanking
  persistence:
    # -- Boolean flag to enable/disable the persistence chart.
    enabled: true

# -- Nginx ingress definitions chart
nginx-ingress:
  ingress:
    # -- Enable endpoint /.well-known/openid-configuration
    openidConfigEnabled: true
    # -- openid-configuration ingress resource labels. key app is taken
    openidConfigLabels: { }
    # -- Enable endpoint /.well-known/uma2-configuration
    uma2ConfigEnabled: true
    # -- uma2 config ingress resource labels. key app is taken
    uma2ConfigLabels: { }
    # -- Enable endpoint /.well-known/webfinger
    webfingerEnabled: true
    # -- webfinger ingress resource labels. key app is taken
    webfingerLabels: { }
    # -- Enable endpoint /.well-known/simple-web-discovery
    webdiscoveryEnabled: true
    # -- webdiscovery ingress resource labels. key app is taken
    webdiscoveryLabels: { }
    # Enable config API endpoints /jans-config-api
    configApiEnabled: true
    # -- configAPI ingress resource labels. key app is taken
    configApiLabels: { }
    # -- Enable endpoint /.well-known/fido-configuration
    u2fConfigEnabled: true
    # -- u2f config ingress resource labels. key app is taken
    u2fConfigLabels: { }
    # -- Enable Auth server endpoints /jans-auth
    authServerEnabled: true
    # -- Auth server config ingress resource labels. key app is taken
    authServerLabels: { }
    # -- Enable mTLS on Auth server endpoint /jans-auth/restv1/token
    authServerProtectedToken: false
    # -- Auth server protected token ingress resource labels. key app is taken
    authServerProtectedTokenLabels: { }
    # -- Enable mTLS onn Auth server endpoint /jans-auth/restv1/register
    authServerProtectedRegister: false
    # -- Auth server protected token ingress resource labels. key app is taken
    authServerProtectedRedisterLabels: { }
    # -- Additional labels that will be added across all ingress definitions in the format of {mylabel: "myapp"}
    additionalLabels: { }
    # -- Additional annotations that will be added across all ingress definitions in the format of {cert-manager.io/issuer: "letsencrypt-prod"}
    # Enable client certificate authentication
    # nginx.ingress.kubernetes.io/auth-tls-verify-client: "optional"
    # Create the secret containing the trusted ca certificates
    # nginx.ingress.kubernetes.io/auth-tls-secret: "gluu/tls-certificate"
    # Specify the verification depth in the client certificates chain
    # nginx.ingress.kubernetes.io/auth-tls-verify-depth: "1"
    # Specify if certificates are passed to upstream server
    # nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream: "true"
    additionalAnnotations: {}
    path: /
    hosts:
    - demoexample.gluu.org
    # -- Secrets holding HTTPS CA cert and key.
    tls:
    - secretName: tls-certificate
      hosts:
      - demoexample.gluu.org

# -- Job to generate data and intial config for Gluu Server persistence layer.
persistence:
  # -- Add custom normal and secret envs to the service
  usrEnvs:
    # -- Add custom normal envs to the service
    # variable1: value1
    normal: {}
    # -- Add custom secret envs to the service
    # variable1: value1
    secret: {}
  # -- Add custom dns policy
  dnsPolicy: ""
  # -- Add custom dns config
  dnsConfig: {}
  image:
    # -- Image pullPolicy to use for deploying.
    pullPolicy: IfNotPresent
    # -- Image  to use for deploying.
    repository: janssenproject/persistence-loader
    # -- Image  tag to use for deploying.
    tag: 1.0.0_b12
    # -- Image Pull Secrets
    pullSecrets: [ ]
  # -- Resource specs.
  resources:
    limits:
      # -- CPU limit
      cpu: 300m
      # -- Memory limit.
      memory: 300Mi
    requests:
      # -- CPU request.
      cpu: 300m
      # -- Memory request.
      memory: 300Mi
  # -- Configure any additional volumes that need to be attached to the pod
  volumes: []
  # -- Configure any additional volumesMounts that need to be attached to the containers
  volumeMounts: []
```
