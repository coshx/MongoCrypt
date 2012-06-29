#!/usr/bin/env ruby
require File.expand_path("../../Command/helpers/aws_connect/aws.rb", __FILE__)
require File.expand_path("../../Model/registrar", __FILE__)
credentials = YAML.load(File.read("credentials.yml"))
key = { :aws_secret_access_key => credentials['aws_secret_access_key'], :aws_access_key_id => credentials['aws_access_key_id'], :provider => "AWS" }

Server = AWS::Server.new(key)
Resource = Registrar::Registrar.new

@create_server_response = Server.create_instance(:ami => 'ami-e565ba8c', :InstanceType => 'm1.large', :SecurityGroup => 'database', :KeyName => 'sandbox-keypair', :region => 'us-east-1a')
@resource_id = Resource.create_instance(:create_server_response => @create_server_response.body)
@instance_id = Resource.find_by_id(:id => @resource_id).first['reservationSet'].last['instancesSet'].last['instanceId']
@volume_one = Server.create_volume('us-east-1a', '1').body['volumeId']
@volume_two = Server.create_volume('us-east-1a', '1').body['volumeId']
Server.attach_volume(@instance_id, @volume_one, 'sdh1')
Server.attach_volume(@instance_id, @volume_two, 'sdf1')
puts Resource.find_by_id(:id => @resource_id).first['reservationSet'].last['instancesSet'].last['dnsName']+" is now online."



