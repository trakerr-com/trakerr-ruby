require 'rubygems'
require_relative 'trakerr/lib/trakerr'

def main()
    argarr = ARGV
    testApp = nil
    if argarr.length > 0
        testApp = Trakerr::TrakerrClient.new(argarr[0], "1.0", "development")
    else
        testApp = Trakerr::TrakerrClient.new("<Your API key here>", "1.0", "development")
    end
    
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

