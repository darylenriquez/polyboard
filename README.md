# PolyBoard

This sample application uses the omniauth-google-oauth2 and google-api-client gems to use gmail api.

In this App:
  - A user can create and update its own user account
  - Create, Update and View Mailboxes
  - In Each Mailbox, a user can connect many gmail accounts
  - User can view and send mails from each gmail accounts

This app should ask user for permission to retrieve emails. It should use the GMail API to access emails.

### Tech

This app uses the following:

* Rails
* Devise - For user management
* Bulma Rails - For using Bulma CSS
* Font Awesome - For better Icons
* Omniauth
* omniauth-google-oauth2
* google-api-client
* NotifyJS
* TinyMCE
* NGROK - for exposing the local server

And other gems and techs.

### Before Running

Please go to [Google Developers Console](https://console.developers.google.com/apis/credentials) and create new OAuth 2.0 client ID credential and enable GMAIL, Conatcts and Google+ API. Take note of the generated Client ID and Client Secret.

Create a file named gmail_variables.yml in config directory and add the client id and secret. The file should be in the following format (ID and Secret provided are sample only):


```sh
development:
  CLIENT_ID: "ddsdsdasdsdfsg34889u432u2gc78r2387g2.apps.googleusercontent.com"
  CLIENT_SECRET: "dsdfds99-hdsh"

test:
  CLIENT_ID: "ddsdsdasdsdfsg34889u432u2gc78r2387g2.apps.googleusercontent.com"
  CLIENT_SECRET: "dsdfds99-hdsh"

production:
  CLIENT_ID: "ddsdsdasdsdfsg34889u432u2gc78r2387g2.apps.googleusercontent.com"
  CLIENT_SECRET: "dsdfds99-hdsh"
```

If you are running this project in Development Mode:

Run ngrok to expose the server to the internet:

```sh
./bin/ngrok http 3000
```

Go back to the Developers console and update the credential created a while ago. Update the Authorized Redirect URI using the forwarding address provided by ngrok.

Youre all set! Use the forwarding address provided to access the server.

If you are running this project in Production Mode:

Go back to the Developers console and update the credential created a while ago. Update the Authorized Redirect URI using the address of the production server.

### Todos

 - Write Tests

