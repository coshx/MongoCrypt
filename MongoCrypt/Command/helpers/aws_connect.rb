module MongoCrypt
  require 'fog'

  class AWSConnect

    def initialize(key)
        @compute = Fog::Compute.new(key)
    end

    def find_instance_by_id(instance_id)
      return @compute.describe_instances( 'instance-id' => instance_id)
    end

    def find_volume_by_id(volume_id)
      return @compute.describe_volumes('volume-id' => volume_id)
    end

    def find_instance(options={})
      return @compute.describe_instances(options)
    end

    def create_tags(instance, tags)
       return @compute.create_tags(instance, tags)
    end

    def create_instance(options={})
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

    def terminate_instance(instance_id)
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

    def luksFormat(ip,md_device_number)

      Net::SSH.start(ip, 'ec2-user') do|session|
        session.open_channel do |channel|
        channel.request_pty do |c, success|
          if success
            puts 'request_pty successful'
          end
        end
        channel.exec("sudo cryptsetup -y luksFormat /dev/md#{md_device_number}") do |ch, success|
         abort "could not execute 'cryptsetup -y luksFormat' command" unless success

         channel.on_data do |data|
            if data.include? "Are you sure?"
              channel.send_data("YES\n");
            end
            if data.include? "Enter LUKS passphrase:"
              channel.send_data("passphrase\n");
            end
            if data.include? "Verify passphrase:"
              channel.send_data("passphrase\n");
            end
          end
          channel.on_close do |ch|
            puts "channel is closing!"
          end
        end

        end
      end
    end






  end
end
