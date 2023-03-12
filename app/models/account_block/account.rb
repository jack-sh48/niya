module AccountBlock
  class Account < AccountBlock::ApplicationRecord
    self.table_name = :accounts

    include Wisper::Publisher
    has_many :provider_booked_slots, class_name: 'BxBlockAppointmentManagement::BookedSlot', foreign_key: "service_provider_id"
    has_many :user_booked_slots, class_name: 'BxBlockAppointmentManagement::BookedSlot', foreign_key: "service_user_id"
    has_secure_password
    before_validation :parse_full_phone_number
    # before_create :generate_api_key
    # has_one :blacklist_user, class_name: 'AccountBlock::BlackListUser', dependent: :destroy
    # after_save :set_black_listed_user
    has_many :action_items, class_name: 'BxBlockAssessmenttest::ActionItem', dependent: :destroy
    has_many :goals, class_name: 'BxBlockAssessmenttest::Goal', dependent: :destroy
    has_many :assess_select_answers, class_name: 'BxBlockAssessmenttest::AssessSelectAnswer', dependent: :destroy  #, foreign_key: 'assess_select_answer_id'
    has_many :focus_areas, class_name: 'BxBlockAssessmenttest::FocusArea'
    has_many :choose_answers, class_name: 'BxBlockAssessmenttest::ChooseAnswer', dependent: :destroy
    has_many :select_answers, class_name: 'BxBlockAssessmenttest::SelectAnswer', dependent: :destroy
    has_one :motion, class_name: 'BxBlockAssessmenttest::Motion'
    has_one :choose_motion_answer, class_name: 'BxBlockAssessmenttest::ChooseMotionAnswer', dependent: :destroy
    has_many :select_motions, class_name: 'BxBlockAssessmenttest::SelectMotion'
    has_many :user_languages, dependent: :destroy
    has_many :summary_tracks, class_name: 'BxBlockTimeTrackingBilling::SummaryTrack', dependent: :destroy, foreign_key: "account_id"
    accepts_nested_attributes_for :user_languages, allow_destroy: true
    enum status: %i[regular suspended deleted]
    enum gender: %i[Male Female Other]
    has_one_attached :image
    has_many :time_tracks, class_name: "BxBlockTimeTrackingBilling::TimeTrack"
	  scope :get_users, ->(name) { where("lower(full_name) LIKE ?", "%"+name.downcase+"%") }


    # validates :full_phone_number, uniqueness: true, presence: true
    scope :active, -> { where(activated: true) }
    scope :existing_accounts, -> { where(status: ['regular', 'suspended']) }
    # before_update :set_full_name
    validate :check_access_code_requirement, on: :create
    before_create :set_role
    after_create :send_notification

    def send_notification
      admins = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(:admin)&.id)
      device_tokens = UserDeviceToken.where(account_id: admins.pluck(:id))
      fcm_client = FCM.new(ENV['FCM_SERVER_KEY'])
      options = {
        priority: "high",
        collapse_key: "updated_score",
        data: {
          type: 'admin notify'
        },
        notification: {
          title: "User signed up",
          body: self&.full_name.to_s+' signed up now.'
        }
      }
      registration_ids = device_tokens&.pluck(:device_token)
      registration_ids.each_slice(20) do |registration_id|
        response = fcm_client.send(registration_id, options)
      end
    end


    def is_online?
      updated_at > 10.minutes.ago
    end

    private
    def set_role
      if Company.find_by(hr_code: self.access_code)
        self.role_id = BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:hr]).id
      elsif Company.find_by(employee_code: self.access_code)
        self.role_id = BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:employee]).id
      end
    end

    def set_full_name
      self.full_name = "#{self.first_name} #{self.last_name}"
    end

    def parse_full_phone_number
      phone = Phonelib.parse(full_phone_number)
      self.full_phone_number = phone.sanitized
      self.country_code      = phone.country_code
      self.phone_number      = phone.raw_national
    end

    def valid_phone_number
      unless Phonelib.valid?(full_phone_number)
        errors.add(:full_phone_number, "Invalid or Unrecognized Phone Number")
      end
    end

    def generate_api_key
      loop do
        @token = SecureRandom.base64.tr('+/=', 'Qrt')
        break @token unless Account.exists?(unique_auth_id: @token)
      end
      self.unique_auth_id = @token
    end

    def set_black_listed_user
      if is_blacklisted_previously_changed?
        if is_blacklisted
          AccountBlock::BlackListUser.create(account_id: id)
        else
          blacklist_user.destroy
        end
      end
    end

    def check_access_code_requirement
      if self.access_code.present?
        if !Company.find_by("hr_code = ? or employee_code = ?", self.access_code, self.access_code)
          self.errors.add(:base, "Invalid Access Code")
        end
      else
          self.errors.add(:base, "Invalid Access Code")
      end
    end

  end
end
