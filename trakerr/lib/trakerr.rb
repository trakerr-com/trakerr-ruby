require "event_trace_builder"
require "trakerr_client"
require "socket"
require "date"

module Trakerr
  class TrakerrClient
    def initialize(apiKey,
                   contextAppVersion = "1.0",
                   contextEnvName = "development",
                   contextEnvVersion = nil,
                   contextEnvHostname= nil,
                   contextAppOS= nil,
                   contextAppOSVersion= nil,
                   contextAppBrowser= nil,
                   contextAppBrowserVersion= nil,
                   contextDataCenter= nil,
                   contextDataCenterRegion= nil,
                   url= nil)
      default_config = Trakerr::Configuration.default
      default_config.base_path = url || default_config.base_path
      @apiKey = apiKey
      @contextAppVersion = contextAppVersion
      @contextEnvName = contextEnvName || RbConfig::CONFIG["RUBY_BASE_NAME"]
      @contextEnvVersion = contextEnvVersion || RbConfig::CONFIG["ruby_version"]
      @contextEnvHostname = contextEnvHostname || Socket.gethostname

      @contextAppOS = contextAppOS

      if contextAppOS == nil 
        
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

    def CreateAppEvent(classification = "Error", eventType = "unknown", eventMessage = "unknown")
      app_event_new = AppEvent.new({classification: classification, eventType: eventType, eventMessage: eventMessage})
      return app_event_new
    end

    def CreateError(err, classification = "Error", eventType = "unknown", eventMessage = "unknown")
      if eventType == nil || eventType == "unknown"
        eventType = err.class.name
      end
      if eventMessage == nil || eventMessage == "unknown"
        eventMessage = err.message
      end
      app_event_new = AppEvent.new({classification: classification, eventType: eventType, eventMessage: eventMessage})
      app_event_new.event_stacktrace = EventTraceBuilder.get_stacktrace(err)
      return app_event_new
    end

    def SendEvent(appEvent)
      @events_api.events_post(FillDefaults(appEvent))
    end

    def FillDefaults(appEvent)
      appEvent.api_key = appEvent.api_key || @apiKey

      appEvent.context_app_version = appEvent.context_app_version || @contextAppVersion

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
      def GetTextFromLine(text, prefix, suffix)
        raise ArgumentError, "All arguments are expected strings." unless text.is_a? String and prefix.is_a? String and suffix.is_a? String
      
        prefixindex = text.index(prefix)
        return nil if prefixindex == nil
        prefixindex = prefixindex + prefix.length

        suffixindex = text.index(suffix, prefixindex)
        return nil if suffixindex == nil

        text[prefixindex...suffixindex]
      end
  end
end