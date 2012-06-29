module MongoCrypt

require 'json'
require File.expand_path("../../Command/helpers/aws_connect.rb", __FILE__)
key = { :aws_secret_access_key => 'aws_secret_access_key', :aws_access_key_id => 'aws_access_key_id', :provider => "AWS" }

describe "Service" do

  before (:all) do
   Fog.mock!
   Service = MongoCrypt::Service.new(key)
   @create_server_response = Service.create_instance(:ami => 'ami-e565ba8c', :InstanceType => 'm1.large', :SecurityGroup => 'database', :region => 'us-east-1a')
   @test_instance_id = @create_server_response.body['reservationSet'].first['instancesSet'].first['instanceId']
  end

  describe "create" do

    it "returns a Excon::Response object containing valid json" do
      json_object = JSON.parse(@create_server_response.body.to_json)
      json_object.should_not be_nil
    end

    it "returns response containing server instance id" do
      instance_id = @create_server_response.body['reservationSet'].last['instancesSet'].last['instanceId']
      instance_id.should_not be_empty
    end

    it "returns response containing server dns name" do
      instance_id = @create_server_response.body['reservationSet'].first['instancesSet'].first['dnsName']
      instance_id.should_not be_empty
    end

    it "returns response containing server ip address" do
      instance_id = @create_server_response.body['reservationSet'].first['instancesSet'].first['ipAddress']
      instance_id.should_not be_empty
    end

  end

  describe "find_by_instance_id" do
    it "returns the correct instance" do
      _instance_id = AWS.find_instance_by_id(@test_instance_id).body['reservationSet'].first['instancesSet'].first['instanceId']
      _instance_id.should equal @test_instance_id
    end
  end

  describe "find" do
      it "returns the correct instance with aws native filter" do
        aws_native_filer = {'instance-state-name'=>"running"}
        _instance_id = AWS.find_instance(aws_native_filer).body['reservationSet'].first['instancesSet'].first['instanceId']
        _instance_id.should equal @test_instance_id
      end
  end

  describe "create_tags" do

     before(:all) do
       @tag = {'key' => 'value'}
       @create_tags_response = AWSConnect.create_tags(@test_instance_id,@tag).body['return']
     end

     it "should return true" do
        @create_tags_response.should be_true
     end

     it "should install the proper tag" do
        tag = AWS.find_instance_by_id(@test_instance_id).body['reservationSet'].first['instancesSet'].first['tagSet']
        tag['key'].should equal @tag['key']
     end

  end

  context "volume method" do

    before(:all) do
      @volume_create_response = AWSConnect.create_volume('us-east-1a','8')
      @volume_id =  @volume_create_response.body['volumeId']
    end

    describe "create_volume" do

      it "returns a Excon::Response object containing valid json" do
        json_object = JSON.parse(@volume_create_response.body.to_json)
        json_object.should_not be_nil
      end

      it "returns response containing volume id" do
        @volume_id.should_not be_empty
      end

    end

    describe "attach_volume" do

      it "should return true" do
        attach_volume_response = AWS.attach_volume(@test_instance_id, @volume_id , 'sdh1')
        attach_volume_response.should be_true
      end

    end

    describe "find_by_volume_id" do

      it "should return the correct instance" do
        instance = AWSConnect.find_volume_by_id(@volume_id).body['volumeSet'].first['attachmentSet'].first['instanceId']
        instance.should equal @test_instance_id
      end

    end

    describe "detach_volume" do

      it "should return true" do
        detach_volume_response = AWSConnect.detach_volume(@volume_id)
        detach_volume_response.should be_true
      end

    end

    describe "delete_volume" do
      it "should return true" do
        delete_volume_response = AWSConnect.delete_volume(@volume_id)
        delete_volume_response.should be_true
      end
    end


  end



  describe "luksFormat" do
    before(:all) do
          @luksFormat_response = AWSConnect.luksFormat(@test_instance_id)
    end


  end

  describe "delete" do

    before(:all) do
      @delete_server_response = AWSConnect.terminate_instance(@test_instance_id)
    end

    it "should delete a given ec2 instance" do
       @delete_server_response.should  be_true
    end

  end


end
  
end




