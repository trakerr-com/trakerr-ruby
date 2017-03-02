# trakerr_client
Get your application events and errors to Trakerr via the *Trakerr API*.

You will need your API key to send events to trakerr.

## Requirements.

Ruby 1.9.3+
git 2.0+

## Installation & Usage
### 1) Install git and curl
You will need git for the gem to work properly. If you do not have it installed, we recomment installing it from your package manager. You can use your package manager to install it on unix based machines. For machines using apt (ex: Ubuntu)

```bash
apt install git
```
For machines using yum (ex: centOS)
```bash
yum install git
```
For Windows, or if you aren't using a package manager, visit https://git-scm.com/ and download and install it manually. Make sure it is added to your path (open your command prompt and type git --version. If it works, you're set.)


If you are on Windows, you may also need to install curl. Follow the instructions on the curl website for more information. You will also need git installed.

### 2) gem install

Install [bundler](http://bundler.io/) and then you can issue this command to get the freshest version:
```sh
gem "trakerr_client", :git => "git://github.com/trakerr-io/trakerr-ruby.git"
```

You can also install from ruby gmes:
```sh
gem install trakerr_client
```
for the latest stable release.

Then import the package:
```ruby
require 'trakerr/lib/trakerr'
```

## Getting Started

Please follow the [installation procedure](#installation--usage) and you're set to add Trakerr to your project. All of these examples are included in testmain.py.

### Sending Data
You can send custom data as part of your error event if you need to. This circumvents the python handler. Add these imports:

```ruby
from trakerr import TrakerrClient
from trakerr_client.models import CustomData, CustomStringData
```

You'll then need to initialize custom properties once you create the event. Note that `CreateError` and `CreateEvent` can be used to send any levels of error, including warnings, info and fatal. Look at the method signature for more information.

```ruby
def main()
    testApp = Trakerr::TrakerrClient.new("a56a68537730468def34067d0df7943f17815001900144", "1.0", "development")
    begin
        raise ArgumentError
    rescue Exception => e
        appev = testApp.CreateError(e)
        appev.event_user = "john@trakerr.io"
        appev.event_session = "5"

        testApp.SendEvent(appev)
    end
end
```

## An in-depth look at initalizing Trakerr
Most of the examples above involve are initialized simply, since the error is populated with default values. If we take a look at the constructor, we see that there is actually plenty of fields we can fill in ourselves if we don't find the default value useful.
```ruby
 def initialize(apiKey,
                contextAppVersion = "1.0",
                contextEnvName = "development",
                contextEnvVersion = nil,
                contextEnvHostname= nil,
                contextAppOS= nil,
                contextAppOSVersion= nil,
                contextAppBrowser= nil,
                contextAppBrowserVersion= nil,
                contextDataCenter= nil,
                contextDataCenter= nil,
                url= nil)
```

Below is a useful table that covers what each of the the values should be and default to.


Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**api_key** | **str** | API key generated to identfy the application | 
**context_app_version** | **str** | (optional) application version information | [optional if passed `None`] 
**context_env_name** | **str** | (optional) one of &#39;development&#39;,&#39;staging&#39;,&#39;production&#39; or a custom string | [optional if passed `None`] Default Value: "develoment"
**context_env_version** | **str** | (optional) version of environment | [optional if passed `None`] Default Value: Interpreter type(ie. cpython, ironpy) and python version (ie. 2.7.8)
**context_env_hostname** | **str** | (optional) hostname or ID of environment | [optional if passed `None`] Default value: Name of the node the program is currently run on.
**context_app_os** | **str** | (optional) OS the application is running on | [optional if passed `None`] Default value: OS name (ie. Windows, MacOS) + Release (ie. 7, 8, 10, X)
**context_app_os_version** | **str** | (optional) OS version the application is running on | [optional if passed `None`] Default value: OS provided version number
**context_data_center** | **str** | (optional) Data center the application is running on or connected to | [optional if passed `None`] 
**context_data_center_region** | **str** | (optional) Data center region | [optional if passed `None`]
**context_app_browser** | **str** | (optional) browser name if running in a browser (eg. Chrome) | [optional] For web frameworks
**context_app_browser_version** | **str** | (optional) browser version if running in a browser | [optional] For web frameworks
**url_path** | **str** | message containing details of the event or error | 



## Documentation For Models

 - [AppEvent](https://github.com/trakerr-io/trakerr-python/blob/master/generated/docs/AppEvent.md)

## Author
[RM](https://github.com/RMSD)
