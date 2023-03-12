require 'rails_helper'

RSpec.describe AnswerWellBeing, type: :model do
  describe "Associatoins" do
    it  "Should belongs question_well_being" do
     ans_well_being =  AnswerWellBeing.reflect_on_association(:question_well_being)
     expect(ans_well_being.macro).to eq(:belongs_to)  
    end
  end
end