class SqlBuilder

  def self.build(database)

    if database.adapter == "postgresql"
      PostgreSqlBuilder.new(database)
    end

  end

end