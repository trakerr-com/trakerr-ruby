require 'rubygems'
require_relative 'trakerr/lib/trakerr'

def main()
    argarr = ARGV
    api_key = "<Your API key here>"

    api_key = argarr[0] if argarr.length > 0 and api_key == "<Your API key here>"

    testApp = Trakerr::TrakerrClient.new(api_key, "1.0", "development")
    
    begin
        raise ArgumentError
    rescue Exception => e
        appev = testApp.CreateAppEvent(e, "Error")
        appev.event_user = "john@trakerr.io"
        appev.event_session = "5"

        testApp.SendEvent(appev)
    end

    appev2 = testApp.CreateAppEvent(false, "Info", "User failed auth", "400 err", "User error")
    appev2.event_user = "jill@trakerr.io"
    appev2.event_session = "3"

    testApp.SendEvent(appev2)

end

main

