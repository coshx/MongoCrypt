
module AWS
  require 'fog'

  class Server

    def initialize(key)
       @compute = Fog::Compute.new(key)
    end

    def find_by_instance_id(instance_id)
      return @compute.describe_instances( 'instance-id' => instance_id)
    end

    def find_by_volume_id(volume_id)
      return @compute.describe_volumes('volume-id' => volume_id)
    end

    def find(options={})
      return @compute.describe_instances(options)
    end

    def create_tags(instance, tags)
       return @compute.create_tags(instance, tags)
    end

    def create(options={})
      server_data = @compute.run_instances(
            options[:ami], 1, 1,
            'InstanceType' => options[:InstanceType],
            'SecurityGroup' => options[:SecurityGroup],
            'KeyName' => options[:KeyName] ,
            'Placement.AvailabilityZone' => options[:region]
        ).body['instancesSet'].first
      sleep 3
       until @compute.describe_instances(
          'instance-id' => server_data['instanceId']
          ).body['reservationSet'].first['instancesSet'].first['instanceState']['name'] == 'running'
        end
      server = @compute.describe_instances('instance-id' => server_data['instanceId'])
      server.body['reservationSet'].last['instancesSet'].last['launchTime'] = Time.now.to_s
      if(server.body['reservationSet'].last['instancesSet'].last['blockDeviceMapping']!=[])
        server.body['reservationSet'].last['instancesSet'].last['blockDeviceMapping'].last['attachTime'] = Time.now.to_s
      end
      puts 'Server created: '+server_data['instanceId'].to_s
      return server
    end

    def delete(instance_id)
      server_data = @compute.terminate_instances(instance_id).body['instancesSet'].first
      begin
        until result = @compute.describe_instances(
           'instance-id' => server_data['instanceId']
            ).body['reservationSet'].first['instancesSet'].first['instanceState']['name'] == 'terminated'
        end
      rescue ; puts "\nServer terminated: "+server_data['instanceId'].to_s ; return true ; end #only happens when mocked
      puts "\nServer terminated: "+server_data['instanceId'].to_s
      return result
    end

    def create_volume(region, size)
      volume_data = @compute.create_volume(region,size)
      sleep 3
      until @compute.describe_volumes('volume-id' => volume_data.body['volumeId']).body['volumeSet'].first['status'] == 'available'
      end
      puts "\nVolume created: "+volume_data.body['volumeId'].to_s
      return volume_data
    end

    def detach_volume(volume_id)
      @compute.detach_volume(volume_id)
      until result = @compute.describe_volumes('volume-id' => volume_id).body['volumeSet'].first['status'] == 'available' ; end
      puts "\nDetached "+volume_id
      return result
    end

    def delete_volume(volume_id)
      @compute.delete_volume(volume_id)
      begin
        until result = @compute.describe_volumes('volume-id' => volume_id).body['volumeSet'].first['status'] != 'deleting';end
      rescue ; puts "\nVolume deleted: "+volume_id ; return true ; end #only happens when mocked
      puts "\nServer terminated: "+server_data['instanceId'].to_s
      return result
    end

    def attach_volume(instance_id, volume_id, device_name)
      @compute.attach_volume(instance_id, volume_id, device_name)
      until result = @compute.describe_volumes('volume-id' => volume_id).body['volumeSet'].first['status'] == 'in-use' ; end
      if instance_id == @compute.describe_volumes('volume-id' => volume_id).body['volumeSet'].first['attachmentSet'].first['instanceId']
        puts "\n"+volume_id.to_s+' attached to '+instance_id.to_s
      else
        puts "\nVolume attachment error: "+volume_id.to_s+' did not attach to '+instance_id.to_s ;
      end

      return result
    end

  end

end
