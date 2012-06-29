module MongoCrypt

require 'mongo'

class Registrar

      def initialize
        @db = Mongo::Connection.new("localhost", 27017).db("mongocrypt_records")
        @service_records = @db["@service_records"]
        @registry = @db["registry"]
      end

      def create_record(active_service)
         return @service_records.insert(active_service)
      end

      def available_port(instance_ip)
         #todo check for available ports on shared servers (some mongods having been shut down)
         #todo This will not work with more than one shared server instance
        return @service_records.count() + 27017
      end

      def shared_server_ip
        return @registry.find(:key => "shared_server_ip")
      end

      def shared_server_ip(ip)
        return @registry.insert({:key => "shared_server_ip", :value => ip})
      end

      def size
        return @service_records.count()
      end

  end
end