class CoachSpecialization < ApplicationRecord
	validates :expertise, uniqueness: true
end
