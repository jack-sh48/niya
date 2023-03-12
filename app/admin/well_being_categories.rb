ActiveAdmin.register WellBeingCategory do

  permit_params :category_name

  
  index do
      id_column
      column :category_name
      actions
  end

  controller do
    def destroy
      category_id = params[:id]
      WellBeingCategory.find(category_id).destroy
      WellBeingSubCategory.where(well_being_category_id: category_id).destroy_all
      QuestionWellBeing.where(category_id: category_id).destroy_all
      redirect_to admin_well_being_categories_path
    end
  end

  show do
    attributes_table title: "Question Details" do
      row :category_name
    end
  end

  form do |f|
    f.inputs do
      f.input :category_name
    end
    f.actions
  end
end
