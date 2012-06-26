#!/usr/bin/env ruby

#require "#{File.dirname(__FILE__)}/db/resource.rb"
#require "#{File.dirname(__FILE__)}/lib/compute.rb"

requirerelative '/db/resource'
requirerelative 'lib/compute'

credentials = YAML.load(File.read("credentials.yml"))
key = { :aws_secret_access_key => credentials['aws_secret_access_key'], :aws_access_key_id => credentials['aws_access_key_id'], :provider => "AWS" }

Server = AWS::Server.new(key)
Resource = LocalDatabase::Resource.new


#http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference-query-DescribeInstances.html
#http://rubydoc.info/gems/fog/1.3.1/Fog/Compute/AWS/Real

#@server = Server.create(:ami => 'ami-e565ba8c', :InstanceType => 'm1.large', :SecurityGroup => 'database', :KeyName => 'sandbox-keypair', :zone => 'us-east-1a')
#@server = Server.find(:ip => @server.ip)  #  -> where find() is Server class method and returns json respresentation
#puts Resource.find_by_id(:id => @resource_id).first.inspect
#puts Resource.find("_id" =>  @resource_id).first.inspect

#@resource_id = Resource.create(:server => @server) #.body?
=begin
@server = Server.createServer(:ami => 'ami-e565ba8c', :InstanceType => 'm1.large', :SecurityGroup => 'database', :KeyName => 'sandbox-keypair', :zone => 'us-east-1a')
@server.body['reservationSet'].last['instancesSet'].last['launchTime'] = Time.now.to_s
@server.body['reservationSet'].last['instancesSet'].last['blockDeviceMapping'].last['attachTime'] = Time.now.to_s
@resource_id = Resource.create(:server => @server.body)
@instance_id = Resource.find_by_id(:id => @resource_id).first['reservationSet'].last['instancesSet'].last['instanceId']
@volume_one = Server.createVolume(:region => 'us-east-1a', :size => '1')
@volume_two = Server.createVolume(:region => 'us-east-1a', :size => '1')
Server.attachVolume(:instance_id => @instance_id,:volume_id => @volume_one.body['volumeId'], :device_name=> 'sdh1')
Server.attachVolume(:instance_id => @instance_id,:volume_id => @volume_two.body['volumeId'], :device_name=> 'sdh2')
puts Resource.find_by_id(:id => @resource_id).first['reservationSet'].last['instancesSet'].last['dnsName']+" is now online."
=end


#Resource.find().each { |row|
#  puts Server.delete(:instance_id => row['reservationSet'].last['instancesSet'].last['instanceId']).body['reservationSet'].first['instancesSet'].first['instanceState']
#}

#puts Server.findInstance_by_id(:id => 'i-b2043ccb').body['reservationSet'].first['instancesSet'].first['instanceState']

#puts Server.delete(:instance_id => 'i-d0073fa9' )

#).body['reservationSet'].first['instancesSet'].first['instanceState']['name'] == 'running'
#return @compute.describe_instances( 'instance-id' => options[:id])

def delete_all_volumes

  volume =  Server.findVolume().body['volumeSet'].first['attachmentSet'].first['volumeId']
  puts volume

  if(volume)
    delete_all_volumes
  end
end


 # instance = Server.find('instance-state-name'=>"running").body['reservationSet'].last['instancesSet'].last['instanceId']
#  Server.delete(:instance_id => instance)

delete_all_volumes
