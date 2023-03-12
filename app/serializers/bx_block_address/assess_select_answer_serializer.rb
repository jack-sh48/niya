module BxBlockAddress
	class AssessSelectAnswerSerializer < BuilderBase::BaseSerializer
	attributes *[
      :account_id]

    attributes :question do |object|
      BxBlockAssessmenttest::AssessYourselfTestType.find_by(id: object&.assess_yourself_test_type_id)
    end
    attributes :answer do |object|
      BxBlockAssessmenttest::AssessTtAnswer.find_by(id: object&.assess_tt_answer_id)
    end
	end
end

