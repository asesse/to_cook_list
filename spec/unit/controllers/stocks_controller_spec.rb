require 'rails_helper'

describe StocksController, type: :controller do
  render_views
  subject { response }

  include_context 'with default headers'

  describe '#show' do
    let(:stock) { create :stock }
    let(:ingredient_quantity) { create(:ingredient_quantity, target: stock) }

    context 'when the stock exists' do
      before do
        stock
        ingredient_quantity
        get :show, params: { id: stock.id }
      end

      it 'renders the right information' do 
        expect(response.parsed_body['ingredients'][0]['name']).to eq(ingredient_quantity.ingredient.name)
        expect(response.parsed_body['ingredients'][0]['quantity']).to eq(ingredient_quantity.quantity)
        expect(response.parsed_body['ingredients'][0]['unit']).to eq(ingredient_quantity.unit)
      end 
      it { is_expected.to be_ok }
    end

    context 'when the stock doesn\'t exist' do
      before do
        get :show, params: { id: -1 }
      end 
      it { is_expected.to be_not_found}

      it 'renders the error' do 
        expect(response.parsed_body['errors']).to eq('stock_not_found')
      end 
    end
  end
end