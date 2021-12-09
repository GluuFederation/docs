# Password Reset

## Overview

As a privileged user, the administrator can configure the password reset feature built into the Gluu Server.
This feature gives users the ability to reset their password.
Below are the steps to configure that feature:

1. Provide the SMTP Server configuration
1. Enable password reset on oxTrust adminUI
1. Test

## Prerequisites

The following are requirements to use this feature:  

1. An active Gluu Server instance with oxTrust accessible via the web
1. A working SMTP Server  

## Provide the SMTP Server Configuration

The Gluu Server requires an SMTP server to be able to send password reset emails to the user's mailbox. 
A suitable UI is provided to gather the SMTP server configuation on Gluu OxTrust AdminUI.

1. Log into the Gluu Server as a user with admin privileges

1. Navigate to `Configuration` > `Organization Configuration`

1. Select the `SMTP Server Configuration` tab
  ![here](../img/user-authn/passwordRestFormEmpty.png)

1. Fill the form with correct values according to your SMTP Server settings
  ![here](../img/user-authn/PasswordResetFormFilled.png)

1. Click the `Test Configuration` button to ensure the SMTP server is working: 
If the configuration is correct, then you will see a successful message like this:
![here](../img/user-authn/SMTPServerTestSucceed.png)

1. Click the `Update` button to save changes
  
## Enable Password Reset on OxTrust 

1. Navigate to `Configuration` > `Organization Configuration`

1. Select the `System Configuration` tab

1. Enable `Self-Service Password Reset` 
  ![enable](../img/user-authn/PasswordResetEnable.png)

1. Click the `Update` button to save changes

## Test

1. Create a test user in the Gluu Server

1. Go to the Gluu Server login page

1. Click the `Forgot your Password?` link
  ![login](../img/user-authn/ForgetPasswordLink.png)
  
1. Fill the form with the user email and click the `Send Mail` button
  ![form](../img/user-authn/PasswordResetForm.png)
  
1. You'll get the following result:
  ![form](../img/user-authn/ResetPasswordSucceed.png)
  
1. Check the user's mailbox  
  ![form](../img/user-authn/SampleMailReceived.png)


