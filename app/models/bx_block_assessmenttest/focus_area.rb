module BxBlockAssessmenttest
	class FocusArea < ApplicationRecord
		belongs_to :account, class_name: 'AccountBlock::Account'
	end
end