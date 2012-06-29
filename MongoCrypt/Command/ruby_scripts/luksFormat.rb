#!/usr/bin/env ruby
require 'net/ssh'

 Net::SSH.start( '23.21.192.227', 'ec2-user') do|session|

    session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end

    user = "admin"
    pass = "wkjenrkwerwe"

    channel.exec("sudo cryptsetup -y luksFormat /dev/md126") do |ch, success|
      abort "could not execute mongo command" unless success

      channel.on_data do |ch, data|
        puts "#{data}"
        if data.include? "Are you sure?"
          channel.send_data("YES\n");
        end
        if data.include? "Enter LUKS passphrase:"
          channel.send_data("passphrase\n");
        end
        if data.include? "Verify passphrase:"
          channel.send_data("passphrase\n");
        end

        #watch -n .5 cat /proc/mdstat
      end


      channel.on_close do |ch|
        puts "channel is closing!"
      end
    end

    end
 end