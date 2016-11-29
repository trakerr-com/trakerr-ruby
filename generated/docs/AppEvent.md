# Trakerr::AppEvent

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**api_key** | **String** | API key generated for the application | 
**classification** | **String** | one of &#39;debug&#39;,&#39;info&#39;,&#39;warning&#39;,&#39;error&#39; or a custom string | 
**event_type** | **String** | type or event or error (eg. NullPointerException) | 
**event_message** | **String** | message containing details of the event or error | 
**event_time** | **Integer** | (optional) event time in ms since epoch | [optional] 
**event_stacktrace** | [**Stacktrace**](Stacktrace.md) |  | [optional] 
**event_user** | **String** | (optional) event user identifying a user | [optional] 
**event_session** | **String** | (optional) session identification | [optional] 
**context_app_version** | **String** | (optional) application version information | [optional] 
**context_env_name** | **String** | (optional) one of &#39;development&#39;,&#39;staging&#39;,&#39;production&#39; or a custom string | [optional] 
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


