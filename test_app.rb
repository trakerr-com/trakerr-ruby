=begin
Trakerr API Test App

Get your application events and errors to Trakerr via the *Trakerr API*.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end

require 'rubygems'
require_relative 'trakerr/lib/trakerr'

def main()
    argarr = ARGV
    api_key = "<Your API key here>"

    api_key = argarr[0] if argarr.length > 0 and api_key == "<Your API key here>"

    testApp = Trakerr::TrakerrClient.new(api_key, "1.0", "development")

    #Send exception to Trakerr with default values.
    begin
        raise ZeroDivisionError, "Oh no!"
    rescue => exception
        testApp.SendException(exception) #You can change the log_level and the classification too if you would like to!
    end
    
    #Get an AppEvent to populate the class with custom data and then send it to Trakerr.
    begin
        raise ArgumentError
    rescue ArgumentError => e
        appev = testApp.CreateAppEvent(e, "Error")
        appev.event_user = "john@trakerr.io"
        appev.event_session = "5"

        testApp.SendEvent(appev)
    end

    #Send a non Exception to Trakerr.
    appev2 = testApp.CreateAppEvent(false, "Info", "User failed auth", "400 err", "User error")
    appev2.event_user = "jill@trakerr.io"
    appev2.event_session = "3"

    testApp.SendEvent(appev2)

end

main

