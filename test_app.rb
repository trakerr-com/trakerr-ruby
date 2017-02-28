require 'rubygems'
require_relative 'trakerr/lib/trakerr'

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

main

