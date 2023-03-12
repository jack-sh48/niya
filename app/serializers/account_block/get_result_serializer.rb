module AccountBlock
  class GetResultSerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer

    attributes :user_result do |object|
      answers = UserQuestionAnswer.where("account_id = ?", object.id).pluck(:answer_id)

      user_result_for(answers)
    end

    attributes :results do |object|
      result =[]
      final_score=nil
      WellBeingCategory.all.each do |cate|
        catg=[]
        only_category_questions=QuestionWellBeing.where(category_id: cate.id).pluck(:id)
        userquestionanswer=UserQuestionAnswer.where(question_id: only_category_questions).where(account_id: object.id)
        last_question_date=UserQuestionAnswer.where(question_id: only_category_questions).where(account_id: object.id)&.last&.updated_at.to_s
        category_scores=AnswerWellBeing.where(id: userquestionanswer.pluck(:answer_id)).pluck(:score)
        maincatg={}
        if category_scores.present?
          category_scores = category_scores.map(&:to_i)
          cat_count = category_scores.count
          category_final_score = category_scores.reduce(0, :+) if category_scores.length > 0
          category_percentage=(category_final_score*10)/cat_count
          user_answer_result = UserAnswerResult.where(category_id: cate.id)
          user_uar=nil
          cat_score_level=nil
          user_answer_result&.each do |uar|
            if category_final_score>=uar&.min_score and category_final_score<=uar&.max_score
              user_uar=uar&.advice
              cat_score_level=uar.score_level
              break
            end
          end

          maincatg={category_name: cate.category_name, score: category_final_score, question_count: cat_count, percentage: category_percentage, advice: user_uar, submitted_at: Date.parse(last_question_date), score_level: cat_score_level}
        end

        sub_maincatg = {}
        sub_only_category_questions=QuestionWellBeing.where(category_id: cate.id).where(subcategory_id: nil).pluck(:id)
        sub_userquestionanswer=UserQuestionAnswer.where(question_id: sub_only_category_questions).where(account_id: object.id)
        sub_category_scores=AnswerWellBeing.where(id: sub_userquestionanswer.pluck(:answer_id)).pluck(:score)
        sub_maincatg={}
        if sub_category_scores.present?
          sub_category_scores = sub_category_scores.map(&:to_i)
          sub_count = sub_category_scores.count
          sub_category_final_score = sub_category_scores.reduce(0, :+) if sub_category_scores.length > 0
          sub_category_percentage=(sub_category_final_score*10)/sub_count
          sub_maincatg={sub_category: cate.category_name, score: sub_category_final_score, question_count: sub_count, percentage: category_percentage}
        end
        catg<<sub_maincatg

        question=WellBeingSubCategory.where(well_being_category_id: cate&.id).each do |sub_cate|
          cate_questions = QuestionWellBeing.where("category_id = ? and subcategory_id = ?", cate.id, sub_cate&.id)
          questions = UserQuestionAnswer.where("account_id = ?", object.id).where(question_id: cate_questions.all.pluck(:id))
          answers = questions.all.pluck(:answer_id)
          scores=nil
          scores=AnswerWellBeing.where(id: answers).pluck(:score)
            scores = scores.map(&:to_i) 
            count = scores.count
            final_score = scores.length > 0? scores.reduce(0, :+):0 
            percentage=(final_score*10)/count if !count.zero?
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

            catg<<{sub_category: sub_cate.sub_category_name, score: final_score, question_count: count, percentage: percentage, advice: sub_user_uar, score_level: score_level}

        end

          result<<{category_result: maincatg, sub_category_result: catg}
        
      end
      result
    end


    class << self
      private
      def user_result_for(answers)
        scores=AnswerWellBeing.where(id: answers).pluck(:score)
        if scores.present?
          scores = scores.map(&:to_i)
          count = scores.count
          final_score = scores.reduce(0, :+)/count if scores.length > 0
          {final_score: final_score, question_count: answers.count, percentage: (final_score*100)/count}
        end
      end

    end

  end
end
