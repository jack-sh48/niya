ActiveAdmin.register BxBlockUpload::MultipleUploadFile, as: "Bulk Upload File" do
  menu priority: 9
  permit_params  :choose_file,:txt_info, file_types_attributes: [:id, :file_name, :assesment_test_type_answer_id, :file_discription, :file_content, :multiple_file, :_destroy, :text_file, :text_file_to_str, focus_areas: []]

  actions :all, except: []

  before_create do |obj|
    obj.file_types.each do |ft|
      ft.focus_areas.delete("") if ft.focus_areas.first==""
    end
  end

  after_create do |obj|
    accounts = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(:employee).id).joins(:select_answers)
    accounts.each do |account|
      obj.file_types.each do |ft|
        focus_area = ft.focus_areas.map{|x| x.to_i}
        test_type_answer=BxBlockAssessmenttest::SelectAnswer.where(account_id: account.id)&.last
				user_focus_areas=BxBlockAssessmenttest::AssesmentTestTypeAnswer.where(id: test_type_answer&.multiple_answers).pluck(:id)
        unless (user_focus_areas & focus_area).empty?

          device_token = UserDeviceToken.find_by(account_id: account.id)&.device_token
          fcm_client = FCM.new(ENV['FCM_SERVER_KEY'])
          options = {
            priority: "high",
            collapse_key: "updated_score",
            data: {
              type: "Suggestion"
            },
            notification: {
              title: "Suggested for you",
              body: "New content is uploaded related to your focus areas."
            }
          }
          fcm_client.send(device_token, options)
        end
      end
    end
  end

  form do |f|
    f.semantic_errors :blah
    f.inputs class: 'file' do
      f.input :choose_file, default: f.object.choose_file, input_html: {class: 'choose_file', onchange: "(function(){
        let chooseFileInput = document.querySelector('.choose_file').value
        let fileFields=document.querySelectorAll('.file_type_select')
        if(chooseFileInput=='docs') {
          fileFields.forEach((ele)=>{
          ele.setAttribute('accept', '.docs, .pdf, .txt', 'docx', '.csv')
          })
        }
        if(chooseFileInput=='audios') {
          fileFields.forEach((ele)=>{
            ele.setAttribute('accept', '.mp3')
            })
        }
        if(chooseFileInput=='videos') {
          fileFields.forEach((ele)=>{
            ele.setAttribute('accept', '.mp4')
            })
        }
      })()", onclick: "(function(){
        let chooseFileInput = document.querySelector('.choose_file').value
        let fileFields=document.querySelectorAll('.file_type_select')
        if(chooseFileInput=='docs') {
          fileFields.forEach((ele)=>{
          ele.setAttribute('accept', '.docs, .pdf, .txt', 'docx', '.csv')
          })
        }
        if(chooseFileInput=='audios') {
          fileFields.forEach((ele)=>{
            ele.setAttribute('accept', '.mp3')
            })
        }
        if(chooseFileInput=='videos') {
          fileFields.forEach((ele)=>{
            ele.setAttribute('accept', '.mp4')
            })
        }
      })()"}
    end

    f.inputs class: 'file types file_type_select' do 
      has_many :file_types, multiple: true, allow_destroy: true do |t|
        t.input :multiple_file, as: :file, input_html: {class: 'file_type_select', accept: '.none'}
        t.input :file_content
        t.input :file_name
        t.input :file_discription
        t.input :assesment_test_type_answer_id, :input_html => { :value => BxBlockAssessmenttest::AssesmentTestTypeAnswer.first.id}, as: :hidden
        t.input :focus_areas, as: :check_boxes, label: 'Focus Area Point', collection: BxBlockAssessmenttest::AssesmentTestTypeAnswer.all.map{|x| [x.answers, x.id, {checked: t.object.focus_areas.include?(x.id.to_s)}]}
        # t.input :text_file, as: :file, input_html: {accept: '.txt'}
       end
    end
    f.actions
  end

  index do
      selectable_column
      column :id
      column :choose_file
      actions
  end

  show do
    attributes_table do
      row :id
    end

    panel "Multipe Files" do
      table_for resource.file_types do
        column :id
        column :file_link do |object|
          link_to(object.multiple_file.filename, rails_blob_path(object.multiple_file, disposition: 'attachment')) if object.multiple_file.attached?
        end

        column :file_name do |object|
          object&.file_name
        end

        column :file_discription do |object|
          object&.file_name
        end

        column :key_focus do |object|
          object&.focus_areas
        end
      end
    end
  end 
end
