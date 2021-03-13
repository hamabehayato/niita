require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    let(:params) { attributes_for(:user) }

    context "正しい値が入力された時" do
      it "ユーザ登録出来る" do
        subject
        res = JSON.parse(response.body)
        expect(res["status"]).to eq("success")
        expect(res["data"]["id"]).to eq(User.last.id)
        expect(res["data"]["email"]).to eq(User.last.email)
        expect(response).to have_http_status(:ok)
      end

      it "ヘッダー情報を取得できる" do
        subject
        header = response.header
        expect(header["uid"]).to be_present
        expect(header["access-token"]).to be_present
        expect(header["token-type"]).to be_present
        expect(header["client"]).to be_present
        expect(header["Content-Type"]).to be_present
        expect(header["ETag"]).to be_present
        expect(header["expiry"]).to be_present
      end
    end

    context "nameが入力されていないとき" do
      let(:params) { attributes_for(:user, name: nil) }

      it "ユーザが作成されない" do
        expect { subject }.to change { User.count }.by(0)
      end
    end

    context "emailが入力されていないとき" do
      let(:params) { attributes_for(:user, email: nil) }

      it "ユーザが作成されない" do
        expect { subject }.to change { User.count }.by(0)
      end
    end

    context "passwordが入力されていないとき" do
      let(:params) { attributes_for(:user, password: nil) }

      it "ユーザが作成されない" do
        expect { subject }.to change { User.count }.by(0)
      end
    end
  end

  describe "POST api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "存在する値のとき" do
      let(:params) { attributes_for(:user, name: user.name, email: user.email, password: user.password) }
      let(:user) { create(:user) }

      it "ログインできる" do
        subject
        JSON.parse(response.body)
        expect(response.headers["uid"]).to be_present
        expect(response.headers["access-token"]).to be_present
        expect(response.headers["client"]).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    # context "存在しない値のとき" do
    #     let(:params) { attributes_for(:user) }
    #     let(:user) { create(:user) }

    #     fit "ログインできない" do
    #         subject
    #         expect(response).to have_http_status(401)
    #     end
    # end

    context "emailが一致しないとき" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: "hoge", password: user.password) }

      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        header = response.header
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(headers["uid"]).to be_blank
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "passwordが一致しない場合" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email, password: "hoge") }

      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        header = response.header
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(headers["uid"]).to be_blank
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "ユーザがログインしているとき" do
      let(:user) { create(:user) }
      let(:headers) { create(:user).create_new_auth_token }

      it "ログアウトできる" do
        subject
        # expect(user.reload.tokens).to be_blank
        expect { subject }.to change { user.reload.tokens }.from(be_present).to(be_blank)
        expect(response).to have_http_status(:ok)
      end
    end

    context "誤った情報を送信したとき" do
      let(:user) { create(:user) }
      let!(:token) { user.create_new_auth_token }
      let!(:headers) { { "access-token" => "", "token-type" => "", "client" => "", "expiry" => "", "uid" => "" } }

      it "ログアウトできない" do
        subject
        expect(response).to have_http_status(:not_found)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "User was not found or was not logged in."
      end
    end
  end
end
