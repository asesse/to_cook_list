RSpec.describe Recipe, type: :model do
  subject(:recipe) { build :recipe }

  describe 'Validations' do
    it { is_expected.to be_valid }

    it 'is not valid without a name' do
      recipe.name = nil
      expect(recipe).not_to be_valid
    end

    it 'is not valid without instructions' do 
      recipe.instructions = nil
      expect(recipe).not_to be_valid
    end

    it 'is not valid without portions' do
      recipe.portions = nil
      expect(recipe).not_to be_valid
    end
  end
end