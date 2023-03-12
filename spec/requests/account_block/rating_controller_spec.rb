require 'rails_helper'

RSpec.describe "AccountBlock::RatingsController", type: :request do
 before(:each) do
    admin_role = Support::SharedHelper.new.admin_role
    coach_role = Support::SharedHelper.new.coach_role
    @token = Support::SharedHelper.new.get_token
    @admin_token =   Support::SharedHelper.new.get_admin_token
    account = Support::SharedHelper.new.admin_user
   end
   let(:create_param){{
    rating:{
   	coach_rating: 3.5,
    coach_id: 2
   }
  }
 }
 let(:create_error_param){{
    rating:{
    coach_rating: 3.5
   }
  }
 }
 let(:coach_rating_param){{rating: {

    coach_id: 2,
    coach_rating: 7,
    app_rating: 7
   }
  }
 }
  let(:all_user_feedbacks_params){{rating: {
    coach_id: 2,
    account_id: 2,
    app_rating: 7
   }
  }
 }
  describe "#create" do
    it 'should create ' do
      post '/account_block/ratings', params: create_param, headers: {token: @token}
      expect(response).to have_http_status(200)   
    end

    it 'should show error' do
      post '/account_block/ratings', params: create_error_param, headers: {token: @token}
        expect(response).to have_http_status(422)
    end
    it 'should check if coach and rating is present' do
     post '/account_block/ratings', params: coach_rating_param, headers: {token: @token}
     expect(response).to have_http_status(200)
    end
  end

  describe "#all_users_feedbacks" do
   it 'should show all user ' do
    get '/account_block/all_users_feedbacks', params: all_user_feedbacks_params, headers: {token: @token}
    expect(response).to have_http_status(200)
   end
  end

  describe "#user_feedback" do
   it 'should show user feedback' do
    get '/account_block/user_feedback', headers: {token: @token}
    expect(response).to have_http_status(200)
   end
  end
  describe "#delete_ratings" do
    it "should delete users ratings" do 
      delete '/account_block/delete_ratings', headers: {token: @token}
      expect(response).to have_http_status(200)
    end
  end
end