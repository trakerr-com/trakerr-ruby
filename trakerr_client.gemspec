# -*- encoding: utf-8 -*-
#
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

$:.push File.expand_path("../lib", __FILE__)
$:.push File.expand_path("../generated/lib", __FILE__)
$:.push File.expand_path("../trakerr/lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "trakerr_client"
  s.version     = "1.0.0r"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Swagger-Codegen"]
  s.email       = [""]
  s.homepage    = "https://github.com/swagger-api/swagger-codegen"
  s.summary     = "Trakerr API Ruby Gem"
  s.description = "Get your application events and errors to Trakerr via the *Trakerr API*."
  s.license     = "Apache-2.0"
  s.required_ruby_version = '>= 1.9.3'

  s.add_runtime_dependency 'typhoeus', '~> 1.0', '>= 1.0.1'
  s.add_runtime_dependency 'json', '~> 1.8', '>= 1.8.3'

  s.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'
  s.add_development_dependency 'vcr', '~> 3.0', '>= 3.0.1'
  s.add_development_dependency 'webmock', '~> 1.24', '>= 1.24.3'
  s.add_development_dependency 'autotest', '~> 4.4', '>= 4.4.6'
  s.add_development_dependency 'autotest-rails-pure', '~> 4.1', '>= 4.1.2'
  s.add_development_dependency 'autotest-growl', '~> 0.2', '>= 0.2.16'
  s.add_development_dependency 'autotest-fsevent', '~> 0.2', '>= 0.2.11'

  #s.files         = `find *`.split("\n").uniq.sort.select{|f| !f.empty? }
  s.files         = `git ls-files`.split("\n").delete_if {|file| file.include? "spec"}
  s.test_files    = `git ls-files`.split("\n").delete_if {|file| not file.include? "spec"}
  s.executables   = []
  s.require_paths = ["generated/lib", "trakerr/lib"]
end
