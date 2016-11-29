# Trakerr::EventsApi

All URIs are relative to *https://www.trakerr.io/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**events_post**](EventsApi.md#events_post) | **POST** /events | Submit an application event or error to Trakerr


# **events_post**
> events_post(data)

Submit an application event or error to Trakerr

 The events endpoint submits an application event or an application error / exception with an optional stacktrace field to Trakerr.  ##### Sample POST request body: ``` {  \"apiKey\": \"a9a2807a2e8fd4602adae9e8f819790a267213234083\",  \"classification\": \"Error\",  \"eventType\": \"System.Exception\",  \"eventMessage\": \"This is a test exception.\",  \"eventTime\": 1479477482291,  \"eventStacktrace\": [    {      \"type\": \"System.Exception\",      \"message\": \"This is a test exception.\",      \"traceLines\": [        {          \"function\": \"Main\",          \"line\": 19,          \"file\": \"TrakerrSampleApp\\\\Program.cs\"        }      ]    }  ],  \"contextAppVersion\": \"1.0\",  \"contextEnvName\": \"development\",  \"contextEnvHostname\": \"trakerr.io\",  \"contextAppOS\": \"Win32NT Service Pack 1\",  \"contextAppOSVersion\": \"6.1.7601.65536\" } ``` ##### Sample POST response body (200 OK): ``` { } ```

### Example
```ruby
# load the gem
require 'trakerr_client'

api_instance = Trakerr::EventsApi.new

data = Trakerr::AppEvent.new # AppEvent | Event to submit


begin
  #Submit an application event or error to Trakerr
  api_instance.events_post(data)
rescue Trakerr::ApiError => e
  puts "Exception when calling EventsApi->events_post: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**AppEvent**](AppEvent.md)| Event to submit | 

### Return type

nil (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json



