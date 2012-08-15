module MongoCrypt
  require 'net/ssh'
  require 'net/smtp'

  class AWSConnect2
  	def initialize()
  	end
  	def mdadm_create()
  		Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec('sudo mdadm --verbose --create /dev/md10 --level=1 --chunk=256 --raid-devices=1 /dev/sdh10 --force') do |ch, success|
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

 	end
  	def lv_create()
  	Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec('sudo lvcreate -l 100%vg -n data vg10') do |ch, success|
     abort "error" unless success
     channel.on_data do |ch, data|
        puts "#{data}"
        end
        end
    
    
    end
    
    end
  end
  	def make_datadir()
  	Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec('sudo mkdir /data') do |ch, success|
     abort "error" unless success
     channel.on_data do |ch, data|
        puts "#{data}"
        end
        
        
        end
    
    
    
    end
    
    end
  end
  	def mke2fs()
  	Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec('sudo mke2fs -t ext4 -F /dev/vg10/data') do |ch, success|
     abort "error" unless success
     channel.on_data do |ch, data|
        puts "#{data}"
        end
        
        
        end
    
    
    
    end
    
    end

  end
  	def mount_datadir() 
  	Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec("sudo mount /data") do |ch, success|
     abort "error" unless success
     channel.on_data do |ch, data|
        puts "#{data}"
        end
        
        
        end
    
    
    
    end
    
    end

  end
  	def pv_create() 
  	Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec('sudo pvcreate /dev/mapper/enc-pv -ff') do |ch, success|
     abort "error" unless success
     channel.on_data do |ch, data|
        puts "#{data}"
        end
        
        
        end
    
    
    
    end
    
    end

  end
  	def vg_create()
  Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec('sudo vgcreate vg10 /dev/mapper/enc-pv') do |ch, success|
     abort "error" unless success
     channel.on_data do |ch, data|
        puts "#{data}"
        end
        
        
        end
    
    
    
    end
    
    end
  end
  	def tee()
  		Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|

	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    
    
    channel.exec("echo '/dev/vg10/data /data ext4 defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab") do |ch, success|
     abort "error" unless success
     channel.on_data do |ch, data|
        puts "#{data}"
        end
        
        
        end
    
    
    
    end
    
    end
  	end
  	def luks_format()
  		Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|
  		session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end

    user = "admin"
    pass = "wkjenrkwerwe"

    channel.exec("sudo cryptsetup -y luksFormat /dev/md10") do |ch, success|
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
  	end
  	def luks_open()
  	Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|
  		session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end

  
    channel.exec("sudo cryptsetup -y luksOpen /dev/md10 enc-pv") do |ch, success|
      abort "could not do it" unless success

      channel.on_data do |ch, data|
        puts "#{data}"
        if data.include? "Enter passphrase"
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
  	end
  	def gitcore()
  			Net::SSH.start( 'ec2-174-129-23-236.compute-1.amazonaws.com', 'ec2-user',) do|session|
	switch = 0;
	session.open_channel do |channel|

    channel.request_pty do |c, success|
      if success
        puts 'request_pty successful'
      end
    end
    

    channel.exec("sudo su - root") do |ch, success|
     abort "eretror" unless success
     channel.on_data do |ch, data|
       
        puts "#{data}"
        
        case switch 
        	when 0 
        		channel.send_data("sudo yum -y install git-core scons gcc-c++ glibc-devel\n")
        		switch =+ 1
    		when 1
    			if data.strip.eql? "Complete!"
    				switch = switch + 1
    			elsif data.strip.eql? "Nothing to do"
    				switch = 1000
    			end
    		when 2
    			if data.include? "root@"
    				channel.send_data("sudo yum install curl-devel\n");
    				switch = switch + 1
    			end
    		when 3
    			if data.include? "Is this ok"
    				channel.send_data("y\n");
    				switch = switch +1
    			elsif data.strip.eql? "Nothing to do"
    				switch = 1000
    			end
    		when 4
    			if data.strip.eql? "Complete!"
    				switch = switch + 1
    			end
    		when 5
    			if data.include? "root@"
    				channel.send_data("sudo wget -c 'http://downloads.sourceforge.net/project/scons/scons/1.3.0/scons-1.3.0-1.noarch.rpm?use_mirror=ignum'\n");
    				switch = switch + 1
    			end
    		when 6
    			if data.include? "saved"
    				switch = switch + 1
    			elsif data.include? "(try: 5)" 
    				/the number indicates the number of tries it went through/
    				switch = 1000
    			elsif data.strip.eql? "The file is already fully retrieved; nothing to do."
    				switch = 1000
    			end
    		when 7
    			if data.include? "root@"
    				channel.send_data("rpm -i scons-1.3.0-1.noarch.rpm\n");
    				switch = switch + 1
    			end
    		when 8
    			if data.include? "root@"
    				channel.send_data("git clone git://github.com/mongodb/mongo.git\n");
    				switch = switch + 1
    			end
    		when 9
    			if data.include? "Resolving deltas"
    				switch = switch + 1
    			elsif data.strip.eql? "fatal: destination path 'mongo' already exists and is not an empty directory."
    				switch = 1000
    			end
    		when 10
    			if data.include? "root@"
    				channel.send_data("cd mongo\n");
    				switch = switch + 1
    			end
    		when 11
    			if data.include? "root@"
    				channel.send_data("git tag -l\n");
    				switch = switch + 1
    			end
    		when 12
    			if data.include? "r2.2.0-rc0"
    				switch = switch + 1
    			end
    		when 13
    			if data.include? "root@"
    				channel.send_data("git checkout r2.1.1\n");
    				switch = switch + 1
    			end
    		when 14
    			if data.include? "HEAD is now at"
    				switch = switch + 1
    			end
    		when 15
    			if data.include? "root@"
    				channel.send_data("sudo yum install openssl-devel\n");
    				switch = switch + 1
    			end
    		when 16
    			if data.strip.eql? "Is this ok [y/N]:"
    				channel.send_data("y\n");
    				switch = switch + 1
    			elsif data.strip.eql? "Nothing to do"
    				switch = 1000
    			end
    		when 17
    			if data.strip.eql? "Complete!"
    				switch = switch + 1
    			end
    		when 18
    			if data.include? "root@"
    				channel.send_data("scons all --ssl \n");
    				switch = switch + 1
    			end
    		when 19
    			if data.strip.eql? "scons: done building targets."
    				switch = switch + 1
    			end
    		when 20
    			if data.include? "root@"
    				channel.send_data("sudo scons --prefix=/opt/mongo --ssl install\n");
    				switch = switch + 1
    			end
    		when 21
    			if data.strip.eql? "scons: done building targets."
    				switch = switch + 1
    			end
    		when 22
    			if data.include? "root@"
    				channel.send_data("sudo groupadd -r mongod \n");
    				switch = switch + 1
    			end 
    		when 23
    			if data.include? "root@"
    				channel.send_data("sudo useradd -u mongod -g mongod \n");
    				/this username will be different/
    				switch = switch + 1
    			end 
    		when 24
    			if data.include? "root@"
    				channel.send_data("export PATH='$PATH:/opt/mongo/bin/' \n");
    				switch = switch + 1
    			end 
    		when 25
    			if data.include? "root@"
    				channel.send_data("sudo chown mongod:mongod /data \n");
    				switch = switch + 1
    			end 
    		when 26
    			if data.include? "root@"
    				channel.send_data("mkdir data/db \n");
    				switch = switch + 1
    			end
    		when 27
    			exit
    		when 1000
    			/error call here/
    			Net::SMTP.start('smtp.comcast.net', 25) do |smtp|

   					smtp.open_message_stream('jinjimin@gmail.com', 'jinjimin@gmail.com') do |f|
					f.puts 'From: jinjimin@gmail.com'
					f.puts 'To: jinjimin@gmail.com'
      				f.puts 'Subject: test message'
					f.puts 'This is a test message.'

    end
	end
    			exit
    		end    
        end
        
    end
        
              
  
    
    
   
  end
  end
  end
  		  
  
 
  end
  end