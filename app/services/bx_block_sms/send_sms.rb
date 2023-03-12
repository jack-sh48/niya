module BxBlockSms
  class SendSms
    attr_reader :to, :text_content

    def initialize(to, text_content)
      @to = to
      @text_content = text_content
    end
    
    # Sms Otp
    def call
      # Provider.send_sms(to, text_content)
      message = "<#> Your verification code is  #{@text_content}"
      # message =  @text_content
      client = Twilio::REST::Client.new(ENV['ACCOUNT_SID'], ENV["AUTH_TOKEN"])
      client.messages.create({
        from: '+18315742648',
        to: "#{@to}",
        body: message
      })
    end
  end
end
