module BxBlockAssessmenttest
	class GoalsController < ApplicationController
		include BuilderJsonWebToken::JsonWebTokenValidation
		before_action :validate_json_web_token
		before_action :account_user
		def create
			@goal = BxBlockAssessmenttest::Goal.new(create_params.merge(account_id: @current_user&.id))
			if @goal.save!
				@goal.update(complete: false)
				render json: BxBlockAddress::GoalSerializer.new(@goal).serializable_hash, status: :created
			else
				render json: {errors: @goal.errors}
			end
		end

		def update
			@goal = BxBlockAssessmenttest::Goal.find_by(id: params[:id])
			if @goal&.present?
				@goal.update(update_params)
				render json: BxBlockAddress::GoalSerializer.new(@goal, meta:{message: "updated successfully"}).serializable_hash, status: :ok
			else
				render json: {errors: [message: "goal not found/updated"]}
			end
		end

		def current_goals
			@cur_goals = @current_user&.goals&.all.order(created_at: 'desc').where(complete: false)
			if @cur_goals.present?
				render json: BxBlockAddress::GoalSerializer.new(@cur_goals).serializable_hash, status: :ok 
			else
				render json: {message: "goals not found"}
			end
		end

		def completed_goals
			@goals = @current_user&.goals.all.order(created_at: 'desc').where(complete: true)
			if @goals.present?
				render json: BxBlockAddress::GoalSerializer.new(@goals).serializable_hash, status: :ok 
			else
				render json: {message: "goals not found"}
			end
		end

		def goal_boards
			if @current_user.present?
				render json: BxBlockAddress::GoalBoardSerializer.new(@current_user).serializable_hash, status: :ok 
			end
		end

		def destroy
			@goal = BxBlockAssessmenttest::Goal.find_by(id: params[:id])
			if @goal&.present?
				@goal.destroy
				render json: {message:["Goal Deleted"]}
			else
				render json: {message: ["Goal Not Found"]}
			end
		end

		private
		def account_user
			@current_user = AccountBlock::Account.find_by(id: @token.id)
		end

		def create_params
			params.permit(:goal, :date, :time_slot)
		end

		def update_params
			params.permit(:goal, :complete, :date, :time_slot)
		end
	end
end