module AccountBlock
  class AccountsController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :validate_json_web_token, only: [:search, :update, :get_hr_details]

    def create
      case params[:data][:type] #### rescue invalid API format
      when 'sms_account'
        validate_json_web_token

        unless valid_token?
          return render json: {errors: [
            {token: 'Invalid Token'},
          ]}, status: :bad_request
        end

        begin
          @sms_otp = SmsOtp.find(@token[:id])
        rescue ActiveRecord::RecordNotFound => e
          return render json: {errors: [
            {phone: 'Confirmed Phone Number was not found'},
          ]}, status: :unprocessable_entity
        end

        params[:data][:attributes][:full_phone_number] =
          @sms_otp.full_phone_number
        @account = SmsAccount.new(jsonapi_deserialize(params))
        @account.activated = true
        if @account.save
          render json: SmsAccountSerializer.new(@account, meta: {
            token: encode(@account.id)
          }).serializable_hash, status: :created
        else
          render json: {errors: format_activerecord_errors(@account.errors)},
            status: :unprocessable_entity
        end

      when 'email_account'
        account_params = params["data"]["attributes"]

        query_email = account_params['email'].downcase
        query_phone = account_params['full_phone_number']
        account = EmailAccount.where('LOWER(email) = ?', query_email).first && EmailAccount.where('full_phone_number = ?',query_phone).first
        if account.present?
          return render json: {errors: [{account: 'Email and phone number already taken'}]}, status: :unprocessable_entity
        end

        query_email = account_params['email'].downcase
        account = EmailAccount.where('LOWER(email) = ?', query_email).first
        if account.present?
          return render json: {errors: [{account: 'Email already taken'}]}, status: :unprocessable_entity
        end

        query_phone = account_params['full_phone_number']
        phone = EmailAccount.where('full_phone_number = ?',query_phone).first
        if phone.present?
          return render json: {errors: [{account: 'Phone number already taken'}]}, status: :unprocessable_entity
        end

        validator = EmailValidation.new(account_params['email'])
        password_validator = PasswordValidation.new(account_params['password_confirmation'])

        is_valid = validator.valid?
        password_valid = password_validator.valid?

        # error_message = password_validation.errors.full_messages.first

        unless is_valid
          error_message = validator.errors.full_messages.first
          return render json: {errors: [{Email: error_message}]}, status: :unprocessable_entity
        end
        unless password_valid
          rule = "Password should be a minimum of 8 characters long,contain both uppercase and lowercase characters,at least one digit,and one special character."
            error_message = password_validator.errors.full_messages.first
            return render json: {errors: [{Password: "#{rule}"}]}, status: :unprocessable_entity
        end

        unless Phonelib.valid?(account_params['full_phone_number'])
            return render json: {errors: [{full_phone_number: "Invalid or Unrecognized Phone Number"}]}, status: :unprocessable_entity
        end
        @account = EmailAccount.new(full_name: account_params[:full_name], email: account_params[:email], full_phone_number: account_params[:full_phone_number], password: account_params[:password], password_confirmation: account_params[:password_confirmation], access_code: account_params[:access_code])
        if @account.password == @account.password_confirmation
          if @account.save
            @account.update(activated: true)

            user_account = AccountBlock::Account.find_by(email: @account.email)
            account_role = BxBlockRolesPermissions::Role.find(user_account&.role_id)&.name
            if account_role=='hr' or account_role=='employee'
              account_status=StatusAudit.where(account_id: user_account.id)&.last
              if account_status&.logged_time&.year != Time.now.year and Time.now.month != account_status&.month.to_i
                account_status = StatusAudit.create(account_id: user_account.id, active: true, logged_time: Time.now, month: Time.now.month)
              end
            end

            render json: EmailAccountSerializer.new(@account, meta: {token: encode(@account.id)}).serializable_hash, status: :created
          else
            render json: {errors: [{full_phone_number: @account&.errors[:base]&.first}]}, status: :unprocessable_entity
          end
        else
          render json: {errors: [{Password: "Password and Confirm Password Not Matched"}]},
            status: :unprocessable_entity
        end

      when 'social_account'
        @account = SocialAccount.new(jsonapi_deserialize(params))
        @account.password = @account.email
        if @account.save
          render json: SocialAccountSerializer.new(@account, meta: {
            token: encode(@account.id),
          }).serializable_hash, status: :created
        else
          render json: {errors: format_activerecord_errors(@account.errors)},
            status: :unprocessable_entity
        end

      else
        render json: {errors: [
          {account: 'Invalid Account Type'},
        ]}, status: :unprocessable_entity
      end
    end

    def update
      if current_user
        if current_user.email != params[:account]['email']
          query_email = params[:account]['email'].downcase
          account = EmailAccount.where('LOWER(email) = ?', query_email).first
          if account.present?
            return render json: {errors: [{account: 'Email already taken'}]}, status: :unprocessable_entity
          end
          validator = EmailValidation.new(params[:account]['email'])

          is_valid = validator.valid?

          unless is_valid
            error_message = validator.errors.full_messages.first
            return render json: {errors: [{Email: error_message}]}, status: :unprocessable_entity
          end
        end

        current_user.update(update_coach_params)
        current_user.gender = params[:account][:genders].to_i
        current_user.phone_number = params[:account][:phone_number].to_i
        current_user.save
        render json: AccountBlock::AccountSerializer.new(current_user)
      end
    end

    def get_hr_details
      if current_user.role_id == BxBlockRolesPermissions::Role.find_by_name(:hr).id
        render json: AccountBlock::HrSerializer.new(current_user)
      end
    end

    def privacy_policy
      begin
        file = PrivacyPolicy&.first&.policy_content
        render json: {data: [file]}
      rescue Exception => e
        render json:{errors: [
          {policy: 'No Data Found'},
        ]}
      end
    end

    private
    def encode(id)
      BuilderJsonWebToken.encode id
    end

    def search_params
      params.permit(:query)
    end

    def update_coach_params
      params.require(:account).permit(:first_name, :last_name, :gender, :email, :phone_number, :image)
    end

    def current_user
      return unless @token
      @current_user ||= AccountBlock::Account.find(@token.id)
    end

  end
end
