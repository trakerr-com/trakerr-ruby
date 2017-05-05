require 'trakerr_client'
require 'event_trace_builder'

module Trakerr
   class TrakerrWriter < StringIO
       def initialize(apiKey, contextAppVersion="1.0", contextDeploymentStage="development")
           super()
           @client = Trakerr::TrakerrClient.new(apiKey, contextAppVersion, contextDeploymentStage)
       end

       def write(str)
           strarray = str.dup.split("\n")

           loglevel = nil
           classification = nil
           evname = nil
           evmessage = nil
           stacktrace = []

           strarray.each_index do |i|
               if i == 0 #TrakerrFormatter dictates severity as the first line.
                   loglevel = strarray[i]

               elsif i == 1 #TrakerrFormatter dictates progname as the second line. This is optional, but will be used as a classification.
                   classification = strarray[i]
               
               elsif i == 2 #TrakerrFormatter dictates `message` as the their line. Message is actually the error message AND the name of the error in parenthesis.
                   ob = strarray[i].match(/(?<message>.*)(?<name>\(.*\))/)
                   evname = ob[:name].gsub(/^\(+|\)+$/, '')
                   evmessage = ob[:message]

               else #All following lines are stacktrace shoved into the buffer automatically if provided.
                    #This is only given if the logger gets an error object,
                    #but I don't believe the TrakerrFormatter has access to it
                   
                   stacktrace << strarray[i]
               end
               
            end

            event = @client.create_app_event(false, loglevel, classification, evname, evmessage)
            event.event_stacktrace = EventTraceBuilder.get_logger_stacktrace(evname, evmessage, stacktrace) \
                                                        unless stacktrace.empty?
            @client.send_event(event)

            super(str)
       end
   end 
end