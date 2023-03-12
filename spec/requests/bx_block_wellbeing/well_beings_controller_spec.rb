require 'rails_helper'

RSpec.describe "BxBlockWellbeing::WellBeings", type: :request do
  @get_data = Support::SharedHelper.new.create_wellbeing
  # @category = Support::SharedHelper.new.create_wellbeing.category
  before(:all) do
    @token = Support::SharedHelper.new.get_token
    @get_data = Support::SharedHelper.new.create_wellbeing
  end

  let(:get_param){
    {
      question_id: 1,
      answer_id: 1
    }
  }
  let (:question_params){
    {
       question_id: 3,
       answer_id: 3,
       id: 1
    }
  }
  let (:ques_params){
    {
       question_id: 2,
       answer_id: 2,
       id: 2,
       category_id:2,
       category_name: "testdemo"
    }
  }

 
  # let(:wrong_param) {{
  #   question_id: 0,
  #   answer_id: 12
  # }}

  describe "#index" do
    it "returns http success" do
      get '/bx_block_wellbeing/well_beings?category_id=1',  headers: { token: @token}
      expect(response).to have_http_status(:success)
    end
  end

  describe "#get_result" do
    it "should return the result" do
      get '/bx_block_wellbeing/get_result', headers: { token: @token}
      expect(response).to have_http_status(:success)
    end
  end

  describe "#question" do
    it "Should get question success" do
      get '/bx_block_wellbeing/question?category_id=1',params: question_params, headers: { token: @token}
      expect(response).to have_http_status(:success)
    end
  end

  describe "#question_categories" do
    it "should get question_categories success" do
      get '/bx_block_wellbeing/question_categories',params: ques_params, headers: { token: @token}
      expect(response).to have_http_status(:success)
    end  
  end

  describe "#delete_answers" do
    it "should delete questions successfully" do
      delete '/bx_block_wellbeing/delete_answers', headers: { token: @token}
      expect(response).to have_http_status(:success)
    end
  end

  describe "#get_result" do
    it "should get result successfully" do
      get '/bx_block_wellbeing/get_result?category_id=1', headers: { token: @token}
      expect(response).to have_http_status(:success)
    end
  end

  describe "#user_answer" do
    it "should get question and answer successfully" do
      post '/bx_block_wellbeing/user_answer', params: get_param, headers: { token: @token}
      expect(response).to have_http_status(:success)
    end
  end

  describe "#all_categories" do
    it 'should get all categories' do
     get '/bx_block_wellbeing/all_categories', headers: {token: @token}
     expect(response).to have_http_status(200)
    end
  end

  describe "user_strength" do
    it "should get user_strength successfully" do
      get '/bx_block_wellbeing/user_strength', headers: { token: @token}
      expect(response).to have_http_status(:success)
    end

    # it "should cover loop" do
    #   WellBeingSubCategory.where(well_being_category_id: 2).each do |sub_cate|
    #     question1=QuestionWellBeing.where(id: 2).last
    #     get '/bx_block_wellbeing/insights', headers: { token: @token}
    #     question2=QuestionWellBeing.where("category_id = ? and subcategory_id = ?", cate.id, sub_cate&.id)
    #     expect(question1).to be(question2)
    #   end
    # end
  end

  describe "insigths" do
    it "should get insigths successfully" do
      get '/bx_block_wellbeing/insights', headers: { token: @token}
      expect(response).to have_http_status(:success)
    end
  end
end
