ActiveAdmin.register UserAnswerResult do

  permit_params :category_id, :subcategory_id, :advice, :min_score, :max_score, :score_level




  form do |f|
    f.inputs do
      f.input :category_id, as: :select, collection: WellBeingCategory.all.collect{|x| [x.category_name, x.id]}    
      f.input :subcategory_id, as: :select, collection: WellBeingSubCategory.all.collect{|x| [x.sub_category_name, x.id]}
      f.input :advice
      f.input :min_score
      f.input :max_score
      f.input :score_level
    end
    f.actions
  end
  
end
