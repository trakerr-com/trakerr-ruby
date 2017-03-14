# Trakerr::AppEvent

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**api_key** | **String** | API key generated for the application | 
**log_level** | **String** | (optional) Logging level, one of &#39;debug&#39;,&#39;info&#39;,&#39;warning&#39;,&#39;error&#39;, &#39;fatal&#39;, defaults to &#39;error&#39; | [optional] 
**classification** | **String** | (optional) one of &#39;error&#39; or a custom string for non-errors, defaults to &#39;error&#39; | 
**event_type** | **String** | type of the event or error (eg. NullPointerException) | 
**event_message** | **String** | message containing details of the event or error | 
**event_time** | **Integer** | (optional) event time in ms since epoch | [optional] 
**event_stacktrace** | [**Stacktrace**](Stacktrace.md) |  | [optional] 
**event_user** | **String** | (optional) event user identifying a user | [optional] 
**event_session** | **String** | (optional) session identification | [optional] 
**context_app_version** | **String** | (optional) application version information | [optional] 
**deployment_stage** | **String** | (optional) deployment stage, one of &#39;development&#39;,&#39;staging&#39;,&#39;production&#39; or a custom string | [optional] 
**context_env_name** | **String** | (optional) environment name (like &#39;cpython&#39; or &#39;ironpython&#39; etc.) | [optional] 
**context_env_language** | **String** | (optional) language (like &#39;python&#39; or &#39;c#&#39; etc.) | [optional] 
**context_env_version** | **String** | (optional) version of environment | [optional] 
**context_env_hostname** | **String** | (optional) hostname or ID of environment | [optional] 
**context_app_browser** | **String** | (optional) browser name if running in a browser (eg. Chrome) | [optional] 
**context_app_browser_version** | **String** | (optional) browser version if running in a browser | [optional] 
**context_app_os** | **String** | (optional) OS the application is running on | [optional] 
**context_app_os_version** | **String** | (optional) OS version the application is running on | [optional] 
**context_data_center** | **String** | (optional) Data center the application is running on or connected to | [optional] 
**context_data_center_region** | **String** | (optional) Data center region | [optional] 
**custom_properties** | [**CustomData**](CustomData.md) |  | [optional] 
**custom_segments** | [**CustomData**](CustomData.md) |  | [optional] 


