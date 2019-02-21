function Test(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not ability.count then
		ability.count = 1
	end
	print('working')
	--StartAnimation(caster, {duration=3, activity=ACT_DOTA_IDLE, rate=0.8, translate="odachi"})
	StartAnimation(caster, {duration=1, activity=ACT_DOTA_FLAIL, rate=1, translate="forcestaff_friendly"})
	Timers:CreateTimer(0.2, function () FreezeAnimation(caster, 4) end)
	--AddAnimationTranslate(caster, ability.count)
	--StartAnimation(caster, {duration=2.5, activity=ACT_DOTA_FORCESTAFF_END, rate=0.5})
	ability.count = ability.count + 1
end