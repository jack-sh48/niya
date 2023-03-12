require 'rails_helper'

RSpec.describe CoachSpecialization, type: :model do
  it "should have a unique name" do
    CoachSpecialization.create!(:expertise=>"testexapmle")
    expert = CoachSpecialization.new(:expertise=>"testexapmle")
    expert.should_not be_valid
    expert.errors[:expertise].should include("has already been taken")
  end
end