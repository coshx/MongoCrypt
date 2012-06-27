#!/usr/bin/env ruby

require_relative 'db/resource.rb'
require_relative 'aws/compute.rb'

#Deploy

credentials = YAML.load(File.read("credentials.yml"))
key = { :aws_secret_access_key => credentials['aws_secret_access_key'], :aws_access_key_id => credentials['aws_access_key_id'], :provider => "AWS" }

Server = AWS::Server.new(key)
Resource = LocalDatabase::Resource.new

#puts Server.find('instance-state-name'=>"running").body

instance = Server.find('instance-state-name'=>"running").body['reservationSet'].last['instancesSet'].last['instanceId']
Server.delete(:instance_id => instance)
#puts Server.label(instance, 'Name' => {:tags =>{:Name => 'hello'}}).body