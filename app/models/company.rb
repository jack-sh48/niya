class Company < ApplicationRecord
	validates :name, :email, presence: true
	validates :hr_code, :employee_code, uniqueness: true
	has_one_attached :image
end
