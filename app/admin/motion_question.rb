ActiveAdmin.register BxBlockAssessmenttest::MotionQuestion, as: "Emotion_Question" do 
    menu priority: 11
  permit_params :emo_question, :motion_id, motion_answers_attributes: [:id,:emo_answer, :destroy]


  filter :emo_question, as: :string, label: "Emotion Question"
  filter :motion_id, as: :string, label: "Emotion"
  filter :motion_answers, label: "Emotion Answer"
  filter :created_at, label: "created at"
  filter :updated_at, label: "updated at"

  # rename new button
  config.clear_action_items!
  action_item :new, only: [:index] do
    link_to "Emotion_Question" , "/admin/emotion_questions/new" 
  end


  form do |f|
    f.semantic_errors :blah
    f.inputs class: 'emo question' do
      f.input :emo_question,label: 'Emotion Question'
      f.input :motion_id,  :as => :select, :collection =>  BxBlockAssessmenttest::Motion.all.collect {|mot| [mot.motion_title, mot.id] }, label: 'Emotion'
    end
    f.inputs class: 'Emotion Answer' do
      has_many :motion_answers, allow_destroy: true do |ans|
        ans.input :emo_answer, label: 'Emotion Answer'
      end
    end
    f.actions

  end

   index do
      selectable_column
      column :id
      column "Emotion Question", :emo_question 
      column "Emotion", :motion_id
      column "Emotion Answer Ids",:motion_answer_ids
      column :created_at
      column :updated_at
      actions
  end

  show do
    attributes_table do
      row "Emotion Question" do |top|
        top.emo_question
      end
    end
    panel "Emotion Answer" do
      table_for resource.motion_answers do
        column :id
        column "Answer" do |que|
          que.emo_answer
        end 
      end
    end
  end 
end

