module BxBlockAddress
	class MyProgressSerializer
		include FastJsonapi::ObjectSerializer
	    
		attributes :focus_areas do |object|
	      count=AccountBlock::Account.where(id: object.id).count
	      accounts= AccountBlock::Account.where(id: object.id)
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
	      t = 4
	      5.times do
	        focus=answers.max_by { |v| freq[v] }
	        color = ["orange", "green", "blue", "red", "yellow"]
	        if focus.present?
				date = focus_areas.first.updated_at.mday
				per_in_thirtydays = (date/3)*10
	          per=(freq[focus]/count.to_f)*10
	          fa<<{focus_area: focus, percentage: per, color: color[t],percentage_in_30_days: per_in_thirtydays}
	        end
	        freq.delete(focus)
	        t -=1
	      end
	      fa=fa.select{ |x| x[:per]!=0 }
	      fa
	    end   
	end
end
