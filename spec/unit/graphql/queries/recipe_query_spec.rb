require 'rails_helper'

describe Types::QueryType, type: :request do 
  let(:recipe) { create :recipe }
  let(:recipe_id) { recipe.id }
  let(:params) do
    {
      'query' => "query {
        recipe(id: #{ recipe_id }){
         name
         instructions
         portions
         author {
          username
        }    
        }
      }"
    }
  end
  before do
    post '/graphql', params: params
  end
  context 'when id exists' do
    it 'renders no error' do
      expect(response.parsed_body["errors"]).to be_nil
    end

    it 'renders the correct information' do
      expect(response.parsed_body.dig('data', 'recipe', 'name')).to eq(recipe.name)
      expect(response.parsed_body.dig('data', 'recipe', 'instructions')).to eq(recipe.instructions)
      expect(response.parsed_body.dig('data', 'recipe', 'portions')).to eq(recipe.portions)
      expect(response.parsed_body.dig('data', 'recipe', 'author', 'username')).to eq(recipe.author.username) 
    end
    
  end
  context 'when id doesn\'t exist' do
    let(:recipe_id) { -2 }
    it 'renders an error' do
      expect(response.parsed_body.dig('errors', 0, 'message')).to eq('not_found')
    end
    
  end

end