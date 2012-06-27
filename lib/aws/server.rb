
module AWS
  require 'fog'

  class Server

    def initialize(key)
       @compute = Fog::Compute.new(key)
    end

    def find_by_instance_id(instance_id)
      return @compute.describe_instances( 'instance-id' => instance_id)
    end

    def find(options={})
      return @compute.describe_instances(options)
    end

    def label(instance, tags)
       return @compute.create_tags(instance, tags)
    end

    def create(options={})
      server_data = @compute.run_instances(
            options[:ami], 1, 1,
            'InstanceType' => options[:InstanceType],
            'SecurityGroup' => options[:SecurityGroup],
            'KeyName' => options[:KeyName] ,
            'Placement.AvailabilityZone' => options[:zone]
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

    def delete(options={})
      puts '..terminating '+options[:instance_id]
      server_data = @compute.terminate_instances(
          options[:instance_id]
      ).body['instancesSet'].first
      until @compute.describe_instances(
         'instance-id' => server_data['instanceId']
          ).body['reservationSet'].first['instancesSet'].first['instanceState']['name'] == 'terminated'
      end
      puts 'Server terminated: '+server_data['instanceId'].to_s

      return @compute.describe_instances('instance-id' => server_data['instanceId'])
   end

    def createVolume(options={})
      region = options[:region]
      size = options[:size]
      volume_data = @compute.create_volume(region,size)
      until @compute.describe_volumes('volume-id' => volume_data.body['volumeId']).body['volumeSet'].first['status'] == 'available'
      end
      puts 'Volume created: '+volume_data.body['volumeId'].to_s
      return volume_data
    end

    def deleteVolume(options={})
        puts "...deleting "+options[:volume_id]
        @compute.delete_volume(options[:volume_id])
    end
    def findVolume(options={})
        return @compute.describe_volumes(options)
    end

    def attachVolume(options={})
        instance_id = options[:instance_id]
        volume_id = options[:volume_id]
        device_name = options[:device_name]
        @compute.attach_volume(instance_id, volume_id, device_name)
        until @compute.describe_volumes('volume-id' => volume_id).body['volumeSet'].first['status'] == 'in-use'
        end
        if instance_id == @compute.describe_volumes('volume-id' => volume_id).body['volumeSet'].first['attachmentSet'].first['instanceId']
          puts volume_id.to_s+' attached to '+instance_id.to_s
        else 'Volume attachment error: '+volume_id.to_s+' did not attach to '+instance_id.to_s
        return instance_id == @compute.describe_volumes('volume-id' => volume_id).body['volumeSet'].first['attachmentSet'].first['instanceId']
        end
    end

  end

end
