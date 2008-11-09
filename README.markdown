OpenId
======

This extension provides [OpenID](http://openid.net) support for [Spree](http://spreehq.org).  The business logic included in this extension provides sensible defaults for various user authentication/creation scenarios.  Feel free to fork and modify to taste.

The authorizaiton requests make user of the [OpenID Simple Registration Extension 1.0](http://openid.net/specs/openid-simple-registration-extension-1_0.html) when possible.  So if the OpenID provider supports this specification, then requested user information (by default only email) will be returned as `sreg` parameters.

User Authentication
-------------------

Authentication refers to the login screen where the user is asked to supply their email and password (or OpenID.)  If the user provides an openid url then they will be taken to the standard login screen for that user's provider.  Upon successful authentication, the url will be checked against existing users in the Spree database.  The user is authorized if a record is found with a matching url.  Otherwise, the user is denied access and informed of the condition by a flash message.

User Creation
-------------

Users are required to supply an email address to create an account.  If they choose to authenticate by OpenID (by supplying an openid url) then no password is required.  The authentication request to the provider will include the user email in the return url.  There have been reports of this not working properly with some providers but support for query parameters in the return url are part of the OpenID 2.0 specification.  (TODO - Find out if its part of the 1.0 specification.)

A new user account will be created using the email returned by the authentication response.  The user account will then have the openid url associated with it for future authentication scenarios.

Auto Creation
-------------

If the user successfully authenticates via OpenID but there is no user with a corresponding URL, then Spree will attempt to create a new account automatically.  If there is an `sreq` parameter for email, we first check to see if there is a user with a corresponding email.  

If there is a matching email, the user will be presented with a screen and given the opportunity to associate this openid url with their account.  In order to do so, the user must enter their original password in order to prevent malicious attempts to hijack another user's account.

If no matching email is found then Spree will automatically create the account using the email provided by the `sreq` parameters.

If there is no `sreq` parameter for email, then the user will be redirected to the account creation page and asked to provide one.