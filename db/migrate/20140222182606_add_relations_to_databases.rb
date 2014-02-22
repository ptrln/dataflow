class AddRelationsToDatabases < ActiveRecord::Migration
  def change
    add_column :databases, :relations, :text
  end
end
