module BxBlockRating
    class CoachRating < ApplicationRecord
        validates :account_id, presence: true
        validates :coach_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true 
    end
end
