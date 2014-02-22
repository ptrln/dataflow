class PostgreSqlBuilder < SqlBuilder

  def initialize(database)
    @database = database
  end

  def build_schema
    return {}
  end

  def build_relations
    return {}
  end

  def self.list_tables
    "SELECT * FROM information_schema.tables WHERE table_schema = 'public'"
  end

end