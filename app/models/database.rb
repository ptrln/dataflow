class Database < ActiveRecord::Base
  attr_accessible :name, :adapter, :encoding, :host, :port, :database_name, :username, :password

  serialize :schema
  serialize :relations

  after_create :build_schema_and_relations

  def connection

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