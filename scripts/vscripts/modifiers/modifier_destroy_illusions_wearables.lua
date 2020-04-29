modifier_destroy_illusions_wearables = class({})

--------------------------------------------------------------------------------

function modifier_destroy_illusions_wearables:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_destroy_illusions_wearables:OnDestroy()
	print("destruiu")
	local killedUnit = self:GetParent()
	if killedUnit.weapon then killedUnit.weapon:Destroy() end
    if killedUnit.head then killedUnit.head:Destroy() end
    if killedUnit.pants then killedUnit.pants:Destroy() end
    if killedUnit.shoulders then killedUnit.shoulders:Destroy() end
    if killedUnit.body then killedUnit.body:Destroy() end
    if killedUnit.legs then killedUnit.legs:Destroy() end
    if killedUnit.arms then killedUnit.arms:Destroy() end
    if killedUnit.arms2 then killedUnit.arms2:Destroy() end
end
