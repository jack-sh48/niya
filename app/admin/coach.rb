ActiveAdmin.register AccountBlock::Account, as: "coaches" do
  menu priority: 5
  # include BuilderJsonWebToken::JsonWebTokenValidation
  # before_action :validate_json_web_token

  
  permit_params :full_name, :email, :full_phone_number, :password, :password_confirmation, :access_code, :activated,
                :city, :education, expertise: [], user_languages_attributes: [:id, :language, :_destroy]

  filter :full_name, as: :string, label: "Full Name"
  filter :email, as: :string, label: "Email"
  filter :full_phone_number

  after_update :check_activation



  controller do
    def scoped_collection
      @accounts = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:coach]).id)
    end

    def create_availability object
      (Date.today..6.months.from_now).each do |date|
        begin
          BxBlockAppointmentManagement::Availability.create!(start_time: "06:00", end_time: "23:00", availability_date: date.strftime("%d/%m/%Y"), service_provider_id: object.id)
        rescue => exception
          next
        end
      end
    end

    def check_activation object
      unless object.activated
        BxBlockAppointmentManagement::BookedSlot.where(service_provider_id: params[:id]).destroy_all
        slots=nil
        begin
          ActiveRecord::Base.connection.execute("SET datestyle = dmy;")
          slots=BxBlockAppointmentManagement::Availability.where("service_provider_id = ? and Date(availability_date) >=?", object.id, Date.today)
        rescue => exception
          slots=nil
        end
        timeslots = [{"to"=>"06:59 AM", "sno"=>"1", "from"=>"06:00 AM", "booked_status"=>false},
          {"to"=>"07:59 AM", "sno"=>"2", "from"=>"07:00 AM", "booked_status"=>false},
          {"to"=>"08:59 AM", "sno"=>"3", "from"=>"08:00 AM", "booked_status"=>false},
          {"to"=>"09:59 AM", "sno"=>"4", "from"=>"09:00 AM", "booked_status"=>false},
          {"to"=>"10:59 AM", "sno"=>"5", "from"=>"10:00 AM", "booked_status"=>false},
          {"to"=>"11:59 AM", "sno"=>"6", "from"=>"11:00 AM", "booked_status"=>false},
          {"to"=>"12:59 PM", "sno"=>"7", "from"=>"12:00 PM", "booked_status"=>false},
          {"to"=>"01:59 PM", "sno"=>"8", "from"=>"01:00 PM", "booked_status"=>false},
          {"to"=>"02:59 PM", "sno"=>"9", "from"=>"02:00 PM", "booked_status"=>false},
          {"to"=>"03:59 PM", "sno"=>"10", "from"=>"03:00 PM", "booked_status"=>false},
          {"to"=>"04:59 PM", "sno"=>"11", "from"=>"04:00 PM", "booked_status"=>false},
          {"to"=>"05:59 PM", "sno"=>"12", "from"=>"05:00 PM", "booked_status"=>false},
          {"to"=>"06:59 PM", "sno"=>"13", "from"=>"06:00 PM", "booked_status"=>false},
          {"to"=>"07:59 PM", "sno"=>"14", "from"=>"07:00 PM", "booked_status"=>false},
          {"to"=>"08:59 PM", "sno"=>"15", "from"=>"08:00 PM", "booked_status"=>false},
          {"to"=>"09:59 PM", "sno"=>"16", "from"=>"09:00 PM", "booked_status"=>false},
          {"to"=>"10:59 PM", "sno"=>"17", "from"=>"10:00 PM", "booked_status"=>false},
          {"to"=>"11:59 PM", "sno"=>"18", "from"=>"11:00 PM", "booked_status"=>false}]
        slots&.update_all(timeslots: timeslots)
        ActiveRecord::Base.connection.execute("SET datestyle = ymd;")
      end
    end

    def destroy
      AccountBlock::Account.find(params[:id]).destroy
      BxBlockAppointmentManagement::Availability.where(service_provider_id: params[:id]).destroy_all
      BxBlockAppointmentManagement::BookedSlot.where(service_provider_id: params[:id]).destroy_all
      redirect_to admin_coaches_path
    end
    

    def create

      if params[:account][:type] == 'email_account'
        account = AccountBlock::EmailAccount.where('LOWER(email) = ?', params[:account]['email'].downcase).first
        return render json: {errors: [{account: 'Email already taken'}]}, status: :unprocessable_entity if account.present?

        password_validator = AccountBlock::PasswordValidation.new(params[:account]['password_confirmation'])
        password_valid = password_validator.valid?

        unless password_valid
          rule = "Password is invalid.Password should be a minimum of 8 characters long,contain both uppercase and lowercase characters,at least one digit,and one special character."
          return render json: {errors: [{Password: "#{rule}"}]}, status: :unprocessable_entity
        end

        unless Phonelib.valid?(params[:account]['full_phone_number'])
            return render json: {errors: [{full_phone_number: "Invalid or Unrecognized Phone Number"}]}, status: :unprocessable_entity
        end

        @account = AccountBlock::EmailAccount.new(full_name: params[:account][:full_name], email: params[:account][:email], full_phone_number: params[:account][:full_phone_number], password: params[:account][:password], password_confirmation: params[:account][:password_confirmation], expertise: params[:account][:expertise])
        if @account.password == @account.password_confirmation
          @account.role_id = BxBlockRolesPermissions::Role.find_by_name(:coach).id
          if @account.save(validate: false)
            @account.update(activated: true)
            create_availability(@account)
				    # CoachAvailabilityWorker.perform_in(Time.now+30.seconds, @account.id)
            redirect_to admin_coaches_path
          else
            render json: {errors: [{full_phone_number: "already exists"}]}, status: :unprocessable_entity
          end
        else
          render json: {errors: [{Password: "Password and Confirm Password Not Matched"}]},
            status: :unprocessable_entity
        end
      end
    end
  end

  
  index :title=> "Account" do
    selectable_column
    id_column
    column :full_name
    column :email
    column :full_phone_number
    column :activated
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table title: "Account Details" do
      row :full_name
      row :email 
      row :full_phone_number
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      if f.object.new_record?
        f.input :type, :input_html => { :value => "email_account"}, as: :hidden
        f.input :full_name
        f.input :email
        f.input :full_phone_number
        f.input :password
        f.input :password_confirmation
        f.input :expertise, as: :check_boxes, collection: CoachSpecialization.all.pluck(:expertise)
      else
        f.input :full_name
        f.input :email
        f.input :full_phone_number
        f.input :password
        f.input :password_confirmation
        f.input :activated
        f.input :education
        f.input :city
        f.has_many :user_languages, allow_destroy: true do |t|
          t.input :language
        end
        f.input :expertise, as: :check_boxes, collection: CoachSpecialization.all.pluck(:expertise), default: f.object.expertise
      end
    end
    f.actions
  end


end