module MongoCrypt
  require 'fog'

  require File.expand_path("../../Model/registrar.rb", __FILE__)
  require_relative 'aws'

  SharedService =  MongoCrypt::SharedService.new(key)

  class Deploy

    def initialize(plan = 'shared')
        #todo public beta - create additional shared server when more than X number of simultaneous mongod instance on shared server
        #todo public beta - find out X (number of mongods that can run comfortably on a single EC2 instance)
        #todo future goal - additional plan types
        #todo upload services to queue
        #todo test service is online before adding to queue

        instance_json = SharedService.create
        Registrar.record(instance_json)
    end


  end

end


