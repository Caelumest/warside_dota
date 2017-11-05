LinkLuaModifier("modifier_treasure_magic_active","heroes/viscous_ooze/viscous_ooze_treasure_magic.lua",LUA_MODIFIER_MOTION_NONE)


viscous_ooze_treasure_magic = class({})

function viscous_ooze_treasure_magic:ProcsMagicStick()
    return false
end

function viscous_ooze_treasure_magic:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if not caster:IsAlive() then return end

	local ability = self
	local modifier = caster:FindModifierByName("modifier_consume_item_strength")

	if modifier.consumedGold then
		local value = 100
		if modifier.consumedGold > value then
			modifier.consumedGold = modifier.consumedGold - value
			caster:ModifyGold(value, false, DOTA_ModifyGold_Unspecified)
			--SendOverheadEventMessage( caster, OVERHEAD_ALERT_GOLD , caster, value, caster:GetPlayerOwnerID() )
			self:GoldCoins(value)
			modifier:ModifyStacks()
			self:GetCaster():CalculateStatBonus()
		else 
			value = modifier.consumedGold
			modifier.consumedGold = 0
			caster:ModifyGold(value, false, DOTA_ModifyGold_Unspecified)
			--SendOverheadEventMessage( caster, OVERHEAD_ALERT_GOLD , caster, value, caster:GetPlayerOwnerID() )
		end
	end

	
end

function viscous_ooze_treasure_magic:GoldCoins(value)
	local caster = self:GetCaster()
	local player = PlayerResource:GetPlayer( caster:GetPlayerID() )
	local playerID = caster:GetPlayerOwnerID()

	--EmitSoundOnClient("General.Coins", PlayerResource:GetPlayer(playerID))	
	caster:EmitSound("Hero_Viscous_Ooze.Treasure_magic")

	local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"		
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 1, caster:GetAbsOrigin() )

	local symbol = 0 -- "+" presymbol
	local color = Vector(255, 200, 33) -- Gold
	local lifetime = 2.5
	local digits = string.len(value) + 1
	local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
	local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, caster, player )
	ParticleManager:SetParticleControl( particle, 1, Vector( symbol, value, symbol) )
    ParticleManager:SetParticleControl( particle, 2, Vector( lifetime, digits, 0) )
    ParticleManager:SetParticleControl( particle, 3, color )
end