require 'logger'

module Trakerr
    class TrakerrFormatter < Logger::Formatter
       def initialize()
           super()
       end

       def call(severity, time, progname, msg)
           "#{severity}\n#{progname}\n#{msg2str(msg)}\n"
       end
    end
end