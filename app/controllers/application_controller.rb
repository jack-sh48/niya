class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  include BuilderJsonWebToken::JsonWebTokenValidation

  before_action :track_login

  private

  def track_login
    return if current_admin_user

    validate_json_web_token if request.headers[:token] || params[:token]

    return unless @token
    begin
      account = AccountBlock::Account.find(@token.id)
    end
    unless account&.role_id.nil?
      return unless account and AccountBlock::Account.find(account&.id).role_id == BxBlockRolesPermissions::Role.find_by_name(:employee).id
    end

    BxBlockTimeTrackingBilling::TimeTrackService.call(AccountBlock::Account.find(account.id))
  end
end
