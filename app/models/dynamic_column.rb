class DynamicColumn < ActiveRecord::Base
  attr_accessible :name, :table, :code

  belongs_to :database

  validates :database, presence: true
end
