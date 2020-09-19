

function aoe(keys)
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()
    local sx = caster:GetAgility()
    local damage  = sx *level
    --local target = keys.target
 

    local target = FindUnitsInRadius(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), nil, 
        300, DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    if target~=nil then
        for key,target in pairs(target) do
                
                
            local damageTable = {
                victim = target,
                attacker = caster,
                damage = damage,
                damage_type=DAMAGE_TYPE_MAGICAL,
                ability = ability, --Optional.
            }
            ApplyDamage(damageTable)
        end    
    end
end
