module BxBlockAddress
	class GoalSerializer < BuilderBase::BaseSerializer

		attributes *[
			:goal,
			:date,
			:time_slot,
			:complete
		]
	end
end






