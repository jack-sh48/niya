# require 'rails_helper'

# RSpec.describe Company, type: :model do


#    before(:each) do
#      @user = Company.create(name: "sfadsfdg", email: "aersest@gmail.com", hr_code: 45670, employee_code: 9076)
#         @user.save!
#         saved_file = @user.image.attach(io: File.open(Rails.root.to_s+"/spec/fixtures/img_lights.jpg"), filename: "img_lights.jpg", content_type: "image/jpg")
#    end

#    describe "Upload image" do
#       context "with a valid image" do   

#         it "saves the image" do       
#           expect(@user.image).to be_attached
#         end
#       end
#     end


# subject {
#     described_class.new(name: "Anything",
#                         email: "Lorem@gmail.com",
#                         hr_code: 345678,
#                         employee_code: 98765 )
#   }

#   it 'is valid withname' do
#     expect(subject).to be_valid
#   end


#   it "is not valid without a name" do
#     subject.name = nil
#     expect(subject).to_not be_valid
#   end

#   it "is not valid without a email" do
#     subject.email = nil
#     expect(subject).to_not be_valid
#   end

#   it "is not valid without a hr_code" do

#     subject.hr_code = nil
#     expect(subject).to_not be_valid
#   end
 
#   it "is not valid without a employee_code" do
#     subject.employee_code = nil
#     expect(subject).to_not be_valid
#   end
# end
