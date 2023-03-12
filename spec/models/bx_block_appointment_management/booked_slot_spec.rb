require 'rails_helper'

RSpec.describe BxBlockAppointmentManagement::BookedSlot, type: :model do
  it 'belongs to service provider' do
    coach_account = Support::SharedHelper.new.get_coach_user
    coach = AccountBlock::Account.find_by(id: coach_account.id)
    #coach_availibility = CoachAvailabilityWorker.create()
    #BxBlockAppointmentManagement::BookedSlot.create(service_provider_id: coach.id,service_user_id: 1, booking_date: 04-01-2023, start_time: '06:59', end_time: '11:59' )
  end
end