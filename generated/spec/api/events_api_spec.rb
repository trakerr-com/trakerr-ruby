=begin
#Trakerr API

#Get your application events and errors to Trakerr via the *Trakerr API*.

OpenAPI spec version: 1.0.0

Generated by: https://github.com/swagger-api/swagger-codegen.git

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

require 'spec_helper'
require 'json'

# Unit tests for Trakerr::EventsApi
# Automatically generated by swagger-codegen (github.com/swagger-api/swagger-codegen)
# Please update as you see appropriate
describe 'EventsApi' do
  before do
    # run before each test
    @instance = Trakerr::EventsApi.new
  end

  after do
    # run after each test
  end

  describe 'test an instance of EventsApi' do
    it 'should create an instact of EventsApi' do
      expect(@instance).to be_instance_of(Trakerr::EventsApi)
    end
  end

  # unit tests for events_post
  # Submit an application event or error to Trakerr
  #  The events endpoint submits an application event or an application error / exception with an optional stacktrace field to Trakerr.  ##### Sample POST request body: &#x60;&#x60;&#x60; {  \&quot;apiKey\&quot;: \&quot;a9a2807a2e8fd4602adae9e8f819790a267213234083\&quot;,  \&quot;classification\&quot;: \&quot;Error\&quot;,  \&quot;eventType\&quot;: \&quot;System.Exception\&quot;,  \&quot;eventMessage\&quot;: \&quot;This is a test exception.\&quot;,  \&quot;eventTime\&quot;: 1479477482291,  \&quot;eventStacktrace\&quot;: [    {      \&quot;type\&quot;: \&quot;System.Exception\&quot;,      \&quot;message\&quot;: \&quot;This is a test exception.\&quot;,      \&quot;traceLines\&quot;: [        {          \&quot;function\&quot;: \&quot;Main\&quot;,          \&quot;line\&quot;: 19,          \&quot;file\&quot;: \&quot;TrakerrSampleApp\\\\Program.cs\&quot;        }      ]    }  ],  \&quot;contextAppVersion\&quot;: \&quot;1.0\&quot;,  \&quot;contextEnvName\&quot;: \&quot;development\&quot;,  \&quot;contextEnvHostname\&quot;: \&quot;trakerr.io\&quot;,  \&quot;contextAppOS\&quot;: \&quot;Win32NT Service Pack 1\&quot;,  \&quot;contextAppOSVersion\&quot;: \&quot;6.1.7601.65536\&quot; } &#x60;&#x60;&#x60; ##### Sample POST response body (200 OK): &#x60;&#x60;&#x60; { } &#x60;&#x60;&#x60;
  # @param data Event to submit
  # @param [Hash] opts the optional parameters
  # @return [nil]
  describe 'events_post test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

end
