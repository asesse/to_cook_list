require 'rails_helper'

describe Mutations::UpdateRecipe, type: :request do 
  let(:user) { create :user}
  let(:user_id) { user.id }
  let(:recipe) { create :recipe }
  let(:recipe_id) { recipe.id }
  let(:name) { 'Tiramisu' }
  let(:instructions) { 'Mélangez la mascarpone et les oeufs. Saupoudrez de cacao' }
  let(:portions) { recipe.portions + 1 }
  let(:ingredient_quantity_1) { create(:ingredient_quantity, target: recipe) }
  let(:ingredient_quantity_2) { create(:ingredient_quantity, target: recipe) }
  let(:ingredient_1) { ingredient_quantity_1.ingredient }
  let(:ingredient_2) { ingredient_quantity_2.ingredient }
  let(:quantity_1) { ingredient_quantity_1.quantity + 1 }
  let(:quantity_2) { ingredient_quantity_2.quantity + 1 }
  let(:unit_1) { (IngredientQuantity::UNITS - [ingredient_quantity_1.unit]).sample }
  let(:unit_2) { (IngredientQuantity::UNITS - [ingredient_quantity_2.unit]).sample }
  let(:params) do
    {
      'query' => "mutation {
        updateRecipe(input: {
          recipeId:  #{recipe_id}
          name: \"#{name}\"
          instructions: \"#{instructions}\"
          portions: #{portions}
          ingredientQuantities: [{
            ingredientId: #{ingredient_1.id}
            quantity: #{quantity_1}
            unit: #{unit_1}
          },
          {
            ingredientId: #{ingredient_2.id}
            quantity: #{quantity_2}
            unit: #{unit_2}
          }]
        }){
          recipe {
            name 
            instructions
            portions
            author {
              username
            }
            ingredientQuantities {
              ingredient {
                name
              }
              quantity
              unit
            }
          }
        }
      }"
    }
  end
    before do
      post '/graphql', params: params, headers: headers
    end 
    
  context 'when it update the recipe' do

    it 'correctly updates the recipe' do
      recipe.reload
      expect(recipe.name).to eq(name)
      expect(recipe.instructions).to eq(instructions)
      expect(recipe.portions).to eq(portions)
      expect(recipe.ingredient_quantities.first.quantity).to eq(quantity_1)
      expect(recipe.ingredient_quantities.first.unit).to eq(unit_1)
    end
  end

  context 'when quantity is equal to 0' do
    let(:quantity_1) { 0 }
    it 'deletes the ingredient' do
      expect(recipe.ingredient_quantities.count).to eq(1)
    end
  end

  context 'when it doesn\'t find the recipe' do
  let(:recipe_id) { -1 }

    it 'renders an error' do
      expect(response.parsed_body['errors'][0]['message']).to eq("Couldn't find Recipe with 'id'=-1")
    end
  end

  context 'when name is blank' do
    let(:name) { " " }
    it 'doesn\'t update the recipe' do
      recipe.reload
      expect(recipe.name).not_to eq(name)
      expect(recipe.instructions).not_to eq(instructions)
      expect(recipe.portions).not_to eq(portions)
      expect(recipe.ingredient_quantities.first.quantity).not_to eq(quantity_1)
      expect(recipe.ingredient_quantities.first.unit).not_to eq(unit_1)
    end
    
    it 'renders an error' do
      expect(response.parsed_body['errors'][0]['message']).to eq("Validation failed: Name can't be blank")
    end
  end

  context 'when instruction is blank' do
    let(:instructions) { " " }
    it 'doesn\'t update the recipe' do
      recipe.reload
      expect(recipe.name).not_to eq(name)
      expect(recipe.instructions).not_to eq(instructions)
      expect(recipe.portions).not_to eq(portions)
      expect(recipe.ingredient_quantities.first.quantity).not_to eq(quantity_1)
      expect(recipe.ingredient_quantities.first.unit).not_to eq(unit_1)
    end
  end

  context 'when portion is negative' do
    let(:portions) { -2 }
      it 'doesn\'t update the recipe' do
        recipe.reload
        expect(recipe.name).not_to eq(name)
        expect(recipe.instructions).not_to eq(instructions)
        expect(recipe.portions).not_to eq(portions)
        expect(recipe.ingredient_quantities.first.quantity).not_to eq(quantity_1)
        expect(recipe.ingredient_quantities.first.unit).not_to eq(unit_1)
      end
    end

  context 'when quantity is negative' do
    let(:quantity_1) { -2 }
    it 'doesn\'t update the recipe' do
      recipe.reload
      expect(recipe.name).not_to eq(name)
      expect(recipe.instructions).not_to eq(instructions)
      expect(recipe.portions).not_to eq(portions)
      expect(recipe.ingredient_quantities.first.quantity).not_to eq(quantity_1)
      expect(recipe.ingredient_quantities.first.unit).not_to eq(unit_1)
    end

    it 'renders an error' do
      expect(response.parsed_body['errors'][0]['message']).to eq("{:quantity=>[{:error=>:greater_than_or_equal_to, :value=>-2, :count=>1}]}")
    end
  end

  context 'quantity is blank' do
    let(:quantity_1) { " " }
    it 'doesn\'t update the recipe' do
      recipe.reload
      expect(recipe.name).not_to eq(name)
      expect(recipe.instructions).not_to eq(instructions)
      expect(recipe.portions).not_to eq(portions)
      expect(recipe.ingredient_quantities.first.quantity).not_to eq(quantity_1)
      expect(recipe.ingredient_quantities.first.unit).not_to eq(unit_1)
    end
  end

  context 'when unit is blank' do
    let(:unit_1) { " " }
    it 'doesn\'t update the recipe' do
      recipe.reload
      expect(recipe.name).not_to eq(name)
      expect(recipe.instructions).not_to eq(instructions)
      expect(recipe.portions).not_to eq(portions)
      expect(recipe.ingredient_quantities.first.quantity).not_to eq(quantity_1)
      expect(recipe.ingredient_quantities.first.unit).not_to eq(unit_1)
    end
  end
end