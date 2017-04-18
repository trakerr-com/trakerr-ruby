require "event_trace_builder"
require "trakerr_client"
require "socket"
require "date"

module Trakerr
  class TrakerrClient

    ##API Key
    attr_accessor :apiKey

    ##App Version of the client the API is tying into.
    attr_accessor :contextAppVersion

    ##Deployment stage of the codebade the API is tying into.
    attr_accessor :contextDeploymentStage

    ##String name of the language being used.
    attr_accessor :contextEnvLanguage

    ##The name of the interpreter
    attr_accessor :contextEnvName

    ## ContextEnvVersion is the version of the interpreter the program is run on.
    attr_accessor :contextEnvVersion

    ## ContextEnvHostname is hostname of the pc running the code.
    attr_accessor :contextEnvHostname

    ## ContextAppOS is the OS the program is running on.
    attr_accessor :contextAppOS

    ## ContextAppOSVersion is the version of the OS the code is running on.
    attr_accessor :contextAppOSVersion

    ## contextAppBrowser is optional MVC and ASP.net applications the browser name the application is running on.
    attr_accessor :contextAppBrowser

    ## contextAppBrowserVersion is optional for MVC and ASP.net applications the browser version the application is running on.
    attr_accessor :contextAppBrowserVersion

    ## ContextDatacenter is the optional datacenter the code may be running on.
    attr_accessor :contextDataCenter

    ## ContextDatacenterRegion is the optional datacenter region the code may be running on.
    attr_accessor :contextDataCenterRegion

    ##
    #Initializes the TrakerrClient class.
    #apiKey:String: Should be your API key string.
    #contextAppVersion:String: Should be the version of your application.
    #contextEnvName:String: Should be the deployment stage of your program.
    ##
    def initialize(apiKey,
                   contextAppVersion = "1.0",
                   contextDeploymentStage = "development")

      default_config = Trakerr::Configuration.default
      default_config.base_path = default_config.base_path

      @apiKey = apiKey
      @contextAppVersion = contextAppVersion
      @contextDeploymentStage = contextDeploymentStage

      @contextEnvLanguage = "Ruby"
      
      if RUBY_PLATFORM == "java"
        @contextEnvName = "jruby"
        @contextEnvVersion = JRUBY_VERSION
      else
        @contextEnvName = "ruby"
        @contextEnvVersion = RUBY_VERSION
      end

      @contextEnvHostname = Socket.gethostname
        
      host_os = RbConfig::CONFIG['host_os']
      case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          text = `systeminfo`

          @contextAppOS = GetTextFromLine(text, "OS Name:", "\n")
          @contextAppOS.chomp! if @contextAppOS != nil
          @contextAppOS.strip! if @contextAppOS != nil

				  version = GetTextFromLine(text, "OS Version:", "\n").split
          version[0].chomp! if version != nil
          version[0].strip! if version != nil
          @contextAppOSVersion = contextAppOSVersion || version[0]

            
        when /darwin|mac os/
          text = `system_profiler SPSoftwareDataType`

          @contextAppOS = GetTextFromLine(text, "System Version:", "(").chomp.strip
				  @contextAppOSVersion = contextAppOSVersion || GetTextFromLine(text, "Kernel Version:", "\n").chomp.strip
            
        when /linux/, /solaris|bsd/
          #uname -s and -r
          @contextAppOS = `uname -s`.chomp.strip
          @contextAppOSVersion = contextAppOSVersion || `uname -r`.chomp.strip
      end

      if @contextAppOS == nil 
        @contextAppOS = RbConfig::CONFIG["target_os"]
      end
      if @contextAppOSVersion == nil
        @contextAppOSVersion = RbConfig::CONFIG['host_os']
      end
      
      @contextAppBrowser = contextAppBrowser
      @contextAppBrowserVersion = contextAppBrowserVersion
      @contextDataCenter = contextDataCenter
      @contextDataCenterRegion = contextDataCenterRegion
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
    def CreateAppEvent(err = false, log_level="Error", classification = "issue", eventType = "unknown", eventMessage = "unknown")
      raise ArgumentError, "All non err arguments are expected strings." unless (log_level.is_a? String) && (classification.is_a? String) && (eventType.is_a? String) && (eventMessage.is_a? String)
      if err != false
        raise ArgumentError, "err is expected instance of exception." unless err.is_a? Exception

        if eventType == nil || eventType == "unknown"
          eventType = err.class.name
        end

        if eventMessage == nil || eventMessage == "unknown"
          eventMessage = err.message
        end

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
    #{"user":"...", "session":"...", "evntname":"...", "evntmessage":"..."}.
    #Omit any element you don't need to fill in the event.
    #If you are NOT sending an error it is recommended that you pass in an evntname and evntmessage
    #error:Exception: The exception you may be sending. Set this to false if you are sending a non-error.
    #This throws an Argument error if error is not an Exception and it's child classes or false.
    #log_level:String: The string representation of the level of the error.
    #classification:String: The string representation on the classification of the issue.
    ##
    def log(arg_hash, error, log_level = "Error", classification = "issue")
      raise ArgumentError, "arg_hash is expected to be a hash" unless arg_hash.is_a? Hash
      raise ArgumentError, "log_level and classification is expected strings." unless (log_level.is_a? String) && (classification.is_a? String)

      app_event = nil
      if error != false
        raise ArgumentError, "err is expected instance of exception." unless err.is_a? Exception
        app_event = CreateAppEvent(error, log_level, classification, arg_hash["evntname"], arg_hash["evntmessage"])
        
      end
      app_event = CreateAppEvent(false,log_level, classification, arg_hash["evntname"], arg_hash["evntmessage"]) if app_event.nil?
      app_event.event_user = arg_hash["user"] if arg_hash.has_key? "user"
      app_event.event_session = arg_hash["session"] if arg_hash.has_key? "session"

      SendEvent(app_event)
    end

    ##
    #Sends the given AppEvent to Trakerr
    #appEvent:AppEvent: The AppEvent to send.
    ##
    def SendEvent(appEvent)
      @events_api.events_post(FillDefaults(appEvent))
    end

    ##
    #Sends the given error to Trakerr. Simplest use case for Trakerr in a catch, uses the default values when sending.
    #You can provide an optional log_level or classification.
    #error:Exception: The exception that is captured or rescued.
    #log_level:String: Logging level, currently one of 'debug','info','warning','error', 'fatal', defaults to 'error'. See loglevel in AppEvent for an always current list of values.
    #classification:String: Optional extra descriptor string. Will default to issue if not passed a value.
    ##
    def SendException(error, log_level = "error", classification = "issue")
      raise ArgumentError, "Error is expected type exception." unless error.is_a? Exception
      raise ArgumentError, "log_level and classification are expected strings" unless (log_level.is_a? String) && (classification.is_a? String)
      
      SendEvent(CreateAppEvent(Error, log_level, classification))
    end

    ##
    #Populates the given AppEvent with the client level default values
    #RETURNS: The AppEvent with Defaults filled.
    #appEvent:AppEvent: The AppEvent to fill.
    ##
    def FillDefaults(appEvent)
      appEvent.api_key = appEvent.api_key || @apiKey

      appEvent.context_app_version = appEvent.context_app_version || @contextAppVersion
      appEvent.deployment_stage = appEvent.deployment_stage || @contextDeploymentStage

      appEvent.context_env_language = appEvent.context_env_language || @contextEnvLanguage
      appEvent.context_env_name = appEvent.context_env_name || @contextEnvName
      appEvent.context_env_version = appEvent.context_env_version || @contextEnvVersion
      appEvent.context_env_hostname = appEvent.context_env_hostname || @contextEnvHostname

      appEvent.context_app_os = appEvent.context_app_os || @contextAppOS
      appEvent.context_app_os_version = appEvent.context_app_os_version || @contextAppOSVersion

      appEvent.context_app_browser = appEvent.context_app_browser || @contextAppBrowser
      appEvent.context_app_browser_version = appEvent.context_app_browser_version || @contextAppBrowserVersion

      appEvent.context_data_center = appEvent.context_data_center || @contextDataCenter
      appEvent.context_data_center_region = appEvent.context_data_center_region || @contextDataCenterRegion

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
      def GetTextFromLine(text, prefix, suffix)
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