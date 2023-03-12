require 'rails_helper'

RSpec.describe AccountBlock::Account, type: :model do
  describe "Associatoins" do
    it  "Should have many time tracks" do
     time_track =  AccountBlock::Account.reflect_on_association(:time_tracks)
     expect(time_track.macro).to eq(:has_many)  
    end
  end
end
  

