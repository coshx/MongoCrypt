
module LocalDatabase
  require 'mongo'

  class Resource

    def create( options = {})
      collection = db["Resources"]
      return collection.insert(options[:server])
    end

    def find_by_id(options ={})
      collection = db["Resources"]
      return collection.find("_id" => options[:id])
    end

    def find(options ={})
      collection = db["Resources"]
      return collection.find(options)
    end

    private
    def db
      return Mongo::Connection.new("localhost", 27017).db("Resources")
    end

  end


end