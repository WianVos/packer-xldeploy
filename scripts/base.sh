#!/bin/sh
set -x

#update ubuntu 
sudo apt-get -y update
sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get -y install puppet