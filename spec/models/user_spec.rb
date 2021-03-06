require 'rails_helper'

RSpec.describe User, type: :model do
#   pending "add some examples to (or delete) #{__FILE__}"
    context "nameを指定しているとき" do 
        it "ユーザーが作られる" do
            user = build(:user)
            expect(user).to be_valid
        end
    end

    context "nameを指定していないとき" do
        it "ユーザー作成に失敗する" do    
            user = build(:user, name: nil)
            # binding.pry
            expect(user.valid?).to eq false
            expect(user.errors.details[:name][0][:error]).to eq :blank
        end
    end

    context "emailを指定していないとき" do
        it "ユーザー作成に失敗する" do    
            user = build(:user, email: nil)
            # binding.pry
            expect(user.valid?).to eq false
            expect(user.errors.details[:email][0][:error]).to eq :blank
        end
    end

    context "passwordを指定していないとき" do
        it "ユーザー作成に失敗する" do    
            user = build(:user, password: nil)
            # binding.pry
            expect(user.valid?).to eq false
            expect(user.errors.details[:password][0][:error]).to eq :blank
        end
    end

    context "すでに同じ名前のnameが存在しているとき" do
        before { create(:user, name: "foo") }
        it "ユーザー作成に失敗する" do
          user = build(:user, name: "foo")
          expect(user.valid?).to eq false
          expect(user.errors.details[:name][0][:error]).to eq :taken
        end
    end

end