ActiveAdmin.register BxBlockAssessmenttest::AssesmentTestType, as: "Niya Chat Board Test Type" do 
  menu priority: 2
  permit_params :question_title, :assesment_test_answer_id, assesment_test_type_answers_attributes: [:id, :answers, :_destroy]

  form do |f|
    f.semantic_errors :blah
    f.inputs class: 'question' do
      f.input :question_title
      f.input :assesment_test_answer_id
      
    end

    f.inputs class: 'multiple_answer' do
      has_many :assesment_test_type_answers, allow_destroy: true do |ans|
        ans.input :answers
      end
    end
    f.actions
  end
  index do
      selectable_column
      column :id
      column :question_title
      column :assesment_test_type_answer_ids
      actions
  end

  show do
    attributes_table do
      row "Question" do |top|
        top.question_title
      end
    end
    panel "Answer" do
      table_for resource.assesment_test_type_answers do
        column :id
        column "Answer" do |que|
          que.answers
        end
        
      end
    end
  end
end


