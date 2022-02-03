require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build :user }

  describe 'Validations' do
    it 'has a valid user' do
      expect(user).to be_valid
    end

    it 'is not valid without a username' do
      user.username = nil
      expect(user).not_to be_valid
    end

    it 'is not valid without an email' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicated email' do
      create(:user, username: 'Dexter', email: 'dexter@example.com')
      user.email = 'dexter@example.com'
      expect(user).not_to be_valid
    end

    it 'is not valid with the wrong email format' do
      addresses = %W[user@foo,com user_at_foo.org example.user@foo.
        foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        user.email = invalid_address 
        expect(user).not_to be_valid
      end    
    end

    it 'is valid with the right email format' do
      addresses = %W[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end 
  end
end

