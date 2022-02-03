class Stock < ApplicationRecord
    has_many :users
    has_many :ingredient_quantities, as: :target, dependent: :destroy
    has_many :ingredients, through: :ingredient_quantities
    validates :invitation_token, uniqueness: true

    before_create :generate_invitation_token

    def generate_invitation_token
      return if self.invitation_token
      token = SecureRandom.alphanumeric(6).upcase
      return self.invitation_token = token if Stock.find_by(invitation_token: token).nil?
      generate_invitation_token
    end
end