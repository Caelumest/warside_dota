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
	local modifiers = target:FindAllModifiers()
	--print("-----------------"..target:GetUnitName().."---------------")
	for k,v in pairs(modifiers) do
		if v:GetName() ~= self:GetName() then
			print("THINK",v:GetName())
		end
	end
	--print("-----------------------------------------------------------")
end
