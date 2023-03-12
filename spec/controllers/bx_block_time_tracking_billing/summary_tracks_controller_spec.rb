require 'rails_helper'

RSpec.describe BxBlockTimeTrackingBilling::SummaryTracksController, type: :controller do
  describe "time track #index" do
    let(:account) { Support::SharedHelper.new.current_user }
    context "when request index" do
      it "it should return time summary track data" do
        request.headers["token"] = BuilderJsonWebToken::JsonWebToken.encode(account.id)
        get :index
        expect(response).to have_http_status(200)
        get :index
      end

      it "it should return time summary track data when pass start date" do
        request.headers["token"] = BuilderJsonWebToken::JsonWebToken.encode(account.id)
        get :index, params: { start_date: '2022-12-05'}
        expect(response).to have_http_status(200)
      end

      it "it should return time summary track data when pass start date" do
        request.headers["token"] = BuilderJsonWebToken::JsonWebToken.encode(account.id)
        get :index, params: { start_date: '2022-12-03'}
        get :index, params: { start_date: '2022-12-04'}
        expect(response).to have_http_status(200)
      end
    end
  end
end
