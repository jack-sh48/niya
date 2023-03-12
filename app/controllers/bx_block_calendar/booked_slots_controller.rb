require 'uri'
require 'net/http'
require 'jwt'
require 'securerandom'

module BxBlockCalendar
  class BookedSlotsController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    before_action :track_login, only: [:video_call]

    $api_key = ENV['API_KEY']
    $secret_key = ENV['SECRET_KEY']
    TIME_ZONE='Asia/Kolkata'
    TIME_FORMAT='%Y-%m-%d %H:%M:%S'
    ERR_MSG='No bookings'
    
    def index
      byebug
      if !current_user.user_booked_slots.blank?
        booked_slots = []
        all_booked_slots = current_user&.user_booked_slots
        all_booked_slots.each do |slot|
          if Time.parse(slot.end_time).localtime > Time.strptime(Time.now.in_time_zone(TIME_ZONE).to_s, TIME_FORMAT)
            booked_slots<<slot
          end
        end
        render json: BxBlockCalendar::BookedSlotSerializer.new(booked_slots, params:{url: request.base_url})
      else
        render json: {errors: [
          {availability: ERR_MSG},
        ]}, status: :unprocessable_entity
      end
    end

    def create
      book_appoint = BxBlockAppointmentManagement::BookedSlot.new(book_params)
      book_appoint.service_user = current_user
      meeting_data = create_meetings
      book_appoint.meeting_code = meeting_data[:meetingId]
      if book_appoint.save
        availability = BxBlockAppointmentManagement::Availability.find_by("service_provider_id = ? and availability_date = ?", book_appoint.service_provider_id, book_appoint.booking_date.strftime("%d-%m-%Y").to_s.gsub("-","/"))
        availability.available_slots_count -= 1
        availability.timeslots.each_with_index do |timeslot, index|
          if Time.parse(timeslot["to"]).strftime("%H:%M")==book_appoint.end_time.split[1] and Time.parse(timeslot["from"]).strftime("%H:%M")==book_appoint.start_time.split[1]
            matched_slot = availability.timeslots[index]
            matched_slot["booked_status"] = true
            availability.timeslots[index] = matched_slot
            availability.save
            break
          end
        end
        device_token = UserDeviceToken.find_by(account_id: current_user.id)&.device_token
        fcm_client = FCM.new(ENV['FCM_SERVER_KEY'])
        options = {
          priority: "high",
          collapse_key: "updated_score",
          data: {
            type: 'booking'
          },
          notification: {
            title: "Appointment Booked",
            body: "Your appointment booked successfully for "+Date.parse(params[:booking_date]).to_s+' at '+ Time.parse(params[:start_time]).strftime("%H:%M %p")
          }
        }
        fcm_client.send(device_token, options)
        render json: BxBlockCalendar::BookedSlotSerializer.new(book_appoint, params: {meeting_data: meeting_data}), status: :created
      else
        error_hash = {}
        book_appoint.errors.messages.each_pair do |column_name, message|
          error_hash[column_name] = message.first
        end
        render json: {
          errors: [error_hash]
        }
      end
    end

    def view_coach_availability
      all_coaches=[]
      test_type_answer=BxBlockAssessmenttest::SelectAnswer.where(account_id: @token.id).last
      focus_areas=BxBlockAssessmenttest::AssesmentTestTypeAnswer.where(id: test_type_answer&.multiple_answers).pluck(:id).map{|x| x.to_s}
      coaches = BxBlockAppointmentManagement::Availability.where(availability_date: params[:booking_date]).where('timeslots @> ?', [{"booked_status": false}].to_json)
      coaches.each do |coach|
        account = AccountBlock::Account.find(coach.service_provider_id)
        all_coaches<< coach if check_coach_expertise(coach, focus_areas) and account.activated
      end
      render json: BxBlockAppointmentManagement::CheckCoachAvailabilitySerializer.new(all_coaches, params: {start_time_param: params[:start_time], url: request.base_url, focus_areas: focus_areas})
    end

    def current_coach
      if !current_user.user_booked_slots.blank?
        booked_slots=[]
        all_booked_slots = current_user&.user_booked_slots
        all_booked_slots.each do |slot|
          if Time.parse(slot.end_time).localtime >= Time.strptime(Time.now.in_time_zone(TIME_ZONE).to_s, TIME_FORMAT)
            booked_slots<<slot
          end
        end
        booked_slots = booked_slots.map(&:service_provider_id).uniq
        accounts = AccountBlock::Account.where(id: [booked_slots])
        render json: BxBlockCalendar::CurrentCoachSerializer.new(accounts, params:{url: request.base_url})
      else
        render json: {errors: [
          {availability: ERR_MSG},
        ]}, status: :unprocessable_entity
      end
    end

    def past_coach
      if !current_user.user_booked_slots.blank?
        booked_slots=[]
        all_booked_slots = current_user&.user_booked_slots
        all_booked_slots.each do |slot|
          if Time.parse(slot.end_time).localtime <= Time.strptime(Time.now.in_time_zone(TIME_ZONE).to_s, TIME_FORMAT)
            booked_slots<<slot
          end
        end
        booked_slots = booked_slots.map(&:service_provider_id).uniq
        accounts = AccountBlock::Account.where(id: [booked_slots])
        render json: BxBlockCalendar::CurrentCoachSerializer.new(accounts, params:{url: request.base_url})
      else
        render json: {errors: [
          {availability: ERR_MSG},
        ]}, status: :unprocessable_entity
      end
    end

    def coach_with_upcoming_appointments
      if current_user
        user=AccountBlock::Account.find(params[:service_provider_id])
        render json: BxBlockCalendar::CoachWithAppointmentSerializer.new(user, params:{url: request.base_url, current_user: current_user})
      else
        render json: {errors: [
          {availability: ERR_MSG},
        ]}, status: :unprocessable_entity
      end
    end

    def coach_with_past_appointments
      if current_user
        user=AccountBlock::Account.find(params[:service_provider_id])
        render json: BxBlockCalendar::CoachWithPastAppointmentSerializer.new(user, params:{url: request.base_url, current_user: current_user})
      else
        render json: {errors: [
          {availability: ERR_MSG},
        ]}, status: :unprocessable_entity
      end
    end

    def user_appointments
      if current_user.role_id == BxBlockRolesPermissions::Role.find_by_name(:coach).id
        user = AccountBlock::Account.find(params[:service_user_id])
        all_booked_slots = BxBlockAppointmentManagement::BookedSlot.where("service_user_id = ? and service_provider_id = ?", user, current_user.id)
        render json: BxBlockAppointmentManagement::CoachAppointmentSerializer.new(all_booked_slots)
      end
    end

    def coach_upcoming_appointments
      if current_user.role_id == BxBlockRolesPermissions::Role.find_by_name(:coach).id
        all_booked_slots = []
        booked_slots = BxBlockAppointmentManagement::BookedSlot.where("service_provider_id = ?", current_user.id)
        booked_slots.each do |slot|
          if Time.parse(slot.end_time).localtime >=Time.strptime(Time.now.in_time_zone(TIME_ZONE).to_s, TIME_FORMAT)
            all_booked_slots<<slot
          end
        end
        render json: BxBlockAppointmentManagement::CoachAppointmentSerializer.new(all_booked_slots)
      end
    end

    def coach_past_appointments
      if current_user.role_id == BxBlockRolesPermissions::Role.find_by_name(:coach).id
        all_booked_slots = []
        booked_slots = BxBlockAppointmentManagement::BookedSlot.where("service_provider_id = ?", current_user.id)
        booked_slots.each do |slot|
          if Time.parse(slot.end_time).localtime <=Time.strptime(Time.now.in_time_zone(TIME_ZONE).to_s, TIME_FORMAT)
            all_booked_slots<<slot
          end
        end
        render json: BxBlockAppointmentManagement::CoachAppointmentSerializer.new(all_booked_slots)
      end
    end

    def user_action_item
      if current_user
        account=AccountBlock::Account.find(params[:service_user_id])
        action_item = account.action_items.create(action_item: params[:action_item], date: params[:date])
        render json: action_item
      end
    end

    def video_call
      if current_user
        render json: {message: "Video call started"}, status: 200
      end
    end

    private

    def check_coach_expertise(object, params)
      account = AccountBlock::Account.find(object.service_provider_id)
      account.expertise = [] if account.expertise.nil?
      account.expertise.delete("") if account.expertise.include?("")
      expertise = ["specialization"].product(JSON.parse(account.expertise.to_s)).map { |a| [a].to_h}
      expertise.delete_at(0) if expertise&.first&.values&.first == ""
      expertise&.each do |exp|
        expertise_focus_areas = CoachSpecialization.where('lower(expertise) LIKE ?', "%"+exp.values.first.to_s.downcase+"%")&.last&.focus_areas
        expertise_focus_areas = expertise_focus_areas.map {|exp_fc| exp_fc.to_s}
        if !(expertise_focus_areas & params).empty?
          return true
        end
      end
      return false
    end

    def book_params
      add_time_with_date
      params.require(:booked_slot).permit(:start_time, :end_time, :service_provider_id, :booking_date)
    end

    def current_user
      byebug
      return unless @token
      @current_user ||= AccountBlock::Account.find(@token.id)
    end

    def add_time_with_date
      booked_slot = params[:booked_slot]
      booked_slot[:start_time] = booked_slot[:booking_date]+" "+booked_slot[:start_time]
      booked_slot[:end_time] = booked_slot[:booking_date]+" "+booked_slot[:end_time]
    end

    def generate_token()
      payload = {
        apikey: ENV['API_KEY'],
        permissions: ["allow_join", "allow_mod", "ask_join"]
      }
      token = JWT.encode(payload, ENV['SECRET_KEY'], 'HS256')
      return token
    end

    def create_meetings
      url = URI("https://api.videosdk.live/v1/meetings")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(url, 'Content-Type' => 'application/json')
      request['authorization'] = generate_token
      user_meeting_id = SecureRandom.alphanumeric(10)
      request.body = {region: 'in001', user_meeting_id: user_meeting_id}.to_json # region: sg001 || in002 || eu001 ||
      # us001
      response = http.request(request)
      meeting_data= eval(response.read_body).merge(token: request['authorization'])
      return meeting_data
    end

    def track_login
      return if current_admin_user

      validate_json_web_token if request.headers[:token] || params[:token]

      return unless @token
      account = AccountBlock::Account.find(@token.id)
      return unless account&.role_id.present?

      if account and AccountBlock::Account.find(account&.id).role_id == BxBlockRolesPermissions::Role.find_by_name(:employee).id
        BxBlockTimeTrackingBilling::TimeTrackService.call(AccountBlock::Account.find(account.id), true)
      end
    end
  end
end
