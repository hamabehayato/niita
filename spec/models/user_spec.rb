require "rails_helper"

RSpec.describe User, type: :model do
  #   pending "add some examples to (or delete) #{__FILE__}"
  context "正しくデータが入力されているとき" do
    it "ユーザーが作られる" do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  context "emailを指定していないとき" do
    it "ユーザー作成に失敗する" do
      user = build(:user, email: nil)
      # binding.pry
      expect(user.valid?).to eq false
      # expect(user.errors.details[:email][0][:error]).to eq :blank
    end
  end
end
