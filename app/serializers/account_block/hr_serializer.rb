module AccountBlock
  class HrSerializer
    include FastJsonapi::ObjectSerializer
    attributes *[
      :full_name,
      :email,
      :full_phone_number,
      :access_code,
      :activated
    ]

    attributes :total_users do |object|
      if object.role_id == BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:hr])&.id
        obj = Company.where("employee_code = ? or hr_code = ?",object.access_code, object.access_code).last&.employee_code
        users = AccountBlock::Account.where(access_code: obj).count
      end
    end

    attributes :total_hours do |object|
      company = Company.where(hr_code: object&.access_code)&.last
      account_ids = BxBlockTimeTrackingBilling::TimeTrack.where(company_id: company&.id)
      total_time = BxBlockTimeTrackingBilling::SummaryTrack.where(account_id: account_ids).pluck(:spend_time)
      seconds_diff = (total_time.reduce(0, :+) * 60).round
      hours = seconds_diff / 3600
      seconds_diff -= hours * 3600
      minutes = seconds_diff / 60
      seconds_diff -= minutes * 60
      seconds = seconds_diff
      "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    end

    attributes :feedback do |object|
      company = Company.where(hr_code: object.access_code).last
      accounts=AccountBlock::Account.where(access_code: company.employee_code)
      company_employees_rating = BxBlockRating::AppRating.where(account_id: accounts.pluck(:id)).pluck(:app_rating)
      average_rating = company_employees_rating.reduce(0,:+)/company_employees_rating.count if company_employees_rating.present?
    end

    attributes :focus_areas do |object|
      emp_code = Company.where(hr_code: object.access_code).last&.employee_code
      count=AccountBlock::Account.where(access_code: emp_code).count
      accounts= AccountBlock::Account.where(access_code: emp_code)
      focus_areas = []
      accounts.each do |account|
        focus_area = BxBlockAssessmenttest::SelectAnswer.where(account_id: account&.id)
        focus_area.each do |f_area|
          if f_area.present?
            focus_areas<<f_area
          end
        end
      end
      answers=[]
      focus_areas.each do |focusarea|
        if focusarea.multiple_answers.present?
          answer = BxBlockAssessmenttest::AssesmentTestTypeAnswer.where(id: focusarea&.multiple_answers)&.pluck(:answers)
          answers=answers+answer
        end
      end
      fa=[]
      freq=answers.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
      5.times do
        focus=answers.max_by { |v| freq[v] }
        if focus.present?
          per=(freq[focus]/count.to_f)*100
          fa<<{focus_area: focus, per: per}
        end
        freq.delete(focus)
      end
      fa=fa.select{ |x| x[:per]!=0 }
      fa
    end

    attributes :company_details do |object|
      if object.role_id == BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:hr])&.id
        cmp = Company.where("employee_code = ? or hr_code = ?", object.access_code, object.access_code).last
        company_details_for(cmp)
      end
    end

    attributes :employee_details do |object|
      if object.role_id == BxBlockRolesPermissions::Role.find_by_name(BxBlockRolesPermissions::Role.names[:hr])&.id
        obj = Company.where("employee_code = ? or hr_code = ?",object.access_code, object.access_code).last&.employee_code
        users = AccountBlock::Account.where(access_code: obj)
        employee_details_for(users)
      end
    end

    class << self
      private

      def company_details_for(object)
        {
          id: object.id,
          name: object&.name,
          email: object&.email,
          address: object&.address,
          employee_code: object.employee_code,
          hr_code: object.hr_code
        }
      end

      def employee_details_for(object)
        h1=[]
        object.each do |obj|
          h1<<({ id: obj.id,
            email: obj.email,
            full_name: obj&.full_name,
            first_name: obj&.first_name,
            last_name: obj&.last_name,
            gender: obj&.gender})
        end
        return h1
      end
    end
  end
end
