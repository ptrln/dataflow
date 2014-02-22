class CreateDatabases < ActiveRecord::Migration
  def change
    create_table :databases do |t|
      t.string  :name
      t.string  :adapter
      t.string  :encoding
      t.string  :host
      t.integer :port
      t.string  :database_name
      t.string  :username
      t.string  :password
      t.text    :schema

      t.timestamps
    end
  end
end