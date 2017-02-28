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
      @contextEnvName = contextEnvName
      @contextEnvVersion = contextEnvVersion
      @contextEnvHostname = contextEnvHostname || Socket.gethostname
      @contextAppOS = contextAppOS || RbConfig::CONFIG["target_os"]
      @contextAppOSVersion = contextAppOSVersion
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

  end
end
