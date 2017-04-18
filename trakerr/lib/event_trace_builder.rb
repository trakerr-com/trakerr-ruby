=begin
Trakerr API

Get your application events and errors to Trakerr via the *Trakerr API*.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end

require "trakerr_client"


module Trakerr
  class EventTraceBuilder

    ##
    #Gets the stactrace from the exception instance passed in.
    #RETURNS: A Stacktrace object that contains the trace of the exception passed in.
    #exc:Exception: The exception caught or rescued.
    ##
    def self.get_stacktrace(exc)
      raise ArgumentError, "get_stacktrace expects an exception instance." unless exc.is_a? Exception

      strace = Trakerr::Stacktrace.new
      add_stack_trace(strace, exc)
      return strace
    end

    private

      ##
      #Adds a InnerStackTrace to the Stacktrace object (which is a collection)
      #strace:Stacktrace: The Stacktrace object to append the latest InnerStackTrace to.
      #exc:Exception: The exception caught or rescued.
      ##
      def self.add_stack_trace(strace, exc)
        raise ArgumentError, "add_stack_trace did not get passed in the correct arguments" unless exc.is_a? Exception and strace.instance_of? Stacktrace

        newtrace = Trakerr::InnerStackTrace.new

        newtrace.type = exc.class.name
        newtrace.message = exc.message
        newtrace.trace_lines = get_event_tracelines(best_regexp_for(exc), exc.backtrace)
        strace.push(newtrace)
      end

      ##
      #Formats and returns a StackTraceLines object that holds the current stacktrace from the error.
      #RETURNS: A StackTraceLines object that contains the parsed traceback.
      #regex:RegularExpression: The regular expression to parse the stacktrace text with.
      #errarray:String[]: An array of strings which each of which is a StackTrace string line.
      ##
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

      ##
      #Parses each given line by the regex
      #RETURNS: A match object with the capture groups file function and line set.
      #regex:RegularExpression: The regular expression to parse the stacktrace text with.
      #line:String: A string with the traceline to parce
      ##
      def self.parse_stacktrace(regex, line)
        raise ArgumentError, "line should be a string." unless line.is_a? String

        match = regex.match(line)
        return match if match

        raise RegexpError, "line does not fit any of the supported stacktraces." #TODO: Error handle this?
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