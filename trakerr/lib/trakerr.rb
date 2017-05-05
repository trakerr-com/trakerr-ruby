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

require "event_trace_builder"
require "trakerr_client"
require "socket"
require "date"

module Trakerr
  class TrakerrClient

    ##API Key
    attr_accessor :api_key

    ##App Version of the client the API is tying into.
    attr_accessor :context_app_version

    ##Deployment stage of the codebade the API is tying into.
    attr_accessor :context_deployment_stage

    ##String name of the language being used.
    attr_accessor :context_env_language

    ##The name of the interpreter
    attr_accessor :context_env_name

    ## context_env_version is the version of the interpreter the program is run on.
    attr_accessor :context_env_version

    ## context_env_version is hostname of the pc running the code.
    attr_accessor :context_env_version

    ## context_app_os is the OS the program is running on.
    attr_accessor :context_app_os

    ## context_app_os_version is the version of the OS the code is running on.
    attr_accessor :context_app_os_version

    ## context_app_browser is optional MVC and ASP.net applications the browser name the application is running on.
    attr_accessor :context_app_browser

    ## context_app_browser_version is optional for MVC and ASP.net applications the browser version the application is running on.
    attr_accessor :context_app_browser_version

    ## context_data_center is the optional datacenter the code may be running on.
    attr_accessor :context_data_center

    ## context_data_center_region is the optional datacenter region the code may be running on.
    attr_accessor :context_data_center_region

    ##
    #Initializes the TrakerrClient class.
    #api_key:String: Should be your API key string.
    #context_app_version:String: Should be the version of your application.
    #context_env_name:String: Should be the deployment stage of your program.
    ##
    def initialize(api_key,
                   context_app_version="1.0",
                   context_deployment_stage="development")

      default_config = Trakerr::Configuration.default
      default_config.base_path = default_config.base_path

      @api_key = api_key
      @context_app_version = context_app_version
      @context_deployment_stage = context_deployment_stage

      @context_env_language = "Ruby"
      
      if RUBY_PLATFORM == "java"
        @context_env_name = "jruby"
        @context_env_version = JRUBY_VERSION
      else
        @context_env_name = "ruby"
        @context_env_version = RUBY_VERSION
      end

      @context_env_version = Socket.gethostname
        
      host_os = RbConfig::CONFIG['host_os']
      case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          text = `systeminfo`

          @context_app_os = get_text_from_line(text, "OS Name:", "\n")
          @context_app_os.chomp! if @context_app_os != nil
          @context_app_os.strip! if @context_app_os != nil

				  version = get_text_from_line(text, "OS Version:", "\n").split
          version[0].chomp! if version != nil
          version[0].strip! if version != nil
          @context_app_os_version = context_app_os_version || version[0]

            
        when /darwin|mac os/
          text = `system_profiler SPSoftwareDataType`

          @context_app_os = get_text_from_line(text, "System Version:", "(").chomp.strip
				  @context_app_os_version = context_app_os_version || get_text_from_line(text, "Kernel Version:", "\n").chomp.strip
            
        when /linux/, /solaris|bsd/
          #uname -s and -r
          @context_app_os = `uname -s`.chomp.strip
          @context_app_os_version = context_app_os_version || `uname -r`.chomp.strip
      end

      if @context_app_os == nil 
        @context_app_os = RbConfig::CONFIG["target_os"]
      end
      if @context_app_os_version == nil
        @context_app_os_version = RbConfig::CONFIG['host_os']
      end
      
      @context_app_browser = context_app_browser
      @context_app_browser_version = context_app_browser_version
      @context_data_center = context_data_center
      @context_data_center_region = context_data_center_region
      api_client = Trakerr::ApiClient.new(default_config)
      @events_api = Trakerr::EventsApi.new(api_client)
    end

    ##
    #Creates a new AppEvent and returns it with a stacktrace if err is an exception object.
    #If passed false, it returns an AppEvent without a stacktrace.
    #RETURNS: An AppEvent instance with the default event information.
    #err:Exception: The exception that is captured or rescued, or false if you don't need a stacktrace.
    #log_level:String: Logging level, currently one of 'debug','info','warning','error', 'fatal', defaults to 'error'. See loglevel in AppEvent for an always current list of values.
    #Will argument error if passed another value.
    #classification:String: Optional extra descriptor string. Will default to issue if not passed a value.
    #eventType:string: String representation of the type of error.
    #Defaults to err.class.name if err is an exception, unknown if not.
    #eventMessage:String: String representation of the message of the error.
    #Defaults to err.message if err is an exception, unknown if not.
    ##
    def create_app_event(err = false, log_level="Error", classification="issue", eventType="unknown", eventMessage="unknown")
      raise ArgumentError, "All non err arguments are expected strings." unless (log_level.is_a? String) && (classification.is_a? String) && (eventType.is_a? String) && (eventMessage.is_a? String)
      if err != false
        raise ArgumentError, "err is expected instance of exception." unless err.is_a? Exception
     
        eventType = err.class.name if eventType == "unknown" || eventType == ""
    
        eventMessage = err.message if eventMessage == "unknown" || eventMessage == ""

      end

      log_level = log_level.downcase

      app_event_new = AppEvent.new({classification: classification, eventType: eventType, eventMessage: eventMessage})

      begin
        app_event_new.log_level = log_level
      rescue ArgumentError
        app_event_new.log_level = "error"
      end
      
      app_event_new.event_stacktrace = EventTraceBuilder.get_stacktrace(err) if err != false

      return app_event_new
    end
    
    ##
    #A single line method to send an event to trakerr.
    #Use may it in a begin-rescue and pass in an error,
    #or set error to false if you don't need a stacktrace.
    #arg_hash takes in a few common values that you may want to populate
    #your app event with in a hash.
    #arg_hash:Hash: A hash with a key value pair for each of the following elements
    #{"user": "...", "session": "...", "evntname": "...", "evntmessage": "..."}.
    #Omit any element you don't need to fill in the event.
    #If you are NOT sending an error it is recommended that you pass in an evntname and evntmessage.
    #Remember that all keys are expected strings, and so it may be safer to you use the arrow
    #operator (=>) so you don't forget to add the space.
    #error:Exception: The exception you may be sending. Set this to false if you are sending a non-error.
    #This throws an Argument error if error is not an Exception and it's child classes or false.
    #log_level:String: The string representation of the level of the error.
    #classification:String: The string representation on the classification of the issue.
    ##
    def log(arg_hash, error, log_level = "error", classification = "issue")
      raise ArgumentError, "arg_hash is expected to be a hash" unless arg_hash.is_a? Hash
      raise ArgumentError, "log_level and classification is expected strings." unless (log_level.is_a? String) && (classification.is_a? String)

      app_event = nil
      if error != false
        raise ArgumentError, "err is expected instance of exception." unless error.is_a? Exception
        app_event = create_app_event(error, log_level, classification, arg_hash.fetch("evntname", "unknown"), arg_hash.fetch("evntmessage", "unknown"))
        
      end
      app_event = create_app_event(false,log_level, classification, arg_hash.fetch("evntname", "unknown"), arg_hash.fetch("evntmessage", "unknown")) if app_event.nil?
      app_event.event_user = arg_hash["user"] if arg_hash.has_key? "user"
      app_event.event_session = arg_hash["session"] if arg_hash.has_key? "session"

      send_event(app_event)
    end

    ##
    #Sends the given AppEvent to Trakerr
    #appEvent:AppEvent: The AppEvent to send.
    ##
    def send_event(appEvent)
      @events_api.events_post(fill_defaults(appEvent))
    end

    ##
    #Populates the given AppEvent with the client level default values
    #RETURNS: The AppEvent with Defaults filled.
    #appEvent:AppEvent: The AppEvent to fill.
    ##
    def fill_defaults(appEvent)
      appEvent.api_key = appEvent.api_key || @api_key

      appEvent.context_app_version = appEvent.context_app_version || @context_app_version
      appEvent.deployment_stage = appEvent.deployment_stage || @context_deployment_stage

      appEvent.context_env_language = appEvent.context_env_language || @context_env_language
      appEvent.context_env_name = appEvent.context_env_name || @context_env_name
      appEvent.context_env_version = appEvent.context_env_version || @context_env_version
      appEvent.context_env_hostname = appEvent.context_env_hostname || @context_env_version

      appEvent.context_app_os = appEvent.context_app_os || @context_app_os
      appEvent.context_app_os_version = appEvent.context_app_os_version || @context_app_os_version

      appEvent.context_app_browser = appEvent.context_app_browser || @context_app_browser
      appEvent.context_app_browser_version = appEvent.context_app_browser_version || @context_app_browser_version

      appEvent.context_data_center = appEvent.context_data_center || @context_data_center
      appEvent.context_data_center_region = appEvent.context_data_center_region || @context_data_center_region

      appEvent.event_time = DateTime.now.strftime("%Q").to_i
      return appEvent
    end

    private
      ##
      #Used for parsing large strings. Gets the text in between a prefix string and a suffix string.
      #Currently used to parse responses from shell commands on OS.
      #RETURNS: The String from text between prefix and suffix or nil if not found or errors occur.
      #text:String: The text to search in.
      #prefix:String: The prefix string to start getting the text after
      #suffix:String: The suffix string to find the ending index for.
      ##
      def get_text_from_line(text, prefix, suffix)
        raise ArgumentError, "All arguments are expected strings." unless (text.is_a? String) && (prefix.is_a? String) && (suffix.is_a? String)
      
        prefixindex = text.index(prefix)
        return nil if prefixindex == nil
        prefixindex = prefixindex + prefix.length

        suffixindex = text.index(suffix, prefixindex)
        return nil if suffixindex == nil

        text[prefixindex...suffixindex]
      end
  end
end