class BxBlockWellbeing::WellBeingsController < ApplicationController
  	
	def index
		if current_user and params[:category_id].present?
			questions = QuestionWellBeing.where(category_id: params[:category_id]).order('updated_at asc')
			render json: AccountBlock::QuestionSerializer.new(questions), status: :ok
		end
	end

	def question
		if current_user
			question = QuestionWellBeing.find(params[:id])
			render json: {questions: [question, answers: question.answer_well_beings]}
		end
	end

	def user_answer
		last_question=false
		useranswer = nil
		if current_user
			user = UserQuestionAnswer.where("account_id = ? and question_id = ?", current_user.id, params[:question_id]).last
			if user.present?
				user.update(answer_id: params[:answer_id])
				useranswer = user
			else
				useranswer=UserQuestionAnswer.create(question_id: params[:question_id], answer_id: params[:answer_id], account_id: current_user.id)
			end
			category_id=QuestionWellBeing.find(params[:question_id]).category_id
			flag=QuestionWellBeing.where(category_id: category_id).order('updated_at desc').first.id == params[:question_id]
			last_question=true if flag

			render json: {useranswer: useranswer, last_question: last_question}
		end
	end

	def all_categories
		if current_user
			categories = WellBeingCategory.all
			render json: categories
		end
	end

	def question_categories
		if current_user
			category=WellBeingCategory.find(params[:category_id])
			render json: AccountBlock::QuestionCategorySerializer.new(category)
		end
	end

	def delete_answers
		UserQuestionAnswer.destroy_all
		render json: {message: "All Answers deleted succesfully"}
	end

	def get_result
		if current_user
			device_token = UserDeviceToken.find_by(account_id: current_user.id)&.device_token
			fcm_client = FCM.new(ENV['FCM_SERVER_KEY'])
			options = {
			priority: "high",
			collapse_key: "updated_score",
			data: {
				type: 'wellbeing'
			},
			notification: {
				title: "Assessment Completed",
				body: "You have completed your assessment kindly check your score."
			}
			}
			fcm_client.send(device_token, options)
			render json: AccountBlock::GetResultSerializer.new(current_user), status: :ok
		end
	end

	def user_strength
		if current_user
			data=[]
			final_score=nil
			WellBeingCategory.all.each do |cate|
				sub_only_category_questions=QuestionWellBeing.where(category_id: cate.id).where(subcategory_id: nil).pluck(:id)
				sub_userquestionanswer=UserQuestionAnswer.where(question_id: sub_only_category_questions).where(account_id: current_user.id)
				sub_category_scores=AnswerWellBeing.where(id: sub_userquestionanswer.pluck(:answer_id)).pluck(:score)				
				if sub_category_scores.present?
					sub_category_scores = sub_category_scores.map(&:to_i)
				end
				
				WellBeingSubCategory.where(well_being_category_id: cate&.id).each do |sub_cate|
					cate_questions = QuestionWellBeing.where("category_id = ? and subcategory_id = ?", cate.id, sub_cate&.id)
					questions = UserQuestionAnswer.where("account_id = ?", current_user.id).where(question_id: cate_questions.all.pluck(:id))
					answers = questions.all.pluck(:answer_id)
					scores=nil
					scores=AnswerWellBeing.where(id: answers).pluck(:score)
					scores = scores.map(&:to_i)
					count = scores.count
					final_score = scores.length > 0? scores.reduce(0, :+):0
					sub_user_answer_result = UserAnswerResult.where(category_id: cate.id).where(subcategory_id: sub_cate.id)
					sub_user_uar=nil
					score_level=nil
					sub_user_answer_result&.each do |uar|
						if final_score>=uar&.min_score and final_score<=uar&.max_score
							sub_user_uar=uar&.advice
							score_level=uar&.score_level
							break
						end
					end

					if sub_cate.sub_category_name != WellBeingSubCategory.where("lower(sub_category_name) LIKE ?", "Substance Use")&.last&.sub_category_name
						data<<{id: sub_cate.id, title: sub_cate.sub_category_name} if score_level == 'high'
					end
				end
			end
			render json: data
		end
	end

	def insights
		if current_user
			render json: AccountBlock::InsightSerializer.new(current_user)
		end
	end

	private
    def current_user
      @current_user = AccountBlock::Account.find(@token.id)
    end
end
