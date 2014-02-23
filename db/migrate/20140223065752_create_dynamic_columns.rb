class CreateDynamicColumns < ActiveRecord::Migration
  def change
    create_table :dynamic_columns do |t|
      t.integer :database_id
      t.string  :name
      t.string  :table
      t.text    :code

      t.timestamps
    end
  end
end
