ActiveAdmin.register BxBlockContactUs::Contact, as: "contact_us" do
    menu priority: 10
  
  permit_params :description 

    index :title=> "contact us" do
      selectable_column
      id_column
      column :account
      column :description
      column :created_at
      actions
    end

    show do
      attributes_table title: "contact" do
        row :description
        row :created_at
      end
    end

    form do |f|
    f.inputs do
      f.input :description
    end
    f.actions
  end

end