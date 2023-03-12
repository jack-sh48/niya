class QuestionWellBeing < ApplicationRecord
	has_many :answer_well_beings, dependent: :destroy
	accepts_nested_attributes_for :answer_well_beings, allow_destroy: true
end
