ActiveAdmin.register BxBlockAssessmenttest::AssessYourselfQuestion, as: "AssessYourself Test Question" do 
  menu priority: 4
  permit_params :question_title, assess_yourself_answers_attributes: [:id, :answer_title, :_destroy]

  form do |f|
    f.semantic_errors :blah
    f.inputs class: 'question' do
      f.input :question_title
    end
    f.inputs class: 'multiple_answer' do
      has_many :assess_yourself_answers, allow_destroy: true do |ans|
        ans.input :answer_title
      end
    end
    f.actions
  end
  index do
      selectable_column
      column :id
      column :question_title
      column :assess_yourself_answer_ids
      actions
  end

  show do
    attributes_table do
      row "Question" do |top|
        top.question_title
      end
    end
    panel "Answer" do
      table_for resource.assess_yourself_answers do
        column :id
        column "Answer" do |que|
          que.answer_title
        end 
      end
    end
  end 
end

