require 'logger'

module Trakerr
  class TrakerrFormatter < Logger::Formatter
    def initialize()
      super()
    end

    def call(severity, time, progname, msg)
      severityid = severity[0]
      "#{severityid}, [#{time}] #{severity} #{progname} : #{msg2str(msg)}\n"
    end
  end
end
