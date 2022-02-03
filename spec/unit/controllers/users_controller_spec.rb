require 'rails_helper'

describe UsersController, type: :controller do
  render_views
  subject { response }

  include_context 'with default headers'

  describe '#show' do
    let(:user) { create :user }

    context 'when the user exists' do
      before do
        get :show, params: { id: user.id }
      end

      it { is_expected.to be_ok }

      it 'renders the right username' do
        expect(response.parsed_body['username']).to eq(user.username)
      end

      it 'renders the right email' do
        expect(response.parsed_body['email']).to eq(user.email)
      end

      it 'renders the right stock_id' do
        expect(response.parsed_body['stock_id']).to eq(user.stock_id)
      end
    end

    context 'when the user does not exist' do
      before do
        get :show, params: { id: -1 }
      end

      it 'is not found' do
        expect(response.parsed_body['errors']).to eq('not_found')
      end

      it { is_expected.to be_not_found }
    end
  end

  describe '#create' do
    let(:username) { Faker::Internet.username }
    let(:stock) { create :stock}
    let(:user) { User.last }
    

    context 'when saved' do
      let(:email) { Faker::Internet.email }
      
      before do
        post :create, params: { user: { username: username, email: email }, invitation_token: stock.invitation_token }
      end

      it 'correctly saves the user' do
        expect(User.count).to eq(1)
        expect(user.username).to eq(username)
        expect(user.email).to eq(email)
      end

      it { is_expected.to be_ok }
    
      it 'renders the message' do
        expect(response.parsed_body['id']).to eq(user.id)
        expect(response.parsed_body['username']).to eq(user.username)
        expect(response.parsed_body['email']).to eq(user.email)
        expect(response.parsed_body['stock_id']).to eq(user.stock_id)
      end
    end

    context 'when username is not present' do
      before do 
        post :create, params: { user: { email: "teacup@example.com" }, invitation_token: stock.invitation_token }
      end

      it 'does not create a user' do
        expect(user).to be_nil
      end 
    end 

    context 'when email is not present' do
      before do
        post :create, params: { user: { username: username }, invitation_token: stock.invitation_token }
      end

      it 'does not create a user' do
        expect(user).to be_nil
      end
  
      it { is_expected.to be_unprocessable }

      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq({"email"=>[{"error"=>"blank"}, {"error"=>"invalid", "value"=>nil}]})
      end
    end

    context 'when email has wrong format' do
        before do
          post :create, params: { user: { username: username, email: "foo@bar+baz.com" } }
        end
        
        it 'doesn\'t create a user' do
          expect(User.count).to eq(0)   
        end

        it 'doesn\'t create a stock' do
          expect(Stock.count).to eq(0)   
        end

        it 'renders an error' do
          expect(response.parsed_body['errors']).to eq({"email"=>[{"error"=>"invalid", "value"=>"foo@bar+baz.com"}]})
        end
    end

    context 'when email already exists' do   
      before do 
        create(:user, username: username, email: "teacup@example.com", stock: stock)
        post :create, params: { user: { username: "teacup", email: "teacup@example.com"}, invitation_token: stock.invitation_token }
      end

      it 'does not create a user' do
        expect(User.count).to eq(1)
      end
  
      it { is_expected.to be_unprocessable }
  
      it 'renders an error' do
        expect(response.parsed_body['errors']).to eq({"email"=>[{"error"=>"taken", "value"=>"teacup@example.com"}]})
      end
    end

    context 'when stock doesn\'t exist' do
      before do 
        post :create, params: { user: { username: "teacup", email: "teacup@example.com"} }
      end
      it 'creates a user' do
        expect(user.username).to eq("teacup")
        expect(user.email).to eq("teacup@example.com")
        expect(User.count).to eq(1)
      end 

      it { is_expected.to be_ok }  

      it 'creates a stock' do 
        expect(Stock.count).to eq(1)
      end

      it 'assigns the new user to the new stock' do
        expect(user.stock_id).to eq(Stock.last.id)
      end
    end

    context 'when stock already exists' do
      before do
        post :create, params: { user: { username: "teacup", email: "teacup@example.com" }, invitation_token: stock.invitation_token }
      end

      it 'creates a user' do
        expect(User.count).to eq(1)
      end

      it { is_expected.to be_ok }

      it 'assigns the new user to an existing stock' do
        expect(user.stock_id).to eq(stock.id)
      end

      it 'renders the right' do
        expect(response.parsed_body['stock_id']).to eq(stock.id)
      end 
    end 
    
    context 'when invitation_token is invalid' do
      before do 
        post :create, params: { user: { username: "teacup", email: "teacup@example.com" }, invitation_token: "hhdhddhd" }
      end

      it 'does not create a user' do 
        expect(User.count).to eq(0)
      end

      it { is_expected.to be_unprocessable }

      it 'renders an error message' do
        expect(response.parsed_body['errors']['stock']).to eq([{"error"=>"blank"}, {"error"=>"blank"}])
      end 
    end 
  end

  describe '#update' do
    let(:stock) { create(:stock)}
    let(:user) { create(:user) }
    
    context 'when is updated' do
      before do
        patch :update, params: { user: { username: 'postman', email: "teacup@example.com" }, id: user.id }
        user.reload
      end 

      it 'correctly updates the user' do
        expect(user.username).to eq('postman')
        expect(user.email).to eq('teacup@example.com')
      end

      it { is_expected.to be_ok }

      it 'renders the message' do 
        expect(response.parsed_body['id']).to eq(user.id)
        expect(response.parsed_body['username']).to eq(user.username)
        expect(response.parsed_body['email']).to eq(user.email)
      end
    end 

    context 'when updating a user with invalid email' do
      before do
        patch :update, params: { user: { email: 'foo@bar+baz.com'}, id: user.id }
      end 

      it 'does not update user' do
        user.reload
        expect(user.email).not_to eq('foo@bar+baz.com')
      end

      it { is_expected.to be_unprocessable }

      it 'renders the error' do 
        expect(response.parsed_body['errors']).to eq({"email"=>[{"error"=>"invalid", "value"=>"foo@bar+baz.com"}]})
      end
    end 

    context 'when email already exists' do
      let(:username) { Faker::Internet.username }
      let(:other_user) { create(:user, username: username, email: "teacup@example.com")}

      before do 
        other_user
        patch :update, params: { user: { email: "teacup@example.com" },  id: user.id }
      end

      it 'does not update user' do
        user.reload
        expect(user.email).not_to eq(other_user.email)
      end

      it { is_expected.to be_unprocessable }

      it 'renders the error' do
      expect(response.parsed_body['errors']).to eq({"email"=>[{"error"=>"taken", "value"=>"teacup@example.com"}]})
      end
    end 

    context 'when is not updated because email is not present' do
      let(:username) { Faker::Internet.username }
      let(:other_user) { create(:user, username: username, email: "teacup@example.com")}

      before do
        patch :update, params: { user: { email: "" }, id: other_user.id }
      end
      
      it 'does not update user' do
        user.reload
        expect(other_user.email).to eq("teacup@example.com")
      end

      it { is_expected.to be_unprocessable }

      it 'renders the error' do
        expect(response.parsed_body['errors']).to eq({"email"=>[{"error"=>"blank"}, {"error"=>"invalid", "value"=>""}]})
      end
    end 


    context 'when user doesn\'t exist' do
      before do
        patch :update, params: { user: { username: Faker::Internet.username }, id: 1 }
      end
        
      it { is_expected.to be_not_found }

      it 'renders the error' do
        expect(response.parsed_body['errors']).to eq('user_not_found')
      end
    end 
  end

  describe '#destroy' do
    let(:user) { create :user }

   context 'when a user exist'do 
    before do 
      user
      delete :destroy, params: { id: user.id }
    end

    it 'correctly destroys the user' do
      expect(User.count).to eq(0)
    end
    
    it { is_expected.to be_ok }

    it 'renders message' do
        expect(response.parsed_body['message']).to eq('user_deleted')
    end
  end

    context 'when a user doesn\'t exist' do
      before do 
        delete :destroy, params: { id: Faker::Internet.uuid }
      end

      it { is_expected.to be_not_found }

      it 'renders an error message' do
        expect(response.parsed_body['errors']).to eq('user_not_found')
      end
    end 
  end
end

