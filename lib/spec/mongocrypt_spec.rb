
require 'json'
require File.expand_path("../../db/resource.rb", __FILE__)
require File.expand_path("../../aws/server.rb", __FILE__)
key = { :aws_secret_access_key => 'aws_secret_access_key', :aws_access_key_id => 'aws_access_key_id', :provider => "AWS" }




describe "Server" do

  before (:all) do
   Fog.mock!
   Server = AWS::Server.new(key)
   @server = Server.create(:ami => 'ami-e565ba8c', :InstanceType => 'm1.large', :SecurityGroup => 'database', :zone => 'us-east-1a')
  end

  describe "create" do

    it "responds with an excon response object" do
      json_object = JSON.parse(@server.body.to_json)
      json_object.should_not be_nil
    end

    it "has response containing server instance id" do
      instance_id = @server.body['reservationSet'].last['instancesSet'].last['instanceId']
      instance_id.should_not be_empty
    end

    it "has response containing server dns name" do
      instance_id = @server.body['reservationSet'].last['instancesSet'].last['dnsName']
      instance_id.should_not be_empty
    end

    it "has response containing server ip address" do
      instance_id = @server.body['reservationSet'].last['instancesSet'].last['ipAddress']
      instance_id.should_not be_empty
    end

  end

  describe "find_by_instance_id" do

    before(:all) do
      @test_instance_id = @server.body['reservationSet'].last['instancesSet'].last['instanceId']
    end

    it "returns the correct instance" do
      _instance_id = Server.find_by_instance_id(@test_instance_id).body['reservationSet'].last['instancesSet'].last['instanceId']
      _instance_id.should equal @test_instance_id
    end

  end

end



