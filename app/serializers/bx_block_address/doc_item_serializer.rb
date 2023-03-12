module BxBlockAddress
	class DocItemSerializer < BuilderBase::BaseSerializer
		include JSONAPI::Serializer
		require 'open-uri'


		attributes :file_info do |j, params|
			file = []
			if j.multiple_file.attached? && params[:url]
				file_details={
					title: j.file_name,
					description: j.file_discription,
					focus_areas: j.focus_areas,
					url: params[:url] + Rails.application.routes.url_helpers.rails_blob_path(j.multiple_file,only_path: true), 
					content_type: j.multiple_file.content_type,
					text_file_to_str: j.text_file_to_str
				} 

				fileurl=params[:url] + Rails.application.routes.url_helpers.rails_blob_path(j.multiple_file,
				only_path: true) if j.multiple_file.attached? && params[:url]
				file_content=nil
				begin
					status = Timeout::timeout(10) do
						open(fileurl) { |f| 
							file_content=f.read.force_encoding("ISO-8859-1").encode("UTF-8")
						}
					end
				rescue => exception
					
				end

				file_details&.store(:file_content,file_content)
				file<<file_details
			end
   	  file 
		end
	end
end


