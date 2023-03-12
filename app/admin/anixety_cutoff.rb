ActiveAdmin.register BxBlockAssessmenttest::AnixetyCutoff, as: "Assess Title" do 
  permit_params :min_score, :max_score, :anixety_title, :category_id


  index :title=> "Assess Title" do
    selectable_column
    id_column
    column :min_score
    column :max_score
    column "Advice", :anixety_title
    column :category_id
    actions
  end


  form do |f|
    f.inputs do
      f.input :min_score
      f.input :max_score
      f.input :anixety_title, label: 'assess_title'
      f.input :category_id , as: :select,  collection: BxBlockAssessmenttest::AssessYourselfAnswer.pluck(:id)
    end
    f.actions
  end 
end

