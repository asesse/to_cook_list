require 'rails_helper'

describe Stocks::IngredientsController, type: :controller do
  render_views
  subject { response }

  include_context 'with default headers'

  describe '#create' do
    let(:stock) { create :stock }
    let(:stock_id) { stock.id }
    let(:ingredient) { create :ingredient }
    let(:ingredient2) { create :ingredient }
    let(:ingredient_id) { ingredient.id }
    let(:ingredient_id_2) { ingredient2.id }
    let(:quantity) { rand(1..5) } 
    let(:unit) { IngredientQuantity::UNITS.sample }
    let(:params) do 
      { 
        stock_id: stock_id,
        ingredients: [{ 
          ingredient_id: ingredient_id, 
          quantity: quantity,
          unit: unit
        }, { 
          ingredient_id: ingredient_id_2, 
          quantity: quantity,
          unit: unit
        }] 
      }
    end
    context 'when saved' do
      before do
        post :create, params: params
      end

      it 'correctly add an ingredient to stock' do
        expect(stock.ingredients.count).to eq(2)
      end

      it 'adds the right ingredient' do 
        expect(stock.ingredients.first.id).to eq(ingredient.id)  
      end

      it 'renders the correct information' do
        expect(response.parsed_body['ingredients'][0]['name']).to eq(ingredient.name)
        expect(response.parsed_body['ingredients'][0]['quantity']).to eq(params[:ingredients][0][:quantity])
        expect(response.parsed_body['ingredients'][0]['unit']).to eq(params[:ingredients][0][:unit])  
      end
    end

    context 'when ingredient already exist' do

      before do
      IngredientQuantity.create(ingredient_id: ingredient_id, target: stock, quantity: 2, unit: unit )
      post :create, params: params
      end
      it 'adds the new quantity to the existing quantity' do
        expect(response.parsed_body['ingredients'][0]['quantity']).to eq(quantity + 2)
      end
    end  

    context 'when stock not found' do
      let(:stock_id) { 1 }
      before do
        post :create, params: params 
      end

      it 'renders an error' do 
        expect(response.parsed_body['errors']).to eq('resource_not_found')
      end

      it { is_expected.to be_unprocessable }
    end


    context 'when ingredient not found' do
      let(:ingredient_id) { "bonjour" }
      before do
        post :create, params: params 
      end
      it 'does not create an ingredient' do
        expect(stock.ingredients.count).to eq(0)
      end

      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq({"ingredient"=>[{"error"=>"blank"}]})
      end

      it { is_expected.to be_unprocessable }
    end

    context 'when quantity is blank' do
      let(:quantity) { " " }
      before do
        post :create, params: params 
      end
      it 'does not create an ingredient' do
        expect(stock.ingredients.count).to eq(0)
      end

      it 'redners an error' do
        expect(response.parsed_body['errors']).to eq({"quantity"=>[{"error"=>"blank"}, {"error"=>"not_a_number", "value"=>" "}]})
      end

      it { is_expected.to be_unprocessable }
    end

    context 'when unit is blank' do
      let(:unit) { " " }
      before do
        post :create, params: params 
      end
      it 'does not create an ingredient' do
        expect(stock.ingredients.count).to eq(0)
      end

      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq({"unit"=>[{"error"=>"inclusion", "value"=>" "}]})
      end

      it { is_expected.to be_unprocessable }
    end
  end

  describe '#update' do
    let(:ingredient_quantity) { create :ingredient_quantity }
    let(:quantity) { ingredient_quantity.quantity + 1 }
    let(:unit) { (IngredientQuantity::UNITS - [ingredient_quantity.unit]).sample }
    let(:stock_id) { ingredient_quantity.target.id }
    let(:ingredient_id) { ingredient_quantity.ingredient.id }
    let(:params) do
      { stock_id: stock_id,
        ingredient_id: ingredient_id,
        ingredient: {
          quantity: quantity,
          unit: unit
        }
      }
    end

    before do
      patch :update, params: params
    end
    
    context 'when ingredient is updated' do
      
      it 'correctly updates the ingredient' do 
        ingredient_quantity.reload
        expect(ingredient_quantity.quantity).to eq(quantity)
        expect(ingredient_quantity.unit).to eq(unit)
      end
    end

    context 'when setting quantity to 0' do
      let(:quantity) { 0 }

      it 'destroy the ingredient' do 
        expect(Stock.last.ingredients.count).to eq(0)
      end

      it { is_expected.to be_ok }

      it 'renders' do
        expect(response.parsed_body['ingredients']).to eq([])
      end
    end

    context 'when does not find stock' do 
      let(:stock_id) { -1 }
      it 'does not update' do
        ingredient_quantity.reload
        expect(ingredient_quantity.quantity).not_to eq(quantity)
        expect(ingredient_quantity.unit).not_to eq(unit)
      end

      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq('resource_not_found')
      end
      it { is_expected.to be_unprocessable }
    end

    context 'when does not find ingredient' do
      let(:ingredient_id) { -2 }

      it 'does not update' do
        ingredient_quantity.reload
        expect(ingredient_quantity.quantity).not_to eq(quantity)
        expect(ingredient_quantity.unit).not_to eq(unit)
      end

      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq('resource_not_found')
      end

      it { is_expected.to be_unprocessable }
    end

    context 'when quantity is blank' do
      let(:quantity) { "" }

      it 'does not update' do
        ingredient_quantity.reload
        expect(ingredient_quantity.quantity).not_to eq(quantity)
        expect(ingredient_quantity.unit).not_to eq(unit)
      end
      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq({"quantity"=>[{"error"=>"blank"}, {"error"=>"not_a_number", "value"=>""}]})
      end

      it { is_expected.to be_unprocessable }
    end

    context 'when unit is blank' do
      let(:unit) { "" }

      it 'does not update' do
        ingredient_quantity.reload
        expect(ingredient_quantity.quantity).not_to eq(quantity)
        expect(ingredient_quantity.unit).not_to eq(unit)
      end

      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq({"unit"=>[{"error"=>"inclusion", "value"=>""}]})
      end

      it { is_expected.to be_unprocessable }
    end
  end

  describe '#destroy' do
    let(:stock) { create :stock }
    let(:ingredient_quantity) { create :ingredient_quantity, target: stock }
    let(:stock_id) { ingredient_quantity.target.id }
    let(:ingredient_id) { ingredient_quantity.ingredient.id }
    let(:params) do
      { stock_id: stock_id,
        ingredient_id: ingredient_id
      }
    end

    before do
      delete :destroy, params: params
    end
    context 'when stock exists' do
      it 'correctly deletes the ingredient_quantity' do
        expect(stock.ingredients.count).to eq(0)
      end

      it { is_expected.to be_ok }
    end

    context 'when the stock does not exist' do
      let(:stock_id) { -1 }
      it 'does not delete the ingredient_quantity' do
        expect(stock.ingredients.count).to eq(1)
      end

      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq('resource_not_found')
      end

      it { is_expected.to be_unprocessable }
    end

    context 'when the ingredient does not exist' do
      let(:ingredient_id) { -2 }
      it 'does not delete the ingredient_quantity' do
        expect(stock.ingredients.count).to eq(1)
      end

      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq('resource_not_found')
      end

      it { is_expected.to be_unprocessable }
    end
  end
end