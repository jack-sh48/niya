module BxBlockAddress
	class SuggestionSerializer < BuilderBase::BaseSerializer
		require 'open-uri'

        attributes :docs do |object, params|
            test_type_answer=BxBlockAssessmenttest::SelectAnswer.where(account_id: object.id).last
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

            docs_details(file_data, params)
        end

        attributes :audios do |object, params|
            test_type_answer=BxBlockAssessmenttest::SelectAnswer.where(account_id: object.id).last
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
            media_details(file_data, params)
        end

        attributes :videos do |object, params|
            test_type_answer=BxBlockAssessmenttest::SelectAnswer.where(account_id: object.id).last
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
            media_details(file_data, params)
        end

        class << self
            private
            def media_details(medias, params)
                file = []
                medias.each do |j|
                    focus_a=[]
                    BxBlockAssessmenttest::AssesmentTestTypeAnswer.where(id: j.focus_areas).each do |fa|
                        focus_a<<{id: fa.id, focus_area: fa.answers}
                    end
                    if j.multiple_file.attached? && params[:url]
                        file_details={
                            id: j.id,
                            title: j.file_name,
                            description: j.file_discription,
                            focus_areas: j.focus_areas,
                            user_focus_areas: focus_a,
                            url: params[:url] + Rails.application.routes.url_helpers.rails_blob_path(j.multiple_file,
                            only_path: true), content_type: j.multiple_file.content_type
                        } 
                        file<<file_details
                    end
                end
                file 
		    end

            def docs_details(docs, params)
                file = []
                docs.each do |j|
                    focus_a=[]
                    BxBlockAssessmenttest::AssesmentTestTypeAnswer.where(id: j.focus_areas).each do |fa|
                        focus_a<<{id: fa.id, focus_area: fa.answers}
                    end
                    if j.multiple_file.attached? && params[:url]
                        file_details={
                            id: j.id,
                            title: j.file_name,
                            description: j.file_discription,
                            focus_areas: j.focus_areas,
                            user_focus_areas: focus_a,
                            url: params[:url] + Rails.application.routes.url_helpers.rails_blob_path(j.multiple_file,
                            only_path: true), content_type: j&.multiple_file&.content_type
                        }
                        if j&.multiple_file.record&.text_file_blob&.content_type == "text/plain"
                            file_content= j.text_file.attached? ? j.text_file.download : nil
                        else
                            file_content = j.file_content
                        end

                        file_details.merge!({:file_content => file_content})
                        file<<file_details
                    end
                end
   	            file 
		    end
        end
    end
end