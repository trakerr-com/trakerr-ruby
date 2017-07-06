require 'logger'
require 'delegate'
require 'event_trace_builder'
require 'trakerr_client'

module Trakerr
    class TrakerrLogger < SimpleDelegator
        attr_accessor :min_severity
        attr_accessor :trakerr_client

        def initalize(logger)
            __setobj__(logger)
            @min_severity = Logger::WARN
            #@trakerr_client TODO: Finish send to trakerr. 
        end

         ##
        # @see Logger#debug
        def debug(progname = nil, &block)
            send_to_trakerr(Logger::DEBUG, progname)
            super
        end

        ##
        # @see Logger#info
        def info(progname = nil, &block)
            send_to_trakerr(Logger::INFO, progname)
            super
        end

        ##
        # @see Logger#warn
        def warn(progname = nil, &block)
            send_to_trakerr(Logger::WARN, progname)
            super
        end

        ##
        # @see Logger#error
        def error(progname = nil, &block)
          send_to_trakerr(Logger::ERROR, progname)
          super
        end

        ##
        # @see Logger#fatal
        def fatal(progname = nil, &block)
            send_to_trakerr(Logger::FATAL, progname)
            super
        end

        ##
        # @see Logger#unknown
        def unknown(progname = nil, &block)
            send_to_trakerr(Logger::UNKNOWN, progname)
            super
        end

        private

        def send_to_trakerr(ex)
            if ex.is_a?(Exception)#TODO: Work on recognizing the java logger, and it having a backtrace.
                ex.set_backtrace(build_backtrace()) unless ex.backtrace
                return ex
            end

            err = RuntimeError.new(ex.to_s)
            err.set_backtrace(build_backtrace())
            err
        end

        def build_backtrace()
            backtrace = Kernal.caller
            backtrace.drop_while { |frame| frame[:file] =~ %r{/logger.rb\z} }
            backtrace
        end

        def severity_to_string(severity)
            case severity
        when Logger::DEBUG
            "debug"
        when Logger::INFO
            "info"
        when Logger::WARN
            "warn"
        when Logger::ERROR
            "error"
        when Logger::Fatal
            "fatal"
        else
            "fatal"#If logging "UNKNOWN"
        end
    end
end