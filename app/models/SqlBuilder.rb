class SqlBuilder

  def self.build(database)

    if database.adapter == "postgresql"
      PostgresSqlBuilder.new(database)
    end

  end

end