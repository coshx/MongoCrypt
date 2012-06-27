
require_relative 'db/resource.rb'
require_relative 'aws/compute.rb'

credentials = YAML.load(File.read("credentials.yml"))
key = { :aws_secret_access_key => credentials['aws_secret_access_key'], :aws_access_key_id => credentials['aws_access_key_id'], :provider => "AWS" }

Server = AWS::Server.new(key)
Resource = LocalDatabase::Resource.new

@server = Server.create(:ami => 'ami-e565ba8c', :InstanceType => 'm1.large', :SecurityGroup => 'database', :KeyName => 'sandbox-keypair', :zone => 'us-east-1a')
@resource_id = Resource.create(:server => @server.body)
@instance_id = Resource.find_by_id(:id => @resource_id).first['reservationSet'].last['instancesSet'].last['instanceId']
@volume_one = Server.createVolume(:region => 'us-east-1a', :size => '1')
@volume_two = Server.createVolume(:region => 'us-east-1a', :size => '1')
Server.attachVolume(:instance_id => @instance_id,:volume_id => @volume_one.body['volumeId'], :device_name=> 'sdh1')
Server.attachVolume(:instance_id => @instance_id,:volume_id => @volume_two.body['volumeId'], :device_name=> 'sdh2')
puts Resource.find_by_id(:id => @resource_id).first['reservationSet'].last['instancesSet'].last['dnsName']+" is now online."



