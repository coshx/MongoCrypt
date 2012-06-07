

MongoCrypt (http://addons.heroku.com/mongocrypt2) is an add-on (http://addons.heroku.com) for providing an encrypted mongo database.

Adding an encrypted mongo database to an application provides a secure way to store data.  

Your provisioned MongoCrypt database is accessible via any normal mongo driver which supports ssl (including the ruby driver, Python, Java, and Node.js).  

Mongomapper is also supported using :git => 'https://github.com/ZimChi/mongomapper.git'


*****

## Provisioning the add-on

MongoCrypt can be attached to a Heroku application via the  CLI:

<div class="callout" markdown="1">
A list of all plans available can be found [here](http://addons.heroku.com/ADDON_SLUG).
</div>

    :::term
    $ heroku addons:add ADDON_SLUG
    -----> Adding ADDON_SLUG to sharp-mountain-4005... done, v18 (free)

Once ADDON_NAME has been added a `ADDON_CONFIG_NAME` setting will be available in the app configuration and will contain the [[variable purpose, i.e. "canonical URL used to access the newly provisioned ADDON_NAME service instance."]]. This can be confirmed using the `heroku config` command.

    :::term
    $ heroku config | grep ADDON_CONFIG_NAME
    ADDON_CONFIG_NAME    => http://user:pass@instance.ip/resourceid

After installing ADDON_NAME the application should be configured to fully integrate with the add-on.

## Local setup

### Environment setup

[[If running against the add-on service during development is not applicable this section can be omitted]]

After provisioning the add-on it’s necessary to locally replicate the config vars so your development environment can operate against the service.

<div class="callout" markdown="1">
Though less portable it’s also possible to set local environment variables using `export ADDON_CONFIG_NAME=value`.
</div>

Use [Foreman](config-vars#local_setup) to reliably configure and run the process formation specified in your app’s [Procfile](procfile). Foreman reads configuration variables from an .env file. Use the following command to add the ADDON_CONFIG_NAME values retrieved from heroku config to `.env`.

$ heroku config -s | grep ADDON_CONFIG_NAME >> .env
$ more .env

<p class="warning" markdown="1">
Credentials and other sensitive configuration values should not be committed to source-control. In Git exclude the .env file with: `echo .env >> .gitignore`.
</p>

### Service setup

[[If there is a local executable required (like for the memcache add-on) then include installation instructions. If not, omit entire section]]

ADDON_NAME can be installed for use in a local development  environment.  Typically this entails [[installing the software | creating another version of the service]] and pointing the ADDON_CONFIG_NAME to this [[local | remote]] service.

<table>
  <tr>
    <th>If you have...</th>
    <th>Install with...</th>
  </tr>
  <tr>
    <td>Mac OS X</td>
    <td style="text-align: left"><code>brew install X</code></td>
  </tr>
  <tr>
    <td>Windows</td>
    <td style="text-align: left">Link to some installer</td>
  </tr>
  <tr>
    <td>Ubuntu Linux</td>
    <td style="text-align: left"><code>apt-get install X</code></td>
  </tr>
  <tr>
    <td>Other</td>
    <td style="text-align: left">Link to some raw package</td>
  </tr>
</table>

## Using with Rails 3.x

[[Repeat this ##Rails 3.x sections for all other supported languages/frameworks including Java, Node.js, Python, Scala, Play!, Grails, Clojure. Heroku is a polyglot platform - don't box yourself into supporting a single language]]

Ruby on Rails applications will need to add the following entry into their `Gemfile` specifying the ADDON_NAME client library.

    :::ruby
    gem 'ADDON_SLUG'

Update application dependencies with bundler.

    :::term
    $ bundle install
    sample output

### Development environment

When developing locally it is best to turn off the integration with ADDON_NAME to minimize dependencies on remote services. [[Describe how to stub/disable add-on integration - or specific steps required for local dev - for your service here.]].

### Deploy changes

Deploy the ADDON_NAME configuration to Heroku:

    :::term
    $ git add config/ADDON_SLUG.rb
    $ git commit -a -m "Adding ADDON_SLUG config"
    $ git push heroku master
    …
    -----> Heroku receiving push
    -----> Launching... done, v3
           http://warm-frost-1289.herokuapp.com deployed to Heroku

    To git@heroku.com:warm-frost-1289.git
     * [new branch]      master -> master

Configuration of the add-on can be confirmed by running:

    :::term
    $ heroku run confirmation command

[[On Heroku, configuration is managed via configuration variables. Please update client libraries to follow this pattern. No configuration files with sensitive information should ever be required within the application source and required config values should be read in from the ENV by supported libraries.]]

### Feature 1

[[Describe how to use/integrate feature 1 from Ruby on Rails]]

### Feature 2

[[Describe how to use/integrate feature 2 from Ruby on Rails]]

## Monitoring & Logging

Stats and the current state of ADDON_NAME can be displayed via the CLI.

    :::term
    $ heroku ADDON_SLUG:command
    example output

ADDON_NAME activity can be observed within the Heroku log-stream by [[describe add-on logging recognition, if any]].

    :::term
    $ heroku logs -t | grep 'ADDON_SLUG pattern'

## Dashboard

<div class="callout" markdown="1">
For more information on the features available within the ADDON_NAME dashboard please see the docs at [mysite.com/docs](mysite.com/docs).
</div>

The ADDON_NAME dashboard allows you to [[describe dashboard features]].

![ADDON_NAME Dashboard](http://i.imgur.com/FkuUw.png "ADDON_NAME Dashboard")

The dashboard can be accessed via the CLI:

    :::term
    $ heroku addons:open ADDON_SLUG
    Opening ADDON_SLUG for sharp-mountain-4005…

or by visiting the [Heroku apps web interface](http://heroku.com/myapps) and selecting the application in question. Select ADDON_NAME from the Add-ons menu.

![ADDON_NAME Add-ons Dropdown](http://f.cl.ly/items/1B090n1P0d3W0I0R172r/addons.png "ADDON_NAME Add-ons Dropdown")

## Troubleshooting

If [[feature X]] does not seem to be [[common issue Y]] then 
[[add specific commands to look for symptoms of common issue Y]].

## Migrating between plans

<div class="note" markdown="1">Application owners should carefully manage the migration timing to ensure proper application function during the migration process.</div>

[[Specific migration process or any migration tips 'n tricks]]

Use the `heroku addons:upgrade` command to migrate to a new plan.

    :::term
    $ heroku addons:upgrade ADDON_SLUG:newplan
    -----> Upgrading ADDON_SLUG:newplan to sharp-mountain-4005... done, v18 ($49/mo)
           Your plan has been updated to: ADDON_SLUG:newplan

## Removing the add-on

ADDON_NAME can be removed via the  CLI.

<div class="warning" markdown="1">This will destroy all associated data and cannot be undone!</div>

    :::term
    $ heroku addons:remove ADDON_SLUG
    -----> Removing ADDON_SLUG from sharp-mountain-4005... done, v20 (free)

Before removing ADDON_NAME a data export can be performed by [[describe steps if export is available]].

## Support

All ADDON_NAME support and runtime issues should be submitted via on of the [Heroku Support channels](support-channels). Any non-support related issues or product feedback is welcome at [[your channels]].

## Additional resources

Additional resources are available at:

* [Site docs](http://mysite.com)
* [Some screencast](http://someguysblog.com)