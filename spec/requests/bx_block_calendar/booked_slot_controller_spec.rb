require 'rails_helper'

RSpec.describe "BxBlockCalendar::BookedSlotsController", type: :request do
  hr_role = Support::SharedHelper.new.hr_role
  account = Support::SharedHelper.new.get_coach_user
  hr_account = Support::SharedHelper.new.create_company_hr
  @token = Support::SharedHelper.new.get_token

 
  let(:create_param){
    {
      booked_slot: {
        start_time: "01/01/2023 15:0",
        end_time: "01/01/2023 15:59",
        service_provider_id: "133",
        booking_date: "2023-01-01"
      }
    }
  }

  let(:params_set_2){
    {
      booked_slot: {
        start_time: "01/01/2023 15:0",
        end_time: "01/01/2023 15:59",
        service_provider_id: "133"
      }
    }
  }

  let(:params_set_3){
    {
     service_user_id: account.id,
      date: "12/10/2022"
    }
  }

  let(:params_set_4){
    {
      service_provider_id: "22",
      format: :json
    }
  }

  let(:params_set_5){
    {
       booked_slot:{
        access_code: "jhdf",
        service_provider_id: "133",
        id: account.id,
        url: "http://localhost:3000"
       }
    }
  }

  let(:params_set_6){
    {
       service_provider_id: "92"
    }
  }
  before(:all) do
    admin_role = Support::SharedHelper.new.admin_role
    coach_role = Support::SharedHelper.new.coach_role
    @token = Support::SharedHelper.new.get_token
    @admin_token = Support::SharedHelper.new.get_admin_token
  end

  describe '#index' do
    it 'should not show booked slots' do
    	byebug
      get '/bx_block_calendar/booked_slots', headers: { token: @token}
      expect(response).to have_http_status(200)
    end
  end

  # describe "#create" do
  #   it "should create booked slots" do
  #     post '/bx_block_calendar/booked_slots', params: create_param, headers: { token: @token}
  #     expect(response).to have_http_status(200)
  #   end

  #   it "should return error msg booking date is blank" do
  #     h = {"booking_date"=>"Booking date must be present", "service_provider"=>"must exist", "service_user"=>"must exist", "start_time"=>"end time format is not correct, it should be in HH:MM format"} 
  #     post '/bx_block_calendar/booked_slots',params: params_set_2,headers: {token: @admin_token}
  #     res = JSON.parse(response.body)
  #     expect(res["errors"].first).to eq h.as_json
  #   end
  # end

  # describe "#view_coach_availability" do
  #   it "should view_coach_availability" do
  #     get '/bx_block_calendar/booked_slots/view_coach_availability', headers: {token: @token}
  #     expect(response).to have_http_status(200)
  #   end
  # end

  # describe "#current_coach" do
  #   it "should not view current coach because of parmas" do
  #     get '/bx_block_calendar/booked_slots/current_coach', headers: {token: @token}
  #     expect(response).to have_http_status(422)
  #   end
  # end

  # describe "#user_action_item" do
  #   it "should create action items " do
  #     post '/bx_block_calendar/booked_slots/user_action_item',params: params_set_3,headers: {token: @token}
  #     expect(response).to have_http_status(200)
  #   end
  # end

  # describe "#coach_past_appointments" do
  #   it "should " do
  #      get '/bx_block_calendar/booked_slots/coach_past_appointments',params: params_set_4, headers: {token: @admin_token}
  #      err = JSON.parse(response.body)['err']
  #      expect()
  #   end
  # end

  # describe "#current_coach" do
  #   data = {"id"=>"account.id",
  #     "type"=>"current_coach","attributes"=>{"coach_details"=>{"id"=>account.id, "full_name"=>"assess user", "expertise"=>[], "rating"=>nil, "education"=>nil, "languages"=>"", "city"=>nil, "image"=>nil}}}
  #   it "should show current coach " do
  #       service_user_id =  BuilderJsonWebToken.decode(@token).id
  #       user_booked_slot = BxBlockAppointmentManagement::BookedSlot.new(service_provider_id: 3, service_user_id:  service_user_id, booking_date: '04-01-2023', start_time: '15:09', end_time: '15:59' )
  #       user_booked_slot.save(validate: false)
  #       get '/bx_block_calendar/booked_slots/current_coach',params: params_set_5,headers: {token: @admin_token}
  #       JSON.parse(response.body)
  #       expect(response).to eq data.as_json
  #   end
  # end

  # describe "#past_coach" do
  #   data = {"id"=>"account.id",
  #        "type"=>"current_coach","attributes"=>{"coach_details"=>{"id"=>account.id, "full_name"=>"assess user", "expertise"=>[], "rating"=>nil, "education"=>nil, "languages"=>"", "city"=>nil, "image"=>nil}}}
  #     it "should show past coach " do
  #       service_user_id = BuilderJsonWebToken.decode(@token).id
  #        user_booked_slot = BxBlockAppointmentManagement::BookedSlot.new(service_provider_id: 3, service_user_id:  service_user_id, booking_date: '04-01-2023', start_time: '15:09', end_time: '15:59' )
  #         user_booked_slot.save(validate: false)
  #      get '/bx_block_calendar/booked_slots/past_coach', params: params_set_5,headers: {token: @token}
  #     end
  # end

  # describe "#coach_with_upcoming_appointments" do
  #   it 'should show coach_with_past_appointments' do
  #     get '/bx_block_calendar/booked_slots/coach_with_upcoming_appointments', params: params_set_6, headers: {token: @token}
  #   end
  # end
end