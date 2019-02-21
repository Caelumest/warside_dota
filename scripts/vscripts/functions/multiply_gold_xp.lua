function MultiplyGoldXp(killedUnit, attacker)
  local killedTeam = killedUnit:GetTeam()
  local heroTeam = attacker:GetTeam()
  local extraTime = 0 
  count = 0
  if attacker ~= nil and killedUnit ~= nil then
    if attacker:IsRealHero() then
      heroID = attacker:GetPlayerID()
    end
    local xpbounty = killedUnit:GetDeathXP()
    
    if multiplier_Exp ~= nil and attacker:IsRealHero() then
      local units = FindUnitsInRadius( killedUnit:GetTeamNumber(), killedUnit:GetOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false )
          if killedUnit:GetTeam() ~= heroTeam then
            for _,hEnemy in pairs( units ) do
              if count < 1 then
                for _,hEnemy in pairs( units ) do
                  count = count + 1
            end
          end
          hEnemy:AddExperience(((xpbounty/count) * multiplier_Exp),0, false, true)
        end
        count = 0
      elseif killedUnit:GetTeam() == heroTeam then
        local allyUnits = FindUnitsInRadius( killedUnit:GetTeamNumber(), killedUnit:GetOrigin(), nil, 1300, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false )
        for _,hEnemy in pairs( allyUnits ) do
              if count < 1 then
                for _,hEnemy in pairs( allyUnits ) do
                  count = count + 1
            end
          end
          hEnemy:AddExperience((((xpbounty / 4) / count) * multiplier_Exp),0, false, true)
        end
        count = 0
      end
    end
    if multiplier_Gold ~= nil and killedUnit:GetTeam() ~= heroTeam  then
      local goldbounty = killedUnit:GetGoldBounty()
      if killedUnit:IsTower() or killedUnit:GetName() == 'npc_dota_roshan' or killedUnit:IsBarracks() or killedUnit:IsShrine() then
        if attacker:IsRealHero() and killedUnit:IsTower() and killedUnit:GetTeam() ~= heroTeam then
          PlayerResource:ModifyGold(heroID, (200*multiplier_Gold), false, 0);
        end
        if heroTeam == 2 and killedUnit:GetTeam() ~= heroTeam then
          for i=0, 4 do
            PlayerResource:ModifyGold(i, (150*multiplier_Gold), false, 0);
          end
        elseif heroTeam == 3 and killedUnit:GetTeam() ~= heroTeam then
          for i=5, 9 do
            PlayerResource:ModifyGold(i, (150*multiplier_Gold), false, 0);
          end
        end
      end
      if attacker:IsRealHero() then
        PlayerResource:ModifyGold(heroID, (goldbounty * multiplier_Gold), false, 0);
      end
    end
  end
end