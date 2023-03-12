module BxBlockAssessmenttest
	class ActionItemsController < ApplicationController
		include BuilderJsonWebToken::JsonWebTokenValidation
		before_action :validate_json_web_token
    before_action :track_login, only: [:start_game]
		before_action :account_user
		def create
			@action = BxBlockAssessmenttest::ActionItem.new(create_params.merge(account_id: @current_user.id))
			if @action.save
				render json: BxBlockAddress::ActionItemSerializer.new(@action).serializable_hash, status: :created
			else
				render json: {errors: [message: "Action item not created"]},status: :unprocessable_entity
			end
		end

		def update
			@action = BxBlockAssessmenttest::ActionItem.find_by(id: params[:id])
			if @action.present?
				@action.update(update_params)
				render json: BxBlockAddress::ActionItemSerializer.new(@action, meta:{message: "updated successfully"}).serializable_hash, status: :ok
			else
				render json: {errors: [message: "Action item not found/updated"]}
			end
		end

		def current_actions
			@actions = @current_user&.action_items.all.order(created_at: 'desc')
			if @actions.present?
				render json: BxBlockAddress::ActionItemSerializer.new(@actions).serializable_hash, status: :ok
			else
				render json: {message: "actions not found"}
			end
		end

		# def completed_actions
		# 	@actions = @current_user.action_items.all.where(complete: true)
		# 	if @actions.present?
		# 		render json: BxBlockAddress::ActionItemSerializer.new(@actions).serializable_hash, status: :ok
		# 	else
		# 		render json: {message: "actions not found"}
		# 	end
		# end

		def destroy
			@action = BxBlockAssessmenttest::ActionItem.find_by(id: params[:id])
			if @action.present?
				@action.destroy
				render json: {message:["Action Deleted"]}
			else
				render json: {message: ["Action Not Found"]}
			end
		end

		# def complete
		# 	@action = BxBlockAssessmenttest::ActionItem.find_by(id: params[:id])
		# 	if @action.present?
		# 		if !@action.completed == true
		# 			@action.update(completed: true)
		# 			render json: {message:["Action Completed"]}
		# 		else
		# 			render json: {message:["Action Already Completed"]}
		# 		end
		# 	else
		# 		render json: {message: ["Action Not Found"]}
		# 	end
		# end

		# def complete_date
		# 	@action = BxBlockAssessmenttest::ActionItem.find_by(id: params[:id])
		# 	if @action.present?
		# 		if !@action.completed == true
		# 			@action.update(date: params[:date], completed: true)
		# 			render json: {message:["action will complete till:", "#{params[:date]}"]}
		# 		else
		# 			render json: {message:["Action Already Completed"]}
		# 		end
		# 	else
		# 		render json: {message: ["Action Not Found"]}
		# 	end
		# end

		def start_game
			if account_user
        render json: {message: "Games started"}, status: 200
      end
    end

		private

		def account_user
			@current_user = AccountBlock::Account.find_by(id: @token.id)
		end

		def create_params
			params.permit(:action_item, :date, :time_slot)
		end

		def update_params
			params.permit(:action_item, :complete, :date, :time_slot)
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