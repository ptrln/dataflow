class PostgreSqlBuilder < SqlBuilder

  def self.list_tables
    "SELECT * FROM information_schema.tables WHERE table_schema = 'public'"
  end

end