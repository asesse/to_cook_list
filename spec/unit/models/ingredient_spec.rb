require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  subject(:ingredient) { build :ingredient }

  describe 'Validations' do
    
    it 'has a valid factory' do
      expect(ingredient).to be_valid
    end
    
    it 'is not valid without a name' do
      ingredient.name = nil
      expect(ingredient).not_to be_valid
    end

    it 'is not valid if name already exist' do
      create(:ingredient, name: 'tomatoe')
      ingredient.name = 'tomatoe'
      expect(ingredient).not_to be_valid
    end
  end
end