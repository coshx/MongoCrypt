module MongoCrypt
require File.expand_path("../../Command/helpers/aws_connect2.rb", __FILE__)
	AWSConnect2 =  MongoCrypt::AWSConnect2.new()

	class Fileup
		def initialize
			AWSConnect2.mdadm_create
      		AWSConnect2.luks_format
      		AWSConnect2.luks_open
      		AWSConnect2.pv_create
      		AWSConnect2.vg_create
      		AWSConnect2.lv_create
      		AWSConnect2.mke2fs
      		AWSConnect2.make_datadir
      		AWSConnect2.tee
      		AWSConnect2.mount_datadir
		end
	end
	class Mongo
		def initialize
			AWSConnect2.gitcore
      		/AWSConnect2.wget
      		AWSConnect2.curl_dev
      		AWSConnect2.scons
      		AWSConnect2.git_clone
      		AWSConnect2.cd_mongo/
		end
	
	end
	end