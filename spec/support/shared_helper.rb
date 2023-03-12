require "rails_helper"
module Support
  class SharedHelper
    def coach_role
      coachrole = BxBlockRolesPermissions::Role.find_by(id: 2)
      coachrole = BxBlockRolesPermissions::Role.create(id: 2, name: "coach") unless coachrole
      return coachrole
    end

    def hr_role
      hrrole = BxBlockRolesPermissions::Role.find_by(id: 3)
      hrrole = BxBlockRolesPermissions::Role.create(id: 3, name: "hr") unless hrrole
      return hrrole
    end

    def admin_role
      adminrole = BxBlockRolesPermissions::Role.find_by(id: 4)
      adminrole = BxBlockRolesPermissions::Role.create(id: 4, name: "admin") unless adminrole
      return adminrole
    end

    def admin_user
      admin_current_user =  AccountBlock::Account.find_by(id: 88)
      admin_current_user.update(role_id: admin_role.id) if admin_current_user
      admin_current_user = AccountBlock::Account.new(id: 88 ,full_name: "admin",email:"admin@gmail.com",
                                                     full_phone_number: "919099683863", password: "Admin@1234",
                                                     password_confirmation: "Admin@1234", activated: true, role_id: admin_role.id) unless admin_current_user.present?
      admin_current_user&.save(validate: false)
      return admin_current_user
    end

    def get_admin_token
      @token =  BuilderJsonWebToken.encode(admin_user&.id)
      return @token
    end

    def create_company_hr
      comp = Company.find_by(id: 11)
      comp = Company.create(id: 11, name: "tcs", email: "tcs@gmail.com", address: "pune") unless comp.present?
      hr_account = AccountBlock::Account.find_by(id: 112)
      hr_account = AccountBlock::Account.new(id: 112, first_name: nil, last_name: nil, full_phone_number: "917907617765", country_code: 91, phone_number: 7901817765, email: "hr1@gmail.com", activated: true, device_id: nil, unique_auth_id: nil, password_digest: "$2a$12$fkBB390bfobtUaQHS7XiM.WfMMp/rQdt6rluyaAJ.OD...", type: "EmailAccount", created_at: "2022-12-01 10:48:35", updated_at: "2022-12-01 10:51:21", user_name: nil, platform: nil, user_type: nil, app_language_id: nil, last_visit_at: nil, is_blacklisted: false, suspend_until: nil, status: "regular", stripe_id: nil, stripe_subscription_id: nil, stripe_subscription_date: nil, role_id: 5, full_name: "coach2222", gender: nil, date_of_birth: nil, age: nil, is_paid: false, access_code: comp.hr_code, rating: nil, city: nil, expertise: "[\"Stress\"]", education: nil) unless hr_account.present?
      return hr_account
    end

    def get_coach_user
      coach_account = AccountBlock::Account.find_by(id: 300)
      coach_account = AccountBlock::Account.new(id: 300, first_name: nil, last_name: nil, full_phone_number: "917907617765", country_code: 91, phone_number: 7901817765, email: "coach17@gmail.com", activated: true, device_id: nil, unique_auth_id: nil, password_digest: "$2a$12$fkBB390bfobtUaQHS7XiM.WfMMp/rQdt6rluyaAJ.OD...", type: "EmailAccount", created_at: "2022-12-01 10:48:35", updated_at: "2022-12-01 10:51:21", user_name: nil, platform: nil, user_type: nil, app_language_id: nil, last_visit_at: nil, is_blacklisted: false, suspend_until: nil, status: "regular", stripe_id: nil, stripe_subscription_id: nil, stripe_subscription_date: nil, role_id: 5, full_name: "coach2222", gender: nil, date_of_birth: nil, age: nil, is_paid: false, access_code: nil, rating: nil, city: nil, expertise: "[\"Stress\"]", education: nil) unless coach_account.present?
      coach_account&.save(validate: false)
      return coach_account
    end


    def current_user
      company  = Company.find_by(id: 5)
      role = BxBlockRolesPermissions::Role.find_by(id: 1)
      role = BxBlockRolesPermissions::Role.create(id: 1, name: "employee") unless role.present?
      company = Company.create(id: 5, name: "newtata company12", email: "newexample12@gmail.com", address: "newDelhi12",hr_code: "A#{rand(100)}",employee_code:"b#{rand(100)}") unless company.present?
      current_user =  AccountBlock::Account.find_by(id: 1)
      current_user = AccountBlock::Account.create!(id: 1 ,full_name: "assess user",email:"assess@gmail.com",full_phone_number: "919098083863", password: "Admin@123",password_confirmation: "Admin@123", activated: true,access_code: company&.employee_code) unless current_user.present?
      return current_user
    end

    def get_token
      role = BxBlockRolesPermissions::Role.find_by(id: 1)
      role = BxBlockRolesPermissions::Role.create!(id: 1, name: "employee") unless role.present?
      company  = Company.find_by(id: 5)
      company = Company.create!(id: 5, name: "newtata company12", email: "newexample12@gmail.com", address: "newDelhi12",hr_code: "A#{rand(100)}",employee_code: "b#{rand(100)}") unless company.present?
      current_user =  AccountBlock::Account.find_by(id: 2)
      current_user = AccountBlock::Account.create!(id: 2 ,full_name: "assess user",email:"assess@gmail.com",full_phone_number: "919098083863", password: "Admin@12",password_confirmation: "Admin@12", activated: true,access_code: company&.employee_code) unless current_user.present?
      @token =  BuilderJsonWebToken.encode(current_user&.id)
     return @token
    end

    def create_data
      que = BxBlockAssessmenttest::AssessYourselfQuestion.find_by(id:1)
      ans = BxBlockAssessmenttest::AssessYourselfAnswer.find_by(id: 1)
      test_type = BxBlockAssessmenttest::AssessYourselfTestType.find_by(id: 1)
      # select_answer = BxBlockAssessmenttest::AssessSelectAnswer.find_by(id: 1)
      anxeity = BxBlockAssessmenttest::AnixetyCutoff.find_by(id: 1)
      assess_tt = BxBlockAssessmenttest::AssessTtAnswer.find_by(id: 1)
      que = BxBlockAssessmenttest::AssessYourselfQuestion.create!(id: 1, question_title: "Which test do you want to take?") unless que.present?
      ans = BxBlockAssessmenttest::AssessYourselfAnswer.create!(id: 1, assess_yourself_question_id: 1, answer_title: "nice") unless ans.present?
      test_type = BxBlockAssessmenttest::AssessYourselfTestType.create!(id: 1, question_title: "how are you", sequence_number: 1, assess_yourself_answer_id: 1) unless test_type.present?
      # select_answer = BxBlockAssessmenttest::AssessSelectAnswer.create!(id: 1, assess_yourself_test_type_id: 1, assess_tt_answer_id: 3, account_id: 2, assess_yourself_answer_id: 1, select_answer_status: true) unless select_answer.present?
      anxeity = BxBlockAssessmenttest::AnixetyCutoff.create!(id: 1, min_score: 1, max_score: 5, anixety_title: "low depress", category_id: 1,total_score: 3, result: true) unless anxeity.present?
      assess_tt = BxBlockAssessmenttest::AssessTtAnswer.create!(id: 1, answer: 1, answer_score: 3, assess_yourself_test_type_id: 1) unless assess_tt.present?
    end
    def get_company
      company = Company.find(5)
      company = Company.create(name: "newtata company12", email: "newexample12@gmail.com", address: "newDelhi12", hr_code: "A0", employee_code: "b54", created_at: "2023-01-06 06:32:22", updated_at: "2023-01-06 06:32:22") unless company.present?
      return company
    end
    def action_item
      action_item = BxBlockAssessmenttest::ActionItem.find_or_create_by(id: 1, action_item: "my goal",date: "22/10/2022", completed: false,  account_id: 1, time_slot: "10:11 PM")
    end

    def create_wellbeing
      category = WellBeingCategory.where(id: 2).last ? WellBeingCategory.where(id: 2).last : WellBeingCategory.create(id: 2, category_name: "Physical")
      sub_category = WellBeingSubCategory.where(id: 2).last ? WellBeingSubCategory.where(id: 2).last : WellBeingSubCategory.create(id: 2, sub_category_name: "Nutrition", category_id: 2)
      question_wb = QuestionWellBeing.where(id: 2).last ? QuestionWellBeing.where(id: 2).last : QuestionWellBeing.create(id: 2, question: "how are you?", category_id: category.id, subcategory_id: sub_category.id)
      answer_wb = AnswerWellBeing.where(id: 2).last ? AnswerWellBeing.where(id: 2).last : AnswerWellBeing.create(id: 2, answer: "fine", score: "10", question_well_being_id: question_wb.id)
      user_answer_wb = UserQuestionAnswer.where(id: 2).last ? UserQuestionAnswer.where(id: 2).last : UserQuestionAnswer.create(id: 2, question_id: question_wb.id, answer_id: answer_wb.id, account_id: current_user.id)
      user_result_wb = UserAnswerResult.where(id: 2).last ? UserAnswerResult.where(id: 2).last : UserAnswerResult.create(id: 2, category_id: category.id, subcategory_id: sub_category.id, advice: "Nothing", min_score: 5, max_score: 100)
    end
  end
end