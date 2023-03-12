module BxBlockAppointmentManagement
  class CoachAppointmentSerializer < BuilderBase::BaseSerializer
    attributes :id

    attribute :appointments do |object|
      appoint_details_for(object)
    end

    class << self
      private

      def appoint_details_for booked_slot
        {
          id: booked_slot.service_user_id,
          name: AccountBlock::Account.find(booked_slot.service_user_id).full_name,
          booking_date: booked_slot.booking_date,
          viewable_slots: "#{booked_slot.start_time} - #{booked_slot.end_time}",
          meeting_code: booked_slot.meeting_code
        }
      end
    end
  end
end
