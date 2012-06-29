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

      channel.exec("sudo mongod --port 27017  --dbpath=/data/db/") do |ch, success|
       abort "could not execute mongod command" unless success

       channel.on_data do |ch, data|
         puts "got stdout: #{data}"
       end

       channel.on_extended_data do |ch, type, data|
         puts "got stderr: #{data}"
       end

       channel.on_close do |ch|
         puts "channel is closing!"
       end
     end

   end
end

