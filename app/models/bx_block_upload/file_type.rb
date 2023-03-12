module BxBlockUpload	
	class FileType < ApplicationRecord
		self.table_name = :file_types
		belongs_to :multiple_upload_file, class_name: 'BxBlockUpload::MultipleUploadFile'
		
		has_one_attached :multiple_file
		has_one_attached :text_file


	end
end
