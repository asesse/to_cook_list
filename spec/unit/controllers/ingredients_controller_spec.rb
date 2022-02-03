require 'rails_helper'

describe IngredientsController, type: :controller do
  render_views
  subject { response }

  include_context 'with default headers'

  describe '#index' do
    before do 
      create_list(:ingredient, 10)
      get :index
    end
    it 'renders the right amount of ingredients' do
      expect(response.parsed_body["ingredients"].count).to eq(Ingredient.count)
    end
   
    it { is_expected.to be_ok }
  end
end