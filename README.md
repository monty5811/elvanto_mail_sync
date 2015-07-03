# Elvanto --> Google Mailing List Sync
[![Circle CI](https://circleci.com/gh/monty5811/elvanto_mail_sync.svg?style=svg)](https://circleci.com/gh/monty5811/elvanto_mail_sync) [![codecov.io](http://codecov.io/github/monty5811/elvanto_mail_sync/coverage.svg?branch=master)](http://codecov.io/github/monty5811/elvanto_mail_sync?branch=master) [![Code Issues](http://www.quantifiedcode.com/api/v1/project/b97df657d68d46e9805d486bcac9e12d/badge.svg)](http://www.quantifiedcode.com/app/project/b97df657d68d46e9805d486bcac9e12d)

Small webapp to sync Elvanto group members to mailing lists run on a Google
apps domain.

**NOTE** this may destroy all your data - this has not been fully tested yet!!

## Features

 - Whitelist access to particular users
 - Prevent syncing of an email address (On a per group or a global level)
 - Enable automated syncing for individual groups

## Installation

This app should run comfortably on Heroku's free tier providing you do not sync too frequently. (Syncing every half hour leaves plenty of spare time.)

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

 - Create credentials on google TODO: link
 - Click the push to deploy button
 - Add secrets as config variables on heroku
 - Scale the worker dyno up to 1
 - Setup a recurring task to run the command `python manage.py elvanto2google` using the scheduler addon
 - Sign into the app with a user that has admin rights on your google apps domain
 - Sync your emails

## Limitations

 - Roles on the mailing lists are not yet supported - coming soon!

## Contributing

We welcome contributions. However, to make things as easy as possible, please fork this repo and then create a new feature branch and work in that - it makes things far [easier](http://codeinthehole.com/writing/pull-requests-and-other-good-practices-for-teams-using-github/).
