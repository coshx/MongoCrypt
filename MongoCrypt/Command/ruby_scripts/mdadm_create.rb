require 'net/ssh'

	Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec('sudo mdadm --verbose --create /dev/md11 --level=1 --chunk=256 --force --raid-devices=1 /dev/sdh11') do |ch, success|
     abort "error" unless success
     channel.on_data do |ch, data|
       puts "#{data}"
        if data.include? "Continue creating array?"
          channel.send_data("YES\n");
        end
        end
        
        end
    
    
    
    end
    
    end
