module BxBlockAssessmenttest
	class ChooseAnswersController < ApplicationController
		include BuilderJsonWebToken::JsonWebTokenValidation
		before_action :validate_json_web_token
		def create
			question = BxBlockAssessmenttest::AssesmentTestQuestion.find_by(id:  params[:question_id])
			answer = question&.assesment_test_answers&.where(id: params[:answer_id])
			if question.present?
				if answer.present? && question.sequence_number == params[:sequence_number]
					@selected_answer = BxBlockAssessmenttest::ChooseAnswer.new(assesment_test_question_id: params[:question_id], assesment_test_answer_id: params[:answer_id], account_id: @token.id)
					if @selected_answer.save

						render json: BxBlockAddress::ChooseAnswerSerializer.new(@selected_answer).serializable_hash, status: :created
					else
						render json: {errors: [{message: "account not found"}]}
					end
				else 
					render json: {errors: [{message: "answer or sequence number not match with this question "}]}

	            end 
	        else 
					render json: {errors: [{message: "question id not found "}]}

	        end 

		end

		
	end
end