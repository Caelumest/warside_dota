function HideWearables( event )
 local hero = event.caster
 local ability = event.ability
 local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
 print("Hiding Wearables")
 --hero:AddNoDraw() -- Doesn't work on classname dota_item_wearable

 hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
 hero.hiddenWearables = {} -- Keep every wearable handle in a table, as its way better to iterate than in the MovePeer system
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if string.find(modelName, "invisiblebox") == nil then
             -- Add the original model name to revert later
             table.insert(hero.wearableNames,modelName)
             print("Hidden "..modelName.."")

             -- Set model invisible
             model:SetModel("models/development/invisiblebox.vmdl")
             table.insert(hero.hiddenWearables,model)
            end
        end
        model = model:NextMovePeer()
        if model ~= nil then
         print("Next Peer:" .. model:GetModelName())
        end
    end
end

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
   if v:GetModelName() == "models/heroes/abaddon/weapon.vmdl" then
    v:SetModel("models/items/abaddon/feathers/feathers_weapon.vmdl")
   end

   if v:GetModelName() == "models/heroes/abaddon/mount.vmdl" then
    v:SetModel("models/items/abaddon/mount_drake_evercold/mount_drake_evercold.vmdl")
   end

   if v:GetModelName() == "models/heroes/abaddon/cape.vmdl" then
    v:SetModel("models/items/abaddon/hood_of_the_font_guard/hood_of_the_font_guard.vmdl")
   end

   if v:GetModelName() == "models/heroes/abaddon/shoulders.vmdl" then
    v:SetModel("models/items/abaddon/winged_shroud_of_ruin/winged_shroud_of_ruin.vmdl")
   end

   if v:GetModelName() == "models/heroes/abaddon/mount.vmdl" then
    v:SetModel("models/items/abaddon/feathers/feathers_weapon.vmdl")
   end

  end
 end
end