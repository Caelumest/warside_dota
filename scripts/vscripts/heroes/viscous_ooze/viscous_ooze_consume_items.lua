LinkLuaModifier("modifier_consume_item_strength","heroes/viscous_ooze/viscous_ooze_consume_items.lua",LUA_MODIFIER_MOTION_NONE)


viscous_ooze_consume_items = class({})

function viscous_ooze_consume_items:OnUpgrade()
	if IsServer() then 
		self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_consume_item_strength",{})

		local subability = self:GetCaster():FindAbilityByName("viscous_ooze_treasure_magic")
		if subability and subability:GetLevel() == 0 then
			subability:UpgradeAbility(false)
		end
	end
end

function viscous_ooze_consume_items:OnSpellStart()
	if IsServer() and not bInterrupted then 
		local caster = self:GetCaster()
		local modifier = caster:FindModifierByName("modifier_consume_item_strength")

		local strengthPerGold = self:GetSpecialValueFor("strength_per_gold")
		local cooldownPerGold = self:GetSpecialValueFor("cooldown_per_gold")

		if not modifier then 
			modifier = caster:AddNewModifier(caster,self,"modifier_consume_item_strength",{}) 
			modifier.consumedGold = 0
		end

		if not modifier.consumedGold then modifier.consumedGold = 0 end

		--Consume items in backpack, add total networth
		local cooldown = 0
		for i = 6, 8 do
			local item = caster:GetItemInSlot(i)
			if item and item:IsPermanent() then
				local networth = item:GetCost()

				modifier.consumedGold = modifier.consumedGold + networth
				caster:RemoveItem(item)
				cooldown = cooldown + (networth * cooldownPerGold / 100)
				caster:EmitSound("Hero_Viscous_Ooze.Consume_items")
			end
		end

		caster:SetModifierStackCount("modifier_consume_item_strength", caster, (modifier.consumedGold * strengthPerGold) / 100)
		caster:CalculateStatBonus()

		self:StartCooldown(cooldown)
	end
end


modifier_consume_item_strength = class({})

function modifier_consume_item_strength:IsPermanent()
	return true
end

function modifier_consume_item_strength:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
    return funcs
end

function modifier_consume_item_strength:IsDebuff()
	return false
end

function modifier_consume_item_strength:GetModifierBonusStats_Strength()
    return self:GetStackCount()
end

function modifier_consume_item_strength:ModifyStacks()
	self:SetStackCount(self.consumedGold / 100)
	return false
end
