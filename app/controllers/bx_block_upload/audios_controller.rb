module BxBlockUpload
	class AudiosController < ApplicationController
		include BuilderJsonWebToken::JsonWebTokenValidation
		before_action :validate_json_web_token
		before_action :account_user
		def audio_list
			if @current_user.present?
				test_type_answer=BxBlockAssessmenttest::SelectAnswer.where(account_id: @token.id).last
				focus_areas=BxBlockAssessmenttest::AssesmentTestTypeAnswer.where(id: test_type_answer&.multiple_answers).pluck(:id).map{|x| x.to_s}				
				file_id = BxBlockUpload::MultipleUploadFile.where(choose_file: 'audios').pluck(:id)
				file=BxBlockUpload::FileType.joins(:multiple_upload_file).where(multiple_upload_file_id: file_id)
				file_data=[]
				file.each do |f|
					f.focus_areas.delete("")
					fc=f.focus_areas.map{|x| x.to_s}
					if !(fc & focus_areas).empty?
						file_data<<f
					end
				end
				render json: BxBlockAddress::MultipleUploadFileSerializer.new(file_data, params: {url: request.base_url}), status: :ok
			end
			
		end

		def video_list
			if @current_user.present?
				test_type_answer=BxBlockAssessmenttest::SelectAnswer.where(account_id: @token.id).last
				focus_areas=BxBlockAssessmenttest::AssesmentTestTypeAnswer.where(id: test_type_answer&.multiple_answers).pluck(:id).map{|x| x.to_s}				
				file_id = BxBlockUpload::MultipleUploadFile.where(choose_file: 'videos').pluck(:id)
				file=BxBlockUpload::FileType.joins(:multiple_upload_file).where(multiple_upload_file_id: file_id)
				file_data=[]
				file.each do |f|
					f.focus_areas.delete("")
					fc=f.focus_areas.map{|x| x.to_s}
					if !(fc & focus_areas).empty?
						file_data<<f
					end
				end
				render json: BxBlockAddress::MultipleUploadFileSerializer.new(file_data, params: {url: request.base_url}), status: :ok
			end
			
		end

		def docs_list
			if @current_user.present?
				test_type_answer=BxBlockAssessmenttest::SelectAnswer.where(account_id: @token.id).last
				focus_areas=BxBlockAssessmenttest::AssesmentTestTypeAnswer.where(id: test_type_answer&.multiple_answers).pluck(:id).map{|x| x.to_s}				
				file_id = BxBlockUpload::MultipleUploadFile.where(choose_file: 'docs').pluck(:id)
				file=BxBlockUpload::FileType.joins(:multiple_upload_file).where(multiple_upload_file_id: file_id)
				file_data=[]
				file.each do |f|
					f.focus_areas.delete("")
					fc=f.focus_areas.map{|x| x.to_s}
					if !(fc & focus_areas).empty?
						file_data<<f
					end
				end
				render json: BxBlockAddress::DocItemSerializer.new(file_data, params: {url: request.base_url}), status: :ok
			end
		end

		def suggestion
			if @current_user.present?
				render json: BxBlockAddress::SuggestionSerializer.new(@current_user, params: {url: request.base_url}), status: :ok
			end
		end
		
		private 

		def account_user
			@current_user = AccountBlock::Account.find_by(id: @token.id)
		end
	end
end