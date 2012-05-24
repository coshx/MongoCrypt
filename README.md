========
Setup
========
install Heroku toolbelt: https://toolbelt.herokuapp.com/

http://nodejs.org/#download

install Node:

rvm use 1.9.3

rvm gemset create kwyjibo

gem install foreman

npm install

-------
Run with
-------

SSO_SALT=e6t6vHOweLqDvvuM HEROKU_USERNAME=mongocrypt HEROKU_PASSWORD=xrTpvtHD0fbdfHsb foreman start

provision test resource with: kensa test provision

simulate admin panel login from heroku: kensa sso 1  (1 is the id of the resource)

simulate customer remoting with: ruby consumer_app.rb  (must install mongo)