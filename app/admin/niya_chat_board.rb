ActiveAdmin.register BxBlockAssessmenttest::AssesmentTestQuestion, as: "Niya Chat Board" do 
  menu priority: 1
  permit_params :title , :sequence_number, assesment_test_answers_attributes: [:id, :answers, :_destroy]

  form do |f|
    f.semantic_errors :blah
    f.inputs class: 'question' do
      f.input :title
      f.input :sequence_number
    end
    f.inputs class: 'multiple_answer' do
      has_many :assesment_test_answers, allow_destroy: true do |ans|
        ans.input :answers
      end
    end
    f.actions
  end
  index do
      selectable_column
      column :id
      column :title
      column :sequence_number
      actions
  end

  show do
    attributes_table do
      row "Question" do |top|
        top.title
      end
    end
    panel "Answer" do
      table_for resource.assesment_test_answers do
        column :id
        column "Answer" do |que|
          que.answers
        end
        
      end
    end
  end
  
end

