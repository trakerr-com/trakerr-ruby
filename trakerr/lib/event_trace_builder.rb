# Trakerr API
#
# Get your application events and errors to Trakerr via the *Trakerr API*.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'trakerr_client'

module Trakerr
  class EventTraceBuilder

    ##
    # Gets the stactrace from the exception instance passed in.
    # RETURNS: A Stacktrace object that contains the trace of the exception passed in.
    # exc:Exception: The exception caught or rescued.
    ##
    def self.get_stacktrace(exc)
      raise ArgumentError, 'get_stacktrace expects an exception instance.' unless exc.is_a? Exception

      strace = Trakerr::Stacktrace.new
      add_stack_trace(strace, exc.class.name, exc.message, best_regexp_for(exc), exc.backtrace)
      strace
    end

    def self.get_logger_stacktrace(errtype, errmessage, stackarray)
      raise ArgumentError, 'errtype and errmessage are expected strings' unless (errtype.is_a? String) && (errmessage.is_a? String)
      raise ArgumentError, 'stackarray is expected to be an iterable with strings values' unless stackarray.respond_to?('each')

      strace = Trakerr::Stacktrace.new
      add_stack_trace(strace, errtype, errmessage, best_regexp_guess(stackarray[0]), stackarray)
      strace
    end

    private

    def self.add_stack_trace(strace, errtype, errmessage, regex, stackarray)
      newtrace = Trakerr::InnerStackTrace.new

      newtrace.type = errtype
      newtrace.message = errmessage
      newtrace.trace_lines = get_event_tracelines(regex, stackarray)
      strace.push(newtrace)
    end

    ##
    # Formats and returns a StackTraceLines object that holds the current stacktrace from the error.
    # RETURNS: A StackTraceLines object that contains the parsed traceback.
    # regex:RegularExpression: The regular expression to parse the stacktrace text with.
    # errarray:String[]: An array of strings which each of which is a StackTrace string line.
    ##
    def self.get_event_tracelines(regex, errarray)
      raise ArgumentError, 'errarray should be an iterable object.' unless errarray.respond_to?('each')

      stlines = Trakerr::StackTraceLines.new

      errarray.each do |line|
        stline = Trakerr::StackTraceLine.new
        match = parse_stacktrace(regex, line)
        stline.file = match[:file]
        stline.line = match[:line]
        stline.function = match[:function]

        stlines.push(stline)
      end
      stlines
    end

    ##
    # Parses each given line by the regex.
    # RETURNS: A match object with the capture groups file function and line set.
    # regex:RegularExpression: The regular expression to parse the stacktrace text with.
    # line:String: A string with the traceline to parce
    ##
    def self.parse_stacktrace(regex, line)
      raise ArgumentError, 'line should be a string.' unless line.is_a? String

      match = regex.match(line)
      return match if match

      raise RegexpError, 'line does not fit any of the supported stacktraces.' # TODO: Error handle this?
    end

    def self.best_regexp_for(exc)
      # TODO: add error check
      if defined?(Java::JavaLang::Throwable) && exc.is_a?(Java::JavaLang::Throwable)
        @@JAVA
      elsif defined?(OCIError) && exc.is_a?(OCIError)
        @@OCI
        # elsif execjs_exception?(exception)
        # Patterns::EXECJS disabled pending more complex test
      else
        @@RUBY
      end
    end

    def self.best_regexp_guess(str)
      # Guess the regex. Test each regex on the string and see which regex captures the most data.
      # Use the one that captures the most. RegexErrors if none of the regexs are able to match

      java_match = @@JAVA.match(str) if defined?(Java::JavaLang::Throwable)
      oci_match = @@OCI.match(str) # if defined?(OCIError)
      ruby_match = @@RUBY.match(str)
      java_count = 0
      ruby_count = 0
      oci_count = 0

      ruby_match.captures.each { |item| ruby_count += 1 if item } if ruby_match
      oci_match.captures.each { |item| oci_count += 1 if item } if oci_match
      java_match.captures.each { |item| java_count += 1 if item } if java_match

      if ruby_count >= oci_count && ruby_count >= java_count && ruby_count > 0
        @@RUBY
      elsif oci_count >= ruby_count && oci_count >= java_count && oci_count > 0
        @@OCI
      elsif java_count >= ruby_count && java_count >= oci_count && java_count > 0
        @@JAVA
      else
        raise RegexpError, 'line does not fit any of the supported stacktraces.'
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
