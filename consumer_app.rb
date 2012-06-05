require 'mongo'
require 'uri'

#url = ENV['MONGO_URL'] || 'localhost'
#port = ENV['MONGO_PORT'] || 27017
#name = ENV['DB_NAME'] || "local"

uri = URI.parse(ENV['MONGOCRYPT_URL'])

puts "-MongoDb Info--"

connection = Mongo::Connection.new(uri.host, uri.port, :ssl=>true)
connection.database_names.each { |name| puts name }
connection.database_info.each { |info| puts info.inspect}