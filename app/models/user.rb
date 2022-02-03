# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :stock
  has_many :recipes
  validates :username, :email, presence: true
  VALID_EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP
  validates :email, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :stock, presence: true
end

