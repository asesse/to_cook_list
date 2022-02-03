require 'rails_helper'

describe Mutations::CreateUser, type: :request do


  let(:stock) { create :stock}
  let(:user) { User.last }
  let(:username) { Faker::Internet.username  }
  let(:email) { "teacup@example.com" }
  let(:mutation_input) do 
    "{
    username: \"#{username}\"
    email: \"#{email}\" 
  }"    
  end
  let(:params) do
    {
      'query' => "mutation { 
        createUser(input: #{mutation_input}) {
          user {
            username
            email
            stockId
          }
        }
      }"
    }
  end



    context 'when saved' do
      before do
        post '/graphql', params: params
      end

      it 'correctly saves the user' do
        expect(User.count).to eq(1)
        expect(user.username).to eq(username)
        expect(user.email).to eq(email)
      end
    
      it 'renders the message' do
        expect(response.parsed_body.dig('data', 'createUser', 'user', 'username')).to eq(user.username)
        expect(response.parsed_body.dig('data', 'createUser', 'user', 'email')).to eq(user.email)
        expect(response.parsed_body.dig('data', 'createUser', 'user', 'stockId').to_i).to eq(user.stock_id)
      end
    end

    context 'when username is not present' do
      before do
        post '/graphql', params: params
      end
      let(:username) { " " }

      it 'does not create a user' do
        expect(user).to be_nil
      end 
    end 

    context 'when email is not present' do
      let(:email) { " " }
      before do
        post '/graphql', params: params
      end
      
      it 'does not create a user' do
        expect(user).to be_nil
      end

      it 'renders an error' do
        expect(response.parsed_body.dig('errors', 0, 'message')).to eq("{:message=>{:email=>[{:error=>:blank}, {:error=>:invalid, :value=>\" \"}]}, :status=>:unprocessable_entity}")
      end
    end

    context 'when email has wrong format' do
      before do
        post '/graphql', params: params
      end
      let(:email) { "foo@bar+baz.com" }
        
        it 'doesn\'t create a user' do
          expect(User.count).to eq(0)   
        end

        it 'doesn\'t create a stock' do
          expect(Stock.count).to eq(0)   
        end

        it 'renders an error' do
          expect(response.parsed_body.dig('errors', 0, 'message')).to eq("{:message=>{:email=>[{:error=>:invalid, :value=>\"foo@bar+baz.com\"}]}, :status=>:unprocessable_entity}")
        end
    end

    context 'when email already exists' do
      before do
        create(:user, username: username, email: "teacup@example.com", stock: stock)
        post '/graphql', params: params   
      end   

      it 'does not create a user' do
        expect(User.count).to eq(1)
      end
  
      it 'renders an error' do
        expect(response.parsed_body.dig('errors', 0, 'message')).to eq("{:message=>{:email=>[{:error=>:taken, :value=>\"teacup@example.com\"}]}, :status=>:unprocessable_entity}")
      end
    end

    context 'when stock doesn\'t exist' do
      let(:stock) { -3 }
      before do
        post '/graphql', params: params
      end
      
      it 'creates a user' do
        expect(user.username).to eq(username)
        expect(user.email).to eq(email)
        expect(User.count).to eq(1)
      end 

      it 'creates a stock' do 
        expect(Stock.count).to eq(1)
      end

      it 'assigns the new user to the new stock' do
        expect(user.stock_id).to eq(Stock.last.id)
      end
    end

    context 'when stock already exists' do
      let(:mutation_input) do 
        "{
        username: \"#{username}\"
        email: \"#{email}\" 
        invitationToken: \"#{invitation_token}\"
      }"
      end
      let(:invitation_token) { stock.invitation_token}
      before do
       
        post '/graphql', params: params
      end
    
      it 'creates a user' do
        expect(User.count).to eq(1)
      end

      it 'assigns the new user to an existing stock' do
        expect(user.stock_id).to eq(stock.id)
      end

      it 'renders the right' do
        expect(response.parsed_body.dig('data', 'createUser', 'user', 'username')).to eq(username)
        expect(response.parsed_body.dig('data', 'createUser', 'user', 'email')).to eq(email)
        expect(response.parsed_body.dig('data', 'createUser', 'user', 'stockId').to_i).to eq(stock.id)
      end 
    end 
    
    context 'when invitation_token is invalid' do
      let(:mutation_input) do 
        "{
        username: \"#{username}\"
        email: \"#{email}\" 
        invitationToken: \"#{invitation_token}\"
      }"    
      end
      let(:invitation_token) { "hhdhddhd" }
      before do
        post '/graphql', params: params
      end    
      
      it 'does not create a user' do 
        expect(User.count).to eq(0)
      end

      it 'renders an error message' do
        expect(response.parsed_body.dig('errors', 0, 'message')).to eq("{:message=>{:stock=>[{:error=>:blank}, {:error=>:blank}]}, :status=>:unprocessable_entity}")
      end 
    end 
  end

  