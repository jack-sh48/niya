module BxBlockAssessmenttest
	class FocusAreasController < ApplicationController
		include BuilderJsonWebToken::JsonWebTokenValidation
		before_action :validate_json_web_token

		def create
			@focus_areas = BxBlockAssessmenttest::SelectAnswer.where(account_id: @token.id).last

			if @focus_areas.present?
				render json: BxBlockAddress::FocusAreaSerializer.new(@focus_areas).serializable_hash, status: :created 
			else
				render json: {errors: [message: "focus areas not not found"]}
			end
		end

		def my_progress
			if current_user.present?
				render json: BxBlockAddress::MyProgressSerializer.new(current_user).serializable_hash, status: :ok
			else
				render json: {errors: "Account Not Found"}, status: :unprocessable_entity
			end
		end

		private


		def current_user
			return unless @token
	    	@current_user ||= AccountBlock::Account.find(@token.id)
		end
	end
end