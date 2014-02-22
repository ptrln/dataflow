class PostgreSqlBuilder < SqlBuilder


  def self.list_tables
    "SELECT * FROM information_schema.tables WHERE table_schema = 'public'"
  end

  def build_schema
    return {}
  end

  def build_relations
    return {}
  end

end