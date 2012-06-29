module MongoCrypt

  require File.expand_path("../../Model/registrar.rb", __FILE__)
  require File.expand_path("../../Command/helpers/aws_connect.rb", __FILE__)
  credentials = YAML.load(File.read("credentials.yml"))
  key = { :aws_secret_access_key => credentials['aws_secret_access_key'], :aws_access_key_id => credentials['aws_access_key_id'], :provider => "AWS" }

  Registrar =  MongoCrypt::Registrar.new
  AWSConnect =  MongoCrypt::AWSConnect.new(key)

  class SharedService

    def create

      instance_ip = Registrar.shared_server_ip

      if(instance_ip == nil)
        instance_ip = setup_new_shared_server
        Registrar.shared_server_ip(instance_ip)
      end

      port =  Registrar.available_port(instance_ip)
      password = generate_password

      setup_file_system(instance_ip, heroku_id, port, password)

      #todo AWSConnect.testURI()

      return AWSConnect.find_instance_by_id(heroku_id)
    end

    private
    def generate_password
      return 'password' #I have a password generator to plug in here
    end

    def setup_file_system(heroku_id,instance_ip, port, password)
      AWSConnect.mdadm_create
      AWSConnect.luks_format
      AWSConnect.luks_open
      AWSConnect.pv_create
      AWSConnect.vg_create
      AWSConnect.lv_create
      AWSConnect.mke2fs
      AWSConnect.make_datadir
      AWSConnect.mount_datadir
      AWSConnect.fstab_register
      AWSConnect.set_permissions
    end

    def setup_new_shared_server
      @create_server_response = AWSConnect.create_instance(
                :ami => 'ami-e565ba8c',
                :InstanceType => 'm1.large',
                :SecurityGroup => 'database',
                :region => 'us-east-1a'
            )
      return instance_ip = @create_server_response.body['reservationSet'].first['instancesSet'].first['instanceID']
    end

    def start_mongod(ip, port, id, password, plan_type)  do
         ssh ip -> channel.exec("sudo mongod --ssl --port #{port}  --dbpath=/data#{id}/db/")
         ssh ip -> channel.exec("sudo mongo #{server}:#{new_port}/admin --eval 'printjson(db.addUser(\"#{user}\",\"#{pass}\"))'") do |ch, success|
         todo: when admin password defined, having password can user start up a new database?
         todo: When 'regular' user defined on particular database, can no longer start up a new DB right?-> sandbox plan
         database automagically created when used, should be no need to prep name (which will be db_#{user})
      end

  end

end