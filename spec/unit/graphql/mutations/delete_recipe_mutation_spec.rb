require 'rails_helper'

describe Mutations::DestroyRecipe, type: :request do 
  let(:user) { create :user }
  let(:recipe) { create(:recipe, user_id: user.id) }
  let(:recipe_id) { recipe.id }
  let(:params) do
    {
      'query' => "mutation {
        destroyRecipe(input: {
          recipeId: #{recipe_id}
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

  context 'when recipe id exists' do
    #it 'validates the schema' do
      #expect(response.parsed_body['errors']).to be_nil
    #end

    it 'correctly delete the recipe' do
      expect(Recipe.find_by(id: recipe_id)).to be_nil
    end
  end

  context 'when it doesn\'t find the recipe' do
    let(:recipe_id) { -3 }
    it 'doesn\'t delete the recipe' do 
      recipe.reload
      expect(user.recipes.count).to eq(1)
    end

    it 'renders an error' do
      expect(response.parsed_body['errors'][0]['message']).to eq('not_found')
    end
  end
end