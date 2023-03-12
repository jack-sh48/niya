require 'rails_helper'

RSpec.describe "BxBlockAssessmenttest::ActionItemsController", type: :request do
   before(:all) do
     @token = Support::SharedHelper.new.get_token
     Support::SharedHelper.new.action_item
  end
 
  let(:create_param){{ goal:  "i need to focus on my work", date: "01/01/2022",time_slot: "10:00 AM" }}
  let(:update_params){{ goal:  "i need to focus on my work",date: "01/01/2022",time_slot: "10:00 AM",complete: "true"}}
  #   describe '#create' do
  #     context 'create action item' do
  #       it 'should pass  when create  action item successfully' do
  #         post '/bx_block_assessmenttest/action_items', params: create_param, headers: { token: @token}
  #         expect(response).to have_http_status :created
  #       end
  #    end 
  # end
 
   #  describe '#update' do
   #      context 'update action item' do
   #        it 'should pass  when update action item successfully' do
   #          put '/bx_block_assessmenttest/update_action?id=1', params: update_params, headers: { token: @token}
   #          expect(response).to have_http_status :ok
   #        end
   #     end 
   # end
    describe '#current_actions' do
        context 'current action item' do
          it 'should pass  when get  action item successfully' do
            get '/bx_block_assessmenttest/current_actions',headers: { token: @token}
            expect(response).to have_http_status :ok
          end
       end 
   end

    describe '#destroy' do
        context 'destroy action item' do
          it 'should pass  when destroy  action item successfully' do
            delete '/bx_block_assessmenttest/destroy_action?id=1',headers: { token: @token}
            expect(response).to have_http_status :ok
          end
       end 
   end

    describe "start_game /games" do
      it "should pass when destroy games start successfully" do
        get '/bx_block_assessmenttest/start_game', headers: { token: @token}
        expect(response).to have_http_status(:success)
      end
    end
end
