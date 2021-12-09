# Super Gluu Admin Guide
This section explains how to configure the Gluu Server to support Super Gluu for strong authentication.

If you do not already have a Gluu Server, [read the docs](http://gluu.org/docs/ce) to learn how to download and deploy the software for free. 

!!! Note
    Super Gluu is tightly bundled with the Gluu Server. The purpose of the Gluu Server is to provide a central authentication service for many mobile and web applications. The purpose of Super Gluu is to enforce strong authentication for access to those apps that rely on the Gluu Server for login. 

## Enable Super Gluu

To get started, log into the Gluu Server dashboard (a.k.a. oxTrust) and do the following: 

1. Navigate to `Configuration` > `Manage Custom Scripts`
1. In the `Person Authentication` tab find the `super_gluu` authentication module  
1. Scroll down and find the `Enable` check box 
1. Enable the script by clicking the check box
1. Scroll to the bottom of the page and click `Update` 

Now, Super Gluu is an available authentication mechanism for your Gluu Server. This means that, using OpenID Connect `acr_values`, applications can now request Super Gluu authentication for users. 

!!! Note 
    To make sure Super Gluu has been enabled successfully, check your Gluu Server's OpenID Connect configuration by navigating to the following URL: `https://<hostname>/.well-known/openid-configuration`. Find `"acr_values_supported":` and look for `"super_gluu"`. 

## Make Super Gluu the Default Authentication Mechanism

Now, applications can request Super Gluu authentication, but what if you want to make Super Gluu your default authentication mechanism? Follow these instructions: 

1. Navigate to `Configuration` > `Manage Authentication` 
2. Select the `Default Authentication Method` tab 
3. In the Default Authentication Method window, see two options: `Default acr` and `oxTrust acr` 

    - The `oxTrust acr` field controls the authentication mechanism that is presented to access the oxTrust dashboard GUI (the application you are in)    
    - The `Default acr` field controls the default authentication mechanism that is presented to users from all applications that leverage your Gluu Server for authentication    

Change one or both fields to Super Gluu authentication as you see fit. To make Super Gluu the default authentication mechanism for access to oxTrust and all other applications that leverage your Gluu Server, change both fields to Super Gluu.  
 
## How to Register a New Device 

After Super Gluu is enabled and configured, initiate the standard login sequence to enroll the device. After successfully entering the username and password you will be presented with a Super Gluu QR code. If you haven't already downloaded Super Gluu, you will now need to download the app. Once downloaded, open the app and scan the QR code.

The app will prompt to approve or deny. Approve the authentication, and now the device has been associated with your account in the Gluu Server. For all future authentications, you will receive a push notification to approve or deny the request. 

## What to Do About Lost Devices? 

If someone loses their device, they will need to inform the Gluu system administrator, who can do the following: 
    
  - Find the ‘DN’ of this user from LDAP 
    
  - Find the oxID ‘DN’ associated with the user
    
  - Remove the oxID DN 

For example, let's say user ‘abc’ lost his device and wants to enroll a new device to use Super Gluu. The Gluu Server admin will do the following: 

(a) Get the DN of user ‘abc’ which will be something like this:   
`dn: inum=@!ABCD.1234.XXX.XXX.YYYY.8770,ou=people,o=@!DEFG.5678.XXX.XXX.ZZZ,o=gluu”`
 
(b) Now find the ‘oxID’ DN which is associated with this user’s DN. It might be something like: 

> ```
> dn: oxId=1487683146561,ou=fido,inum=@!ABCD.1234.XXX.XXX.YYYY.8770,ou=people,o=@!DEFG.5678.XXX.XXX.ZZZ,o=gluu
> objectClass: oxDeviceRegistration
> objectClass: top
> oxDeviceData: {"uuid":"b82abc-a1b2-3abc-bcccc-2222222222222","type":"normal","platform":"android","name":"zico","os_name":"kitkat","os_version":"4.4.4","push_token":"dddddddddd:aaaaaa_58_cccccc_4t_bbbbbbbbbbbbb_aaaaaaaaaaaaaa_ggggggggg"}
> oxDeviceKeyHandle: fyyyyyyyyyyyyy_jaaaaaaaaaaaa_mKJw
> oxStatus: active
> oxApplication: https://test.gluu.org/identity/authentication/authcode
> oxCounter: 2
> creationDate: 20170221131906.559Z
> oxId: 11111111111111111
> oxDeviceRegistrationConf: {"publicKey":"BIGbwF…………….","attestationCert":"MIICJjCCAcygAwIBAgKBgQDzLA-......L5ztE"}
> oxLastAccessTime: 20170
> ```

(c) Delete the oxID DN  

Now the old device is gone, and the user can enroll a new device following the instructions above, regarding registering a new device.  
