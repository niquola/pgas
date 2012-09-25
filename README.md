PGAS means Postgresql As Service
================================

This is naive implementation for "Postgresql as Service"

It shuld be something like heroku postgresql :)

Features:
--------
* serve databases
  * list db
  * create db
  * drop db

* manage template databases
  * list templates
  * create template
  * drop template

* mixed
  * clone db from template

USE CASE
--------
* use local
  service
  client class
  console client

* remote
  remote client (rabbit mq)


TODO:
--------
* clasterization
* template repository management - u can create template from db or download it from some storage (sftp, s3...)
* drop database
* backup database and save backup in (sftp, s3 etc)
* restore database
* clone database
* standby copy
* http client
* simple status web ui
