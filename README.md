# README

* Prerequisites
  * Rails > 5.1
  * Ruby > 2.3.1
  * Node.js > 6.0.0
  * Yarn > 0.25.2
  * Sendgrid free account
  * Mailgun free account
* Database creation
  * development using sqlite
  * production using PostgreSQL on heroku
* Database initialization
  * ``` rails db:migrate ```
* How to run the test suite
  * ``` rspec```
* Services (job queues, cache servers, search engines, etc.)
  * Using ServiceOjbect to sent E-mail with Mailgun and Sendgrid
  * Check the ``` config/application.yml``` for API Key and mail to, cc, and bcc column.
    * SENDGRID_API_USER : `your SendGrid username`
    * SENDGRID_API_KEY :  `Your SendGrid password`
    * Mailgun_API_KEY : `Your Mailgun API KEY`
    * Mailgun_Domain : `Your Mailgun Domain`
    * mail_to_user : use `String` and comma to separate different user
      * ex.`"test@gmail.com,test2@gmail.com,test3@gmail.com"`
    * mail_cc_user : format same as mail_to_user
    * mail_bcc_user: format same as mail_to_user

* Deployment instructions

Eaxmple for Heroku

* Create new app on Heroku

```
$ heroku create
```

* Push to Heroku

```
$ git push heroku master
```
***If failed with yarn version***

```
$ heroku buildpacks:set heroku/nodejs
```

```
$ heroku buildpacks:add heroku/ruby
```
* Database initialization

```
$ heroku run rails:db:migrate
```

* Filled with your API key and Mail List on `config/application.yml`

* Push secret information by `Figaro`

```
$ figaro heroku:set -e production
```

* Done
