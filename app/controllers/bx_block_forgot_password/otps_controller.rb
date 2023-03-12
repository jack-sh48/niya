module BxBlockForgotPassword
  class OtpsController < ApplicationController
    def create
      if params['email'].present?
        @email_account = AccountBlock::Account.where("LOWER(email) = ?", params['email'].downcase).last
      elsif params['full_phone_number'].present?
        phone = Phonelib.parse(params['full_phone_number']).sanitized
        @sms_account = AccountBlock::Account.where(full_phone_number:  params['full_phone_number']).last
      else
        return render json: {
          errors: [{
            otp: 'Email or phone number are required',
          }],
        }, status: :unprocessable_entity
      end  

        # forget_hash = {meta: {token: token_for(@sms_account, @sms_account.id)}}
        # @sms_account.generate_pin_and_valid_date

        if @sms_account.present?
          puts "sms"
          sms_otp = AccountBlock::SmsOtp.new(full_phone_number: @sms_account.full_phone_number)
          # forget_hash["sms_otp"] = serialized_sms_otp(sms_otp, @sms_account.id) if sms_otp.save
          if sms_otp.save
            render json: {message: "#{sms_otp.pin} sms otp send successfully.", meta: {token: token_for(@sms_account, @sms_account.id)}},status: :ok
          end

        elsif @email_account.present?
          email_otp = AccountBlock::EmailOtp.new(email: @email_account.email)
          if email_otp.save
            send_email_for email_otp
            render json: {email: "#{email_otp.pin} otp send successfully.",meta: {token: token_for(@email_account, @email_account.id)}}
          end 
        else 
           render json: {errors: [{account: "account not found.",}],}, status: :unprocessable_entity
        end

    end

    private

    def create_params
      params.require(:data)
        .permit(*[
          :email,
          :full_phone_number
        ])
    end

    def send_email_for(otp_record)
      EmailOtpMailer
        .with(otp: otp_record, host: request.base_url)
        .otp_email.deliver
    end

    def serialized_email_otp(email_otp, account_id)
      #token = token_for(email_otp, account_id)
      EmailOtpSerializer.new(
        email_otp
      ).serializable_hash
    end



    def token_for(otp_record, account_id)
      BuilderJsonWebToken.encode(
        otp_record.id,
        5.minutes.from_now,
        type: otp_record.class,
        account_id: account_id,
        token_type: 'forgot_password',
        activated: false
      )
    end
  end
end