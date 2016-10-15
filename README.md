# Elvanto --> Google Mailing List Sync

[![Build Status](https://semaphoreci.com/api/v1/monty5811/elvanto_mail_sync/branches/development/badge.svg)](https://semaphoreci.com/monty5811/elvanto_mail_sync) [![Coverage Status](https://coveralls.io/repos/github/monty5811/elvanto_mail_sync/badge.svg?branch=master)](https://coveralls.io/github/monty5811/elvanto_mail_sync?branch=master)

Small webapp to sync Elvanto group members to mailing lists on a Google apps domain.

**NOTE** this may destroy all your data - this has not been fully tested yet!!

## Features

 - Whitelist access to particular users
 - Prevent syncing of an email address (on a per group or a global level)
 - Enable automated syncing for individual groups

## Installation

This app should run comfortably on Heroku's free tier providing you do not sync too frequently.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

 - Create credentials on google - you need to create an application with OAuth credentials and a service account
 - Click the push to deploy button
 - Add secrets as config variables on heroku
 - Scale the worker dyno up to 1
 - Setup a recurring task to run the command `python manage.py elvanto2google` using the scheduler addon
 - Sign into the app with a whitelisted user
 - Sync your groups

## Limitations

 - Roles on the mailing lists are not yet supported

## Contributing

Contributions very welcome. However, to make things as easy as possible, please fork this repo and then create a new feature branch and work in that - it makes things far [easier](http://codeinthehole.com/writing/pull-requests-and-other-good-practices-for-teams-using-github/).

The backend is a super simple Django app and the frontend is written in Elm.
