# NearNote
## Environment
* ruby 3.4.2
* Rails 8.0.1
* SQLite3 2.6.0

## Installation
### Clone repository
```
git clone https://github.com/jdkim/nearnote.git
cd nearnote
```

### Install dependencies
```
bundle install
```

### Setup database
```
rails db:setup
```

### Start the server
```
rails server
```

Now, you can access NearNote at http://localhost:3000.

## Tests
This project uses Minitest for testing. To run the tests, execute:
```
rails test
```

To run system tests, execute:
```
rails test:system
```

## ReCAPTCHA settings procedure
Note: The reCAPTCHA feature will be off if site_key and secret_key are not set.

Access the Google reCAPTCHA site and log in with your Google account.
```
https://www.google.com/recaptcha/admin/create
```

Enter the required information.

label example:
```
near-note
```

reCAPTCHA type:
```
v2 "I'm not a robot" checkbox
```

domain:  
Add your domain, example:
```
example.com
```

After you register your site, site_key and secret_key are generated.  
Add keys to .env file to use reCAPTCHA on your app.
```
RECAPTCHA_SITE_KEY=[Generated site key]
RECAPTCHA_SECRET_KEY=[Generated secret key]
```
