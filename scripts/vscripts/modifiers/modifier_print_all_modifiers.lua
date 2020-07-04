modifier_print_all_modifiers = class({})

--------------------------------------------------------------------------------

function modifier_print_all_modifiers:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_print_all_modifiers:OnCreated()
	self:StartIntervalThink(1)
end

function modifier_print_all_modifiers:OnIntervalThink()
	local target = self:GetParent()
	print(dump(target:FindAllModifiers()))
end
