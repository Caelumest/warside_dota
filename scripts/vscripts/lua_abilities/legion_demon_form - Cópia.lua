--[[Author: Noya
 Date: 10.01.2015.
 Shows the hidden hero wearables
]]
function ShowWearables( event )
 local hero = event.caster
 print("Showing Wearables on ".. hero:GetModelName())

 -- Iterate on both tables to set each item back to their original modelName
 for i,v in ipairs(hero.hiddenWearables) do
  for index,modelName in ipairs(hero.wearableNames) do
   if i==index then
    print("Changed "..v:GetModelName().. " back to "..modelName)
    v:SetModel(modelName)
   end

   -- Here we can also change to any different cosmetic we want, in the proper slot
   if v:GetModelName() == "models/heroes/legion_commander/legion_commander_weapon.vmdl" then
    v:SetModel("models/items/legion_commander/demon_sword.vmdl")
   end
  end
 end
end
