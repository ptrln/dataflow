class Database < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  attr_accessible :name, :adapter, :encoding, :host, :port, :database_name, :username, :password

  serialize :schema
  serialize :relations

  before_create :build_relations

  RAILS_TABLES = {"schema_migrations" => true}

  def connect
    return if @connected

    ClientBase.establish_connection( 
      adapter: adapter, 
      encoding: encoding, 
      host: host, 
      post: 5432, 
      database: database_name, 
      pool: 5, 
      username: username, 
      password: password)

    @connected = true
  end

  def build_schema
    return self.schema if self.schema

    connect

    schema = Hash.new
    ClientBase.connection.tables.each do |table_name|
      next if RAILS_TABLES.has_key?(table_name)

      klass = Class.new(ClientBase) do
        self.table_name = table_name
      end

      schema[table_name] = klass.columns.map { |c| [c.name, c.type, c.sql_type]}
    end

    self.schema = schema
    self.save

    schema
  end

  def build_relations
    return self.relations if self.relations

    build_schema

    relations = Hash.new { Array.new }

    self.schema.each do |table_name, columns|
      columns.each do |column_name, _1, _2|
        if column_name.match(/.+_id$/)
          relation = column_name.gsub(/_id$/, "")
          if self.schema.has_key?(relation.pluralize)
            relations[table_name] = relations[table_name].push(["belongs_to", relation])
            relations[relation.pluralize] = relations[relation.pluralize].push(["has_many", table_name.pluralize])
          end
        end
      end
    end

    self.relations = relations
    self.save

    relations
  end

  def build_classes
    return if @built_classes

    connect

    build_relations

    self.schema.each do |table_name, _|

      class_name = table_name.classify

      relations = self.relations[table_name]

      klass = Class.new(ClientBase) do
        self.table_name = table_name

        relations.each do |relationship, table_name|
          self.send(relationship, table_name)
        end
      end

      Client.const_set(class_name, klass)
    end

    @built_classes = true
  end
end