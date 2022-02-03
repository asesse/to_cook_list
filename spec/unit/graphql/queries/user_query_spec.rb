require 'rails_helper'

describe Types::QueryType, type: :request do
  let(:user) { create :user }
  let(:user_id) { user.id }
  let(:username) { user.username}
  let(:email) { user.email}
  let(:stock_id) { user.stock.id}
  let(:params) do
  {
    'query' => "query {
      user(id: #{ user_id }){
        username
        email
        stockId
      }
    }"
  }
end
  before do
    post '/graphql', params: params, headers: headers
  end
  context 'when the user exists' do

    #it { is_expected.to be_ok }

    it 'renders the right information' do
      expect(response.parsed_body.dig('data', 'user', 'username')).to eq(username)
      expect(response.parsed_body.dig('data', 'user', 'email')).to eq(email)
      expect(response.parsed_body.dig('data', 'user', 'stockId').to_i).to eq(user.stock.id)
    end
  end

  context 'when the user does not exist' do
    let(:user_id) { -2 }

    it 'is not found' do
      expect(response.parsed_body.dig('errors', 0, 'message')).to eq('not_found')
    end
  end
end