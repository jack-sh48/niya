ActiveAdmin.register BxBlockAssessmenttest::AssessYourselfTestType, as: "AssessYourself Test Type Question" do 
  menu priority: 5
  permit_params :question_title, :assess_yourself_answer_id, :sequence_number, assess_tt_answers_attributes: [:id, :answer, :answer_score, :_destroy]

  form do |f|
    f.semantic_errors :blah
    f.inputs class: 'question' do
      f.input :question_title
      f.input :sequence_number
      f.input :assess_yourself_answer_id

    end

    f.inputs class: 'multiple_answers' do
      has_many :assess_tt_answers, allow_destroy: true do |ans|
        ans.input :answer
        ans.input :answer_score
      end
    end
    f.actions
  end

  index do
      selectable_column
      column :id
      column :assess_yourself_answer_id
      column :question_title
      column :sequence_number
      column :assess_tt_answer_ids
      actions
  end

  show do
    attributes_table do
      row "Question" do |top|
        top.question_title
      end
      row "Sequence Number" do |top|
        top.sequence_number
      end
      row "Assess Yourself Answer id" do |top|
        top.assess_yourself_answer_id
      end
    end
    panel "Answer" do
      table_for resource.assess_tt_answers do
        column :id
        column "Answer" do |que|
          que.answer
          que.answer_score
        end 
      end
    end
  end 
end

