require 'mongo'

module MongoConnection
  Mongo::Logger.logger.level = ::Logger::FATAL
  def mongo_insert_doc(database_name, collection_name, documents)
    client = Mongo::Client.new('mongodb://172.17.0.2:27017/' + database_name)
    collection = client[collection_name]
    if documents.kind_of?(Array)
      collection.insert_many(documents)
    else
      collection.insert_one(documents)
    end
  end

  def find_document(database_name, collection_name, query)
    client = Mongo::Client.new('mongodb://172.17.0.2:27017/' + database_name)
    collection = client[collection_name]
    result = collection.find( query ).first
  end
end

