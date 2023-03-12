ActiveAdmin.register Company do
  menu priority: 6
  permit_params :name, :email, :address, :hr_code, :employee_code, :image

  controller do
    def scoped_collection
      @companies = Company.all
    end
  end



  index :title=> "Company" do
    selectable_column
    id_column
    column :name
    column :email
    column :address
    column :employee_code
    column :hr_code
    actions
  end

  show do |object|
    attributes_table title: "Company Details" do
      row :name
      row :email 
      row :address
      row :employee_code
      row :hr_code
      row 'HR List' do
        AccountBlock::Account.where(access_code: object.hr_code)
      end
    end
  end

  form do |f|
    if f.object.new_record?
      f.object.hr_code = SecureRandom.alphanumeric(6)
      f.object.employee_code = SecureRandom.alphanumeric(7)
      f.inputs do
        f.input :name
        f.input :email
        f.input :address
        f.input :employee_code, as: :hidden, label: "Employee Access Code"
        f.input :hr_code,as: :hidden, label: "HR Access Code"
      end
    else
      f.inputs do
        f.input :name
        f.input :email
        f.input :address
        f.input :image, as: :file
        f.input :employee_code, label: "Employee Access Code"
        f.input :hr_code, label: "HR Access Code"
      end
    end
    f.actions
  end
end
