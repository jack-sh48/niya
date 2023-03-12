ActiveAdmin.register AccountBlock::Account, as: "HR" do
  menu priority: 7
  
  permit_params :full_name, :email, :full_phone_number, :password, :password_confirmation, :access_code   

  filter :full_name, as: :string, label: "Full Name"
  filter :email, as: :string, label: "Email"
  filter :full_phone_number
  filter :access_code, as: :string, label: "Access Code"

  controller do
    def scoped_collection
      @accounts = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:hr]).id)
    end
  end


  index :title=> "Account" do
    selectable_column
    id_column
    column :full_name
    column :email
    column :full_phone_number
    column :access_code
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table title: "Account Details" do
      row :full_name
      row :email 
      row :full_phone_number
      row :access_code
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :full_name
      f.input :email
      f.input :full_phone_number
      f.input :password
      f.input :password_confirmation
      f.input :access_code
    end
    f.actions
  end


end