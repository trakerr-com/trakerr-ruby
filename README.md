# Trakerr - Ruby API client

Get your application events and errors to Trakerr via the *Trakerr API*.

You can send both errors and non-errors (plain log statements, for example) to Trakerr with this API.

## Overview

The detailed integration guides are primarily oriented around sending errors or warnings. **Option-3 in the
detailed integration guide** describes how you could send a non-exception (or any log statement).

A Trakerr *Event* can consist of various parameters as described here in [AppEvent](https://github.com/trakerr-com/trakerr-ruby/blob/master/generated/docs/AppEvent.md).
Some of these parameters are populated by default and others are optional and can be supplied by you.

Since some of these parameters are common across all event's, the API has the option of setting these on the
TrakerrClient instance (described towards the bottom) and offers a factory API for creating AppEvent's.

- REST API version: 2.0.0
- Package (SDK) version: 2.0.0

### Requirements.

Ruby 1.9.3+
and
git 2.0+

## Installation & Usage
### 1) Install git and curl
You will need git for the gem to work properly. If you do not have it installed, we recommend installing it from your package manager. You can use your package manager to install it on unix based machines. For machines using apt (ex: Ubuntu)

```bash
apt install git
```

For machines using yum (ex: centOS)
```bash
yum install git
```

For Windows, or if you aren't using a package manager, visit https://git-scm.com/ and download and install it manually. Make sure it is added to your path (open your command prompt and type git --version. If it works, you're set.)


If you are on Windows, you may also need to install curl and configure your ruby to use it. Trakerr uses typhous to actually send the exception to us. Follow the instructions on the curl website for more information and Typhous's project page to finish setup.

### 2) gem install

Install [bundler](http://bundler.io/) and then you can issue this command to get the freshest version:
```sh
gem "trakerr_client", :git => "git://github.com/trakerr-io/trakerr-ruby.git"
```

You can also install from ruby gems:
```sh
gem install trakerr_client
```
for the latest stable release.

Then import the package:
```ruby
require 'trakerr/lib/trakerr'
```

## Detailed Integration Guide

Please follow the [installation procedure](#installation--usage) and you're set to add Trakerr to your project. All of these examples are included in test_app.rb.

If you would like to generate some quick sample events, you may download test_app.rb and run it from the command line like so:
```sh
ruby test_app.rb <<api-key>>
```

### Package dependency
Require the package:

```ruby
require 'trakerr/lib/trakerr'
```

### Option 1: Sending a default error to Trakerr
A trivial case would involve calling `log` for a caught exception.
```ruby
def main()
    testApp = Trakerr::TrakerrClient.new("<api-key>", "Application version number", "deployment type")
    begin
        raise ZeroDivisionError, "Oh no!"
    rescue ZeroDivisionError => exception
        #You can leave the hash empty if you would like to use the default values.
        #We recommend that you supply a user and a session for all events,
        #and supplying an "evntname" and "evntmessage" for non errors.
        testApp.log({"user"=>"jack@trakerr.io", "session"=>"7"}, exception) 
    end
end
```

Along with the `"user"` and `"session"`; the hash can also take `"evntname"` and `"evntmessage"`. Note that these two will be filled in automatically for errors you rescue if you do not provide them, so we suggest giving them for non-errors.

`log` may also take in a log_level and a classification (We recommend you providing this **especially** if you send a warning or below), but will otherwise default all of the AppEvent properties.

### Option 2: Sending an error to Trakerr with Custom Data
If you want to populate the `AppEvent` fully with custom properties (log only accepts the minimum set of useful custom properties to utilize Trakerr's rich feature set), you can manually create an `AppEvent` and populate it's fields. Pass it to the `SendEvent` to then send the AppEvent to Trakerr. See the `AppEvent` API for more information on it's properties.

```ruby
def main()
    testApp = Trakerr::TrakerrClient.new("<api-key>", "Application version number", "deployment type")
    begin
        raise ArgumentError
    rescue Exception => e
        appev = testApp.CreateAppEvent(e)
        appev.event_user = "john@trakerr.io"
        appev.event_session = "5"

        testApp.SendEvent(appev)
    end
end
```

### Option 3: Send a non-exception to Trakerr
Trakerr accepts events that aren't errors. To do so, pass false to the CreateAppEvent Exception field to not attach a stacktrace to the event (if you don't need it). Be sure to pass values in to the rest of the parameters since the default values will most likely not be useful for you if you don't have a stacktrace!
```ruby
def main()
    testApp = Trakerr::TrakerrClient.new("<api-key>", "Application version number", "deployment type")
    
    #Send a non Exception to Trakerr.
    appev2 = testApp.CreateAppEvent(false, "Info", "User failed auth", "Passwords are different", "User error")
    appev2.event_user = "jill@trakerr.io"
    appev2.event_session = "3"

    testApp.SendEvent(appev2)
end
```

## An in-depth look at TrakerrClient's properties
TrakerrClient's constructor initalizes the default values to all of TrakerrClient's properties.

```ruby
 def initialize(def initialize(apiKey,
                   contextAppVersion = "1.0",
                   contextDeploymentStage = "development")
```

The TrakerrClient class however has a lot of exposed properties. The benefit to setting these immediately after after you create the TrakerrClient is that AppEvent will default it's values against the TrakerClient that created it. This way if there is a value that all your AppEvents uses, and the constructor default value currently doesn't suit you; it may be easier to change it in TrakerrClient as it will become the default value for all AppEvents created after. A lot of these are populated by default value by the constructor, but you can populate them with whatever string data you want. The following table provides an in-depth look at each of those.


Name | Type | Description | Notes
------------ | ------------- | -------------  | -------------
**apiKey** | **string** | API key generated for the application | 
**contextAppVersion** | **string** | Application version information. | Default value: `1.0`
**contextDevelopmentStage** | **string** | One of development, staging, production; or a custom string. | Default Value: `development`
**contextEnvLanguage** | **string** | Constant string representing the language the application is in. | Default value: "ruby"
**contextEnvName** | **string** | Name of the interpreter the program is run on. | Default Value: ruby if ruby MRI or jruby if jruby
**contextEnvVersion** | **string** | Version of ruby this program is running on. | Default Value: `JRUBY_VERSION` if jruby or `RUBY_VERSION` if ruby MRI 
**contextEnvHostname** | **string** | Hostname or ID of environment. | Default value: `Socket.gethostname`
**contextAppOS** | **string** | OS the application is running on. | Default value: OS name (ie. Windows, MacOS).
**contextAppOSVersion** | **string** | OS Version the application is running on. | Default value: System architecture string.
**contextAppOSBrowser** | **string** | An optional string browser name the application is running on. | Defaults to `nil`
**contextAppOSBrowserVersion** | **string** | An optional string browser version the application is running on. | Defaults to `nil`
**contextDataCenter** | **string** | Data center the application is running on or connected to. | Defaults to `nil`
**contextDataCenterRegion** | **string** | Data center region. | Defaults to `nil`

## Documentation For Models

 - [AppEvent](https://github.com/trakerr-com/trakerr-ruby/blob/master/generated/docs/AppEvent.md)

## Author
[RM](https://github.com/RMSD)
