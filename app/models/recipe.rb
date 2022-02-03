class Recipe < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: :user_id
  has_many :ingredient_quantities, as: :target, dependent: :destroy
  has_many :ingredients, through: :ingredient_quantities
  accepts_nested_attributes_for :ingredient_quantities, allow_destroy: true
  validates_associated :ingredient_quantities

  validates :name, presence: true
  validates :instructions, presence: true
  validates :portions, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 12, only_integer: true }
end