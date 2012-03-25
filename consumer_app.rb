require 'mongo'

url = ENV['MONGO_URL'] || 'localhost'
port = ENV['MONGO_PORT'] || 27017
name = ENV['DB_NAME'] || "local"

puts "-MongoDb Info--"

connection = Mongo::Connection.new # (optional host/port args)
connection.database_names.each { |name| puts name }
connection.database_info.each { |info| puts info.inspect}