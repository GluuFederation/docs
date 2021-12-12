# One-Time Password (OTP) Authentication

## Overview
This document explains how to use the Gluu Server's included 
[OTP interception script](https://raw.githubusercontent.com/GluuFederation/oxAuth/master/Server/integrations/otp/OtpExternalAuthenticator.py) 
to implement a two-step, two-factor authentication (2FA) process with username / password as the first step, and any OTP *app* as the second step. 

The OTP interception script uses the two-factor event/counter-based HOTP algorithm [RFC4226](https://tools.ietf.org/html/rfc4226) and the time-based TOTP algorithm [RFC6238](https://tools.ietf.org/html/rfc6238).

!!! Note
    To support SMS OTP, follow the [SMS OTP](./sms-otp.md) documentation.

## Prerequisites
- A Gluu Server ([installation instructions](../installation-guide/index.md))
- [HOTP / TOTP authentication script](https://raw.githubusercontent.com/GluuFederation/oxAuth/master/Server/integrations/otp/OtpExternalAuthenticator.py) (included in the default Gluu Server distribution)
- A device with an OTP mobile app installed, like one of the apps [listed below](#recommended-otp-apps)

### Recommended OTP apps
- Google Authenticator for [Android](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=en) or [iOS](https://itunes.apple.com/us/app/google-authenticator/id388497605?mt=8)
- [FreeOTP](https://freeotp.github.io/)
- [Authy](https://authy.com/)

## Properties
The OTP authentication script has the following properties: 

|	Property	|	Description		|	Example	|
|-----------------------|-------------------------------|---------------|
|issuer	|Issuer of the OTP service|Gluu Inc|
|label  |The name of the application | Gluu OTP| 
|otp_conf_file   | Location of the OTP configuration file | `/etc/certs/otp_configuration.json`|
|otp_type| Type of OTP in use |totp or hotp|
|qr_options| Size of the QR code that is used for device enrollment|{ size: 400, mSize: 0.05 }|
|registration_uri | Registration endpoint of the IDP| `https://idp.example.com/identity/register`| 
    
## Enable OTP
Follow the steps below to enable Super Gluu authentication:

1. In oxTrust, navigate to `Configuration` > `Person Authentication Scripts`
1. Find the OTP script
1. Enable the script by checking the box 
1. Scroll to the bottom of the page and click `Update`

Now OTP is an available authentication mechanism for your Gluu Server. This means that, using OpenID Connect `acr_values`, applications can now request OTP authentication for users. 

## Make OTP the Default

If OTP should be the default authentication mechanism, follow these instructions: 

1. Navigate to `Configuration` > `Manage Authentication` 

1. Select the `Default Authentication Method` tab 

1. In the Default Authentication Method window you will see two options: `Default acr` and `oxTrust acr` 

 - `oxTrust acr` sets the authentication mechanism for accessing the oxTrust dashboard GUI (only managers should have acccess to oxTrust)    

 - `Default acr` sets the default authentication mechanism for accessing all applications that leverage your Gluu Server for authentication (unless otherwise specified)    

If OTP should be the default authentication mechanism for all access, change both fields to OTP.  

## OTP Login Pages
The Gluu Server includes two default login pages for OTP:

1. An **enrollment** page that is displayed the first time a user is prompted for OTP authentication;     
![otp-enrollment](../img/user-authn/otp-enrollment.png)                  

1. A **login** page that is displayed for all subsequent OTP authentications.     
![otp](../img/user-authn/otp.png)


## Using OTP Apps

### Device Enrollment

OTP device enrollment happens during the first authentication attempt. The initial enrollment page displays a QR code that needs to be scanned with the OTP app. 

### Subsequent Logins
All subsequent authentications will require the user to retreive and enter an OTP from the application.

### Credential Management
A user's OTP device(s) can be removed by a Gluu administrator either via the oxTrust UI in `Users` > `Manage People`, or in LDAP under the user entry. In LDAP, navigate to appliances and search for an attribute `oxExternalUid`. Remove the values of this attribute. Upon the next OTP login attempt, the user will be prompted to enroll a new device. 

## Notes on TOTP usage

OTP custom script works in one of two modes: TOTP (time-based) or HOTP (even-based). When using time-based flavor of OTP, mobile applications generate codes based on the current time of the device, this code is validated by the server using its own time. As consequene, significant time lags can provoke authentication failures.

It's out of admins control have users devices in a consistent time, but they can maintain server system time accurately. For this you can follow any of the different approaches for linux time synchronization over the network, the most common being **ntp**.

## Self-service account security

To offer end-users a portal where they can manage their own account security preferences, including two-factor authentication credentials like OTP apps, check out our new app, [Gluu Casa](https://casa.gluu.org). 
