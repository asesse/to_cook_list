require 'rails_helper'

describe Mutations::CreateRecipe, type: :request do 
  let(:user) { create :user}
  let(:user_id) { user.id }
  let(:name) { Faker::Lorem.sentence(word_count: 3) }
  let(:instructions) { Faker::Lorem.paragraph_by_chars(number: 2, supplemental: false) }
  let(:portions) { rand(1..12)}
  let(:ingredient_1) { create :ingredient }
  let(:ingredient_2) { create :ingredient }
  let(:quantity_1) { 2 }
  let(:quantity_2) { 3 }
  let(:unit_1) { IngredientQuantity::UNITS.sample }
  let(:unit_2) { IngredientQuantity::UNITS.sample }
  let(:params) do
    {
      'query' => "mutation {
        createRecipe(input: {
          name: \"#{name}\"
          instructions: \"#{instructions}\"
          portions: #{portions}
          authorId: #{user_id}
          ingredientsParams: [{
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
    post '/graphql', params: params
  end

  context 'when it creates a recipe' do 
    it 'adds a recipe' do
      expect(user.recipes.count).to eq(1)
    end
    it 'renders the correct information' do
      recipe = user.recipes.last
      expect(response.parsed_body.dig('data', 'createRecipe', 'recipe', 'name')).to eq(recipe.name)
      expect(response.parsed_body.dig('data', 'createRecipe', 'recipe', 'instructions')).to eq(recipe.instructions)
      expect(response.parsed_body.dig('data', 'createRecipe', 'recipe', 'portions')).to eq(recipe.portions)
      expect(response.parsed_body.dig('data', 'createRecipe', 'recipe', 'author', 'username')).to eq(recipe.author.username)
    end
  end

  context 'when the user id is invalid' do
    let(:user_id) { -2 }
    it 'doesn\'t create the recipe' do 
      expect(user.recipes.count).to eq(0)
    end

    it 'renders an error' do
      expect(response.parsed_body.dig('errors', 0,'message')).to eq("{:author=>[{:error=>:blank}]}")
    end
  end

  context 'when name is blank' do
    let(:name) { " "}
    it 'doesn\'t create the recipe' do 
      expect(user.recipes.count).to eq(0)
    end

    it 'renders an error' do
      expect(response.parsed_body.dig('errors', 0, 'message')).to eq("{:name=>[{:error=>:blank}]}")
    end
  end

  context 'when instructions is blank' do
    let(:instructions) { " " }
    it 'doesn\'t create the recipe' do
      expect(user.recipes.count).to eq(0) 
    end 

    it 'renders an error' do
      expect(response.parsed_body.dig('errors', 0, 'message')).to eq("{:instructions=>[{:error=>:blank}]}")
    end 
  end

  context 'when portion is negative' do
    let(:portions) { -2 }
    it 'doesn\'t create the recipe' do 
      expect(user.recipes.count).to eq(0)
    end 
    
    it 'renders an error' do
      expect(response.parsed_body.dig('errors', 0, 'message')).to eq("{:portions=>[{:error=>:greater_than_or_equal_to, :value=>-2, :count=>1}]}")
    end
  end
end