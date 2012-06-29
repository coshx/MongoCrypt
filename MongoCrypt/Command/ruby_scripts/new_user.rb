#!/usr/bin/env ruby
 require 'rubygems'
 require 'net/ssh'

 url = ENV['URL'] || '23.21.192.227'


 Net::SSH.start( '23.21.192.227', 'ec2-user') do|session|

    session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end

    user = "admin"
    pass = "wkjenrkwerwe"

    channel.exec("sudo mongo 23.21.192.227:27017/admin --eval 'printjson(db.addUser(\"#{user}\",\"#{pass}\"))'") do |ch, success|
      abort "could not execute mongo command" unless success
      channel.on_data do |ch, data|
        puts "#{data}"
      end
      channel.on_close do |ch|
        puts "channel is closing!"
      end
    end

    end
 end



