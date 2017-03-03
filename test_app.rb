require 'rubygems'
require_relative 'trakerr/lib/trakerr'

def main()
    testApp = Trakerr::TrakerrClient.new("Api Key Here", "1.0", "development")
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

