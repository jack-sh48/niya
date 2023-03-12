module BxBlockAssessmenttest	
	class Goal < ApplicationRecord
		self.table_name = :goals
		belongs_to :account, class_name: 'AccountBlock::Account', foreign_key: 'account_id'
	end
end