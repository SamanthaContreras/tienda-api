class Product < ActiveRecord::Base
  has_many :entries
  has_many :orders, through: :entries
end