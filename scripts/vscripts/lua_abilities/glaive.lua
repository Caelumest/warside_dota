GLAIVE_STATE_ATTACK = 0
GLAIVE_STATE_DECAY = 1
GLAIVE_STATE_SUSTAIN = 2
GLAIVE_STATE_RELEASE = 3
 
function SpawnGlaive( keys )
    local caster = keys.caster
    local target = keys.target_points[1]
    local ability = keys.ability
 
    local glaive = CreateUnitByName("npc_dummy_unit",caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_mom_r")),false,caster,caster,caster:GetTeamNumber())
    glaive:RemoveAbility("dummy_unit")
    glaive:RemoveModifierByName("dummy_unit")
    glaive:SetMoveCapability(2)
    -- glaive:SetModel(caster:GetModelName())
 
    AddChildEntity( caster, glaive )
 
    ability:ApplyDataDrivenModifier(caster, glaive, "modifier_glaive_unit",{})
    glaive:AddNewModifier(glaive,nil,"modifier_phased",{})
 
    local particle = ParticleManager:CreateParticle("particles/heroes/dark_goddess/dark_goddess_glaive_alt.vpcf",PATTACH_ABSORIGIN_FOLLOW,glaive)
 
    local projectile_speed = 4540
 
    Physics:Unit(glaive)
 
    glaive:RemoveCollider()
    local collider = glaive:AddColliderFromProfile("gravity")
    collider.radius = 715
    collider.fullRadius = 0
    collider.force = 0
    collider.linear = false
    collider.test = function(self, collider, collided)
        return false
    end
 
    glaive:SetPhysicsVelocityMax(5000)
    glaive:SetPhysicsFriction (0.15)
    glaive:Slide(true)
    glaive:Hibernate(false)
    glaive:PreventDI()
 
    local state = GLAIVE_STATE_ATTACK
   
    local midpoint = Vector((glaive:GetAbsOrigin()[1] + target[1]) / 2, (glaive:GetAbsOrigin()[2] + target[2]) / 2, 0)
 
    local point1 = RotatePosition(midpoint, QAngle(0,50,0), target)
    local point2 = target
    local point3 = RotatePosition(midpoint, QAngle(0,-50,0), target)
 
    local max_point_time = 1.75
    local time = 0.0
 
    local distance = point1 - glaive:GetAbsOrigin()
    local direction = distance:Normalized()
    glaive:SetPhysicsAcceleration(direction * projectile_speed)
 
    glaive:OnPhysicsFrame(function(unit)
        if state == GLAIVE_STATE_ATTACK then
            distance = point1 - glaive:GetAbsOrigin()
            direction = distance:Normalized()
            glaive:SetPhysicsAcceleration(direction * projectile_speed)
           
            if distance:Length2D() < 50 or time > max_point_time then
                time = 0.0
                state = GLAIVE_STATE_DECAY
            end
        elseif state == GLAIVE_STATE_DECAY then
            distance = point2 - glaive:GetAbsOrigin()
            direction = distance:Normalized()
            glaive:SetPhysicsAcceleration(direction * projectile_speed)
 
            if distance:Length2D() < 50 or time > max_point_time then
                time = 0.0
                state = GLAIVE_STATE_SUSTAIN
            end
        elseif state == GLAIVE_STATE_SUSTAIN then
            distance = point3 - glaive:GetAbsOrigin()
            direction = distance:Normalized()
            glaive:SetPhysicsAcceleration(direction * projectile_speed)
 
            if distance:Length2D() < 25 or time > max_point_time then
                time = 0.0
                state = GLAIVE_STATE_RELEASE
            end
        else
            distance = caster:GetAbsOrigin() - glaive:GetAbsOrigin()
            direction = distance:Normalized()
            glaive:SetPhysicsAcceleration(direction * projectile_speed)
 
            if distance:Length2D() < 25 or time > max_point_time then
                caster:EmitSound("Hero_Luna.MoonGlaive.Impact")
 
                glaive:SetPhysicsAcceleration(Vector(0,0,0))
                glaive:SetPhysicsVelocity(Vector(0,0,0))
                glaive:OnPhysicsFrame(nil)
 
                glaive:ForceKill(false)
                ParticleManager:DestroyParticle(particle,false)
            end
        end
        time = time + 0.03
    end)
end