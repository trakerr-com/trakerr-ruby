#!/bin/bash

sudo gem uninstall trakerr_client
rm trakerr_client*.gem
gem build trakerr_client.gemspec
sudo gem install trakerr_client
