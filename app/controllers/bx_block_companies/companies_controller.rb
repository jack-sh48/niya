class BxBlockCompanies::CompaniesController < ApplicationController
	include BuilderJsonWebToken::JsonWebTokenValidation

	before_action :validate_json_web_token
	def index
		if current_user.role_id == BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:admin]).id
			if params[:name].present?
				companies = Company.where("lower(name) LIKE ?", "%"+params[:name].downcase+"%")
				render json: BxBlockCompanies::CompanySerializer.new(companies, params: {url: request.base_url})
			else
				companies = Company.all
				render json: BxBlockCompanies::CompanySerializer.new(companies, params: {url: request.base_url})
			end
		else
			render json: {errors: ["Your are not admin"]}
		end
	end

	def create
		if current_user
			company=Company.new(company_params)
			company.hr_code = SecureRandom.alphanumeric(6)
			company.employee_code = SecureRandom.alphanumeric(7)
			if company.save
				render json: BxBlockCompanies::CompanySerializer.new(company, params: {url: request.base_url})
			else
				render json: {errors: ["Invalid Parameters"]}
			end
		else
			render json: {errors: ["User is not admin"]}
		end
	end

	def get_company
		if current_user
			company = Company.where(id: params[:id]).last
			if company.present?
				render json: BxBlockCompanies::CompanyDetailSerializer.new(company, params: {url: request.base_url})
			end
		end
	end

	def coach_expertise
		expertise=[]
		CoachSpecialization.all.each do |specialization|
			expertise<<{specialization: specialization.expertise, id: specialization.id}
		end
		render json: {data: expertise}
	end

	def update_company
		if current_user
			company=Company.find(params[:id])
			company.update(company_params)
			if company.save
				render json: BxBlockCompanies::CompanySerializer.new(company)
			else
				render json: {errors: ["Invalid Parameters"]}
			end
		else
			render json: {errors: ["User is not admin"]}
		end
	end

	def get_all_details
		if current_user
			coaches = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:coach]).id).count
			employees = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:employee]).id).count
			companies = Company.all.count
			render json: {data: {coaches: coaches, employees: employees, companies: companies}}
		else
			render json: {errors: ["You are not logged in"]}, status: :unprocessable_entity
		end
	end

	def get_coaches
		if current_user
			if params[:name].present?
				coaches = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:coach]).id).get_users(params[:name])
				render json: BxBlockCompanies::CoachDetailSerializer.new(coaches, params: {url: request.base_url})
			else
				coaches = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:coach]).id)
				render json: BxBlockCompanies::CoachDetailSerializer.new(coaches, params: {url: request.base_url})
			end
			
		end
	end

	def get_employees
		if current_user
			if params[:name].present?
				employees = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:employee]).id).get_users(params[:name]).order('created_at desc')
				render json: BxBlockCompanies::EmployeeDetailSerializer.new(employees, params: {url: request.base_url})
			else
				employees = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:employee]).id).order('created_at desc')
				render json: BxBlockCompanies::EmployeeDetailSerializer.new(employees, params: {url: request.base_url})
			end

		end
	end

	def get_hrs
		if current_user
			byebug
			code = Company.where(id: params[:company_id])&.last&.hr_code
			if code.present?
				if params[:name].present?
					hr = AccountBlock::Account.where(access_code: code).get_users(params[:name])
					render json: BxBlockCompanies::HrDetailSerializer.new(hr, params: {url: request.base_url})
				else
					byebug
					hr = AccountBlock::Account.where(access_code: code)
					render json: BxBlockCompanies::HrDetailSerializer.new(hr, params: {url: request.base_url})
				end
			end
		end
	end

	def delete_user
		if current_user
			AccountBlock::Account.find(params[:id]).destroy
			render json: {message: ["User deleted succesfully"]}
		end
	end

	private
	def company_params
		params.require(:company).permit(:name, :email, :address)
	end

	def current_user
		return unless @token
    	@current_user ||= AccountBlock::Account.find(@token.id)
	end
end
