require 'rails_helper'
RSpec.describe CoachAvailabilityWorker, type: :worker do
    coach_account = Support::SharedHelper.new.get_coach_user

    it "should create availability for single coach" do
        coach = AccountBlock::Account.find_by(id: coach_account.id)
        expect { CoachAvailabilityWorker.new.perform(coach_account.id) }.to change { BxBlockAppointmentManagement::Availability.where(service_provider_id: coach.id).count }.by_at_least(1)
    end
end
