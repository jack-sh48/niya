ActiveAdmin.register WellBeingSubCategory do

  permit_params :sub_category_name, :well_being_category_id

  
  index do
      id_column
      column :sub_category_name
      actions
  end

  show do
    attributes_table title: "Question Details" do
      row :sub_category_name
    end
  end

  form do |f|
    f.inputs do
      f.input :sub_category_name
      f.input :well_being_category_id, as: :select, collection: WellBeingCategory.all.collect{|x| [x.category_name, x.id]} 
    end
    f.actions
  end
end
