module BxBlockAssessmenttest	
	class AssesmentTestTypeAnswer < ApplicationRecord
		belongs_to :assesment_test_type, class_name: 'BxBlockAssessmenttest::AssesmentTestType'
	end
end