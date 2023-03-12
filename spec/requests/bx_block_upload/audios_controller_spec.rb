require 'rails_helper'
RSpec.describe "BxBlockUpload::Audios", type: :request do

    before(:all) do
        @token = Support::SharedHelper.new.get_token
    end

   
    describe "audio_list" do 
        it "should get aidio list" do 
            get '/audio_list', headers: {token: @token}
            expect(response).to have_http_status :ok
        end
    end

    describe "docs_list" do 
        it 'should get doc list' do 
            get '/artical_list', headers: {token: @token}
            expect(response).to have_http_status :ok 
        end
    end
     
    describe "video_list" do 
        it 'should get video list' do 
            get '/video_list', headers: {token: @token}
            expect(response).to have_http_status :ok 
        end
    end

    describe "suggestion" do 
        it 'should get video list ' do 
            get '/suggestion', headers: {token: @token}
            expect(response). to have_http_status :ok
        end
    end
end