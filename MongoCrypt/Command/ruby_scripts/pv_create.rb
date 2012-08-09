require 'net/ssh'

	Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec('sudo pvcreate /dev/md11') do |ch, success|
     abort "error" unless success
     channel.on_data do |ch, data|
        puts "hiii"
        end
        
        
        end
    
    
    
    end
    
    end
