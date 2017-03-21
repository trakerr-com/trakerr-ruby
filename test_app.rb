require 'rubygems'
require_relative 'trakerr/lib/trakerr'

def main()
    testApp = Trakerr::TrakerrClient.new("a56a68537730468def34067d0df7943f17815001900144", "1.0", "development")
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

