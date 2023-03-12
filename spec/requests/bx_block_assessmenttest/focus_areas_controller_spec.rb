require 'rails_helper'

RSpec.describe "BxBlockAssessmenttest::FocusAreasControllers", type: :request do
  before(:all) do
     @token = Support::SharedHelper.new.get_token
  end


  describe '#create' do
    context 'get focus areas' do
      it 'should pass  when get focus area successfully' do
        post '/bx_block_assessmenttest/focus_areas',headers: { token: @token}
          expect(response).to have_http_status :ok
        end
     end 
   end


  describe '#my_progress' do
    context 'my_progress' do
      it 'should pass  when get progress successfully' do
        get '/bx_block_assessmenttest/my_progress',headers: { token: @token}
          expect(response).to have_http_status :ok
        end
     end 
   end
end
