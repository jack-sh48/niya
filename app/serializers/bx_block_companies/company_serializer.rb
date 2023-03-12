module BxBlockCompanies
  class CompanySerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer

    attributes :id, :name, :email, :address, :hr_code, :employee_code

    attribute :company_date do |object|
      object.created_at.to_date
    end

    attributes :company_image do |object, params|
        params[:url]+Rails.application.routes.url_helpers.rails_blob_path(object.image, only_path: true) if object.image.attached? &&  params[:url].present?
    end
  end
end
