require 'logger'

module Trakerr
  class TrakerrFormatter < Logger::Formatter
    def initialize(standard_format = true)
      super()
      @standard_format = standard_format
    end

    def call(severity, time, progname, msg)
      if @standard_format
        severityid = severity[0]
        "#{severityid}, [#{time}] #{severity} #{progname} : #{msg2str(msg)}\n"
      else
        "#{severity}\n#{progname}\n#{msg2str(msg)}\n"
      end
    end
  end
end
