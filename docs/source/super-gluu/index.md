# Super Gluu Documentation
Super Gluu is a free and secure two-factor authentication (2FA) mobile app. 

Super Gluu is tightly bundled with the [Gluu Server](https://gluu.org/gluu-server) identity and access management platform, and can be used to achieve 2FA for web and mobile applications that leverage Gluu for authentication.

Super Gluu documentation is organized into the following sections:

- [User Guide](./user-guide/index.md)
- [Admin Guide](./admin-guide/index.md)
- [Developer Guide](./developer-guide/index.md)

## U2F Security
During Super Gluu authentication, the Gluu Server does more than look at the device ID to grant access. Super Gluu uses the Gluu Server's FIDO U2F endpoints to enroll a public key. The private key is stored on the device. To authenticate, the Gluu Server sends a challenge response to the device to check for the corresponding private key.

## How to Deploy Super Gluu 
Super Gluu is tightly bundled with the Gluu Server. Follow the [Gluu installation guide](https://gluu.org/docs/ce/installation-guide/) to deploy Gluu, then follow the Super Gluu [admin guide](https://gluu.org/docs/ce/authn-guide/supergluu/) to configure and begin using Super Gluu for strong authentication.

### Workflows
Super Gluu supports multiple workflows, including: 

- A one-step authentication, where the person scans a QR code with their Super Gluu app, and the Gluu Server looks up which person is associated with that device. 

- A two-step authentication, where the person enters their username and then receives an out-of-band push notification to the mobile device to authorize access (a.k.a identifier first authentication).

- A two-step authentication, where the person enters their username and password and then receives an out-of-band push notification to the mobile device to authorize access.   

In all scenarios, users are prompted to scan a QR code on their first Super Gluu authentication to bind their device and account. In the second and third workflows listed above, users begin receiving push notifications for all authentications after the initial device registration process. 

### Testing locally 

Super Gluu security is based on SSL, and therefore expects a public server with valid certificates. To test locally on a **non-public** server, [follow these steps](./developer-guide/index.md#testing-locally)

## Download Super Gluu		
Super Gluu is available for free on the iOS and Android app marketplaces! 

 - [Download the Android app](https://play.google.com/store/apps/details?id=gluu.org.super.gluu)

 - [Download the iOS app](https://itunes.apple.com/us/app/super-gluu/id1093479646?ls=1&mt=8)

## Business Model 		
 
 - By default, Super Gluu includes advertisements.    		
		
 - Ads can be removed with an in-app purchase for $0.99 per month. For bulk ad-free pricing, please [schedule a call with us](https://gluu.org/booking).
 
 - Super Gluu customizations and source code are available with the purchase of a [Gluu VIP Support contract](https://gluu.org/pricing).
 		
 Learn more about our offerings on the pricing section of the [Super Gluu website](http://super.gluu.org/).  

## NSTIC Funding
Funding for this project was in part provided by an [NSTIC pilot](https://www.nist.gov/itl/tig/pilot-projects#MorphoTrust_USA) project. The base code is MIT License and available on [Github](https://github.com/GluuFederation/oxPush3). 
