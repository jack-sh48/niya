module BxBlockAddress
	class GoalBoardSerializer < BuilderBase::BaseSerializer

        attributes :current_goals do |object|
            current_goals=[]
            @goals = object&.goals&.all.order(created_at: 'desc').where(complete: false)
            @goals.each do |goal|
                current_goals<<{id: goal.id, goal: goal.goal, date: goal.date, time_slot: goal.time_slot, complete: goal.complete}
            end
            current_goals
        end

        attributes :completed_goals do |object|
            complete_goals=[]
            @goals = object&.goals.all.order(created_at: 'desc').where(complete: true)
			@goals.each do |goal|
                complete_goals<<{id: goal.id, goal: goal.goal, date: goal.date, time_slot: goal.time_slot, complete: goal.complete}
            end
            complete_goals
        end
	end
end