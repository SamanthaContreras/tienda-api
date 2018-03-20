class Order < ActiveRecord::Base
  belongs_to :user
  has_many :entries, dependent: :destroy
  has_many :products, through: :entries
end