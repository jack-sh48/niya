module BxBlockAssessmenttest
	class ChooseMotionAnswer < ApplicationRecord
		self.table_name = :choose_motion_answers
		belongs_to :account, class_name: 'AccountBlock::Account'
	end
end

