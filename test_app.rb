require 'rubygems'
require_relative 'trakerr/lib/trakerr'

def main()
    testApp = Trakerr::TrakerrClient.new("a56a68537730468def34067d0df7943f17815001900144", "1.0", "development")
    begin
        raise ArgumentError
    rescue Exception => e
        testApp.CreateError("Error", "Test", "TestBug", e)
    end
end

main

