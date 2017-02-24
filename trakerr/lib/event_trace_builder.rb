require "trakerr_client"


module Trakerr
  class EventTraceBuilder

    def self.get_stacktrace(exc)
      raise ArgumentError, "get_stacktrace expects an exception instance." unless exc.is_a? Exception

      strace = Trakerr::Stacktrace.New
      add_stack_trace(strace, exc)
      return strace

    end

    def self.add_stack_trace(strace, exc)
      raise ArgumentError, "add_stack_trace did not get passed in the correct arguments" unless exc.is_a? Exception and strace.instance_of? Stacktrace

      newtrace = Trakerr::InnerStackTrace.New

      newtrace.type = exc.class.name
      newtrace.message = exc.message
      newtrace.trace_lines = get_event_tracelines(best_regexp_for(exc), exc.backtrace)
      strace.push(newtrace)
    end

    def self.get_event_tracelines(regex, errarray)
      raise ArgumentError, "errarray should be an iterable object." unless errarray.respond_to?('each')

      stlines = Trakerr::StackTraceLines.new

      errarray.each {|line| 
      stline = Trakerr::StackTraceLine.new
      match = parse_stacktrace(regex, line)
      stline.file, stline.line, stline.function = match[:file], match[:line], match[:function]

      stlines.push(stline)
      }
      return stlines
    end

    def self.parse_stacktrace(regex, line)
      raise ArgumentError, "line should be a string." unless line.is_a? String

      match = regex.match(line)
      return match if match

      raise RegexpError, "line does not fit any of the supported stacktraces."
    end

    def self.best_regexp_for(exc)
      #add error check
      if defined?(Java::JavaLang::Throwable) && exc.is_a?(Java::JavaLang::Throwable)
        @@JAVA
      elsif defined?(OCIError) && exc.is_a?(OCIError)
        @@OCI
      #elsif execjs_exception?(exception)
        # Patterns::EXECJS disabled pending more complex test
      else
        @@RUBY
      end
    end

    private

      ##
      # @return [Regexp] the pattern that matches standard Ruby stack frames,
      #   such as ./spec/notice_spec.rb:43:in `block (3 levels) in <top (required)>'
      @@RUBY = %r{\A
          (?<file>.+)       # Matches './spec/notice_spec.rb'
          :
          (?<line>\d+)      # Matches '43'
          :in\s
          `(?<function>.*)' # Matches "`block (3 levels) in <top (required)>'"
        \z}x

      ##
      # @return [Regexp] the pattern that matches JRuby Java stack frames, such
      #  as org.jruby.ast.NewlineNode.interpret(NewlineNode.java:105)
      @@JAVA = %r{\A
        (?<function>.+)  # Matches 'org.jruby.ast.NewlineNode.interpret'
        \(
          (?<file>
            (?:uri:classloader:/.+(?=:)) # Matches '/META-INF/jruby.home/protocol.rb'
            |
            (?:uri_3a_classloader_3a_.+(?=:)) # Matches 'uri_3a_classloader_3a_/gems/...'
            |
            [^:]+        # Matches 'NewlineNode.java'
          )
          :?
          (?<line>\d+)?  # Matches '105'
        \)
      \z}x

      ##
      # @return [Regexp] the pattern that tries to assume what a generic stack
      #   frame might look like, when exception's backtrace is set manually.
      @@GENERIC = %r{\A
        (?:from\s)?
        (?<file>.+)              # Matches '/foo/bar/baz.ext'
        :
        (?<line>\d+)?            # Matches '43' or nothing
        (?:
          in\s`(?<function>.+)'  # Matches "in `func'"
        |
          :in\s(?<function>.+)   # Matches ":in func"
        )?                       # ... or nothing
      \z}x

      ##
      # @return [Regexp] the pattern that matches exceptions from PL/SQL such as
      #   ORA-06512: at "STORE.LI_LICENSES_PACK", line 1945
      # @note This is raised by https://github.com/kubo/ruby-oci8
      @@OCI = /\A
        (?:
          ORA-\d{5}
          :\sat\s
          (?:"(?<function>.+)",\s)?
          line\s(?<line>\d+)
        |
          #{@@GENERIC}
        )
      \z/x

      ##
      # @return [Regexp] the pattern that matches CoffeeScript backtraces
      #   usually coming from Rails & ExecJS
      @@EXECJS = /\A
        (?:
          # Matches 'compile ((execjs):6692:19)'
          (?<function>.+)\s\((?<file>.+):(?<line>\d+):\d+\)
        |
          # Matches 'bootstrap_node.js:467:3'
          (?<file>.+):(?<line>\d+):\d+(?<function>)
        |
          # Matches the Ruby part of the backtrace
          #{@@RUBY}
        )
      \z/x

  end
end