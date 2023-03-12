module BxBlockAddress
	class ActionItemSerializer < BuilderBase::BaseSerializer

		attributes *[
			:action_item,
			:date,
			:time_slot,
			:complete
		]
	end
end






