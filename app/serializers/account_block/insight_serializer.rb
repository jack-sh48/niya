module AccountBlock
    class InsightSerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer

        attributes :top_strength do |object|
            strength=[]
			final_score=nil
			WellBeingCategory.all.each do |cate|
				sub_only_category_questions=QuestionWellBeing.where(category_id: cate.id).where(subcategory_id: nil).pluck(:id)
				sub_userquestionanswer=UserQuestionAnswer.where(question_id: sub_only_category_questions).where(account_id: object.id)
				sub_category_scores=AnswerWellBeing.where(id: sub_userquestionanswer.pluck(:answer_id)).pluck(:score)
				if sub_category_scores.present?
					sub_category_scores = sub_category_scores.map(&:to_i)
				end
				WellBeingSubCategory.where(well_being_category_id: cate&.id).each do |sub_cate|
					cate_questions = QuestionWellBeing.where("category_id = ? and subcategory_id = ?", cate.id, sub_cate&.id)
					questions = UserQuestionAnswer.where("account_id = ?", object.id).where(question_id: cate_questions.all.pluck(:id))
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
					substance_use = sub_cate.sub_category_name != WellBeingSubCategory.where("lower(sub_category_name) LIKE ?", "%"+"Substance Use".downcase+"%")&.last&.sub_category_name
					strength<<{id: sub_cate.id, title: sub_cate.sub_category_name} if score_level == 'high' and substance_use
				end
			end
            strength
        end

        attributes :focus_areas do |object|
            user_focus_areas=nil
            @focus_areas = BxBlockAssessmenttest::SelectAnswer.where(account_id: object.id).last

			if @focus_areas.present?
                user_focus_areas=BxBlockAssessmenttest::AssesmentTestTypeAnswer.where(id: @focus_areas&.multiple_answers)
            end
            user_focus_areas
        end
    end
end