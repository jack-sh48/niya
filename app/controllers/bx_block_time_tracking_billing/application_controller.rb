module BxBlockTimeTrackingBilling
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

  end
end
