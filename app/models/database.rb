class Database < ActiveRecord::Base
  attr_accessible :name, :adapter, :encoding, :host, :port, :database_name, :username, :password

  serialize :schema
  serialize :relations

  after_create :build_schema_and_relations

  def connect
    ClientBase.establish_connection( 
      adapter: adapter, 
      encoding: encoding, 
      host: host, 
      post: 5432, 
      database: database_name, 
      pool: 5, 
      username: username, 
      password: password)
  end

  private

  def builder
    @builder ||= SqlBuilder.build(self)
  end

  def build_schema_and_relations
    schema = builder.build_schema
    relations = builder.build_relations
  end
end