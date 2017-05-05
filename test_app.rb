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
require 'logger'
require_relative 'trakerr/lib/trakerr'
require_relative 'trakerr/lib/trakerr_formatter'
require_relative 'trakerr/lib/trakerr_writer'

def main()
    argarr = ARGV
    api_key = "<Your API key here>"

    api_key = argarr[0] if argarr.length > 0 and api_key == "<Your API key here>"

    testApp = Trakerr::TrakerrClient.new(api_key, "1.0", "development")
    stream = Trakerr::TrakerrWriter.new(api_key, "2.0", "development")

    rlog = Logger.new(stream)

    rlog.formatter = Trakerr::TrakerrFormatter.new

    begin
        raise IOError, "Failed to open file"
    rescue IOError => err
        rlog.fatal err
    end

    #Since we use streams (StringIO) to hook into the ruby logger,
    #accessing stream after it has finished logging and event is simple.
    #Rewind the stream, and then read it to extract data to whatever device you wish for.
    #The example in the comments below prints out to console. The formatter does change how the event is formatted
    #and the information given as the output to be pertinant and easy to parse by the stream hook, but I could probably write a complex regex for default
    #if the demand is there.
    #stream.rewind
    #log = stream.read
    #puts log

    #Send exception to Trakerr with default values.
    begin
        raise ZeroDivisionError, "Oh no!"
    rescue ZeroDivisionError => er
        #You can leave the hash empty if you would like to use the default values.
        #We recommend that you supply a user and a session for all events,
        #and supplying an "evntname" and "evntmessage" for non errors.
        testApp.log({"user"=>"jack@trakerr.io", "session"=>"7"}, er) 
    end
    
    #Get an AppEvent to populate the class with custom data and then send it to Trakerr.
    #Simple custom data can be send through log.
    begin
        raise RegexpError, "Help!"
    rescue RegexpError => e
        appev = testApp.create_app_event(e, "Error")
        appev.event_user = "john@trakerr.io"
        appev.event_session = "5"
        appev.context_app_browser = "Chrome"
        appev.context_app_browser_version = "57.x"

        testApp.send_event(appev)
    end

    #Send a non Exception to Trakerr.
    appev2 = testApp.create_app_event(false, "Info", "User failed auth", "400 err", "User error")
    appev2.event_user = "jill@trakerr.io"
    appev2.event_session = "3"
    appev2.context_app_browser = "Edge"
    appev2.context_app_browser_version = "40.15063.0.0"

    testApp.send_event(appev2)

end

main

