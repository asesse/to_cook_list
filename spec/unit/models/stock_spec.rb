require 'rails_helper'

RSpec.describe Stock, type: :model do
  subject(:stock) { build :stock }

  describe 'Validations' do
    
    context 'when invitation_token is not unique' do 
      it 'is not valid' do
        initial_stock = create(:stock)
        stock.invitation_token = initial_stock.invitation_token
        expect(stock).not_to be_valid
      end      
    end
  end
end