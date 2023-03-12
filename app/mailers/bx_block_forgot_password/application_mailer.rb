module BxBlockForgotPassword
  class ApplicationMailer < BuilderBase::ApplicationMailer
    default from: 'hello@niya.app'
    layout 'mailer'
  end
end
