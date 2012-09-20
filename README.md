PGAS means Postgresql As Service
================================

This is naive implementation for "Postgresql as Service"

It shuld be something like heroku postgresql :)

Features:
--------

* clasterization
* create database [with template]
* template repository management - u can create template from db or download it from some storage (sftp, s3...)
* drop database
* backup database and save backup in (sftp, s3 etc)
* restore database
* clone database
* standby copy
* etc

* rabbitmq client
* http client
* simple status web ui
