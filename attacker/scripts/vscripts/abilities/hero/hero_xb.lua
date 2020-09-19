--双倍法伤特效
function DoubleMagicalDamageParticle(unit,damage)
	if not unit or type(damage) ~= "number" then
		return;
	end
	--只显示正数的暴击
	if damage > 0 then
		PopupNum:PopupCriticalDamage(unit,damage)
	end

end



--二技能 天玄焚火伤害
function tianxuanfenghuo_dmg (ability,hero,point,radius,dmg,stun_time,isDoubleDamage)
	local playerid=hero:GetPlayerOwnerID()

	local p1 = ParticleManager:CreateParticle("particles/abilities/xb_tianxuanfenghuo/uicide_base.vpcf",PATTACH_ABSORIGIN,hero)
	ParticleManager:SetParticleControl( p1, 0, point )

	hero:EmitSound("Hero_Invoker.SunStrike.Ignite")

	local entitiestemp=FindUnitsInRadius( ZXJ_TEAM_ENEMY, point, nil,radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	if entitiestemp~=nil then
		for i,unit in pairs(entitiestemp) do
			local damageTable = {
				victim=unit,
				attacker=hero,
				damage=dmg,
				damage_type=DAMAGE_TYPE_MAGICAL
			}
			ApplyDamage(damageTable)
			--添加眩晕效果
			ability:ApplyDataDrivenModifier(hero, unit, "modifier_hero_xiaobai_tianxuanfenghuo_stun", {duration=stun_time})
			--双倍法伤特效
			if isDoubleDamage then
				DoubleMagicalDamageParticle(unit,dmg)
			end
		end
	end
	--天书第四重开始，每次释放天玄焚火有几率额外释放一次。
	if PlayerUtil.GetXinFa(playerid):GetLevel() > 3 then
		TimerUtil.createTimerWithDelay(0.5,
			function()
				if RollPercentage(60) then
					tianxuanfenghuo_dmg (ability,hero,FindRandomPoint(point,200),radius,dmg,0,isDoubleDamage)
				end
			end
		)
	end
end


--小白大招 天玄破神荒（大招）
function TianXuanPoShenHuang( keys )
	local caster = keys.caster
	local ability = keys.ability;
	local point = keys.target_points[1]
	local playerid=caster:GetPlayerOwnerID()
	
	
	local stun_time=keys.ability:GetLevelSpecialValueFor( "stun_time", keys.ability:GetLevel() - 1 ) or 0--眩晕时间
	local basedamage=keys.ability:GetLevelSpecialValueFor( "basedamage", keys.ability:GetLevel() - 1 ) or 0--伤害系数
	local radio = keys.ability:GetLevelSpecialValueFor( "radio", keys.ability:GetLevel() - 1 ) or 0--选取范围
	local xishu = keys.ability:GetLevelSpecialValueFor( "xishu", keys.ability:GetLevel() - 1 ) or 0--伤害系数
	local fire_duration = keys.ability:GetLevelSpecialValueFor( "fire_duration", keys.ability:GetLevel() - 1 ) or 0--灼烧时间
	
	
	--暴击倍数
	local baoji = 1 

	local damage_yunshi=200

	caster:EmitSound("abilitysounds.xiaobai_skill_1");

	--============================================================================特效部分
	local p1 = ParticleManager:CreateParticle( "particles/abilities/xb_yunshi/yunshi_ground.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( p1, 0, point )
	ParticleManager:SetParticleControl( p1, 1, Vector(radio,radio,radio-30) )--三个数字分别对应地面三个圈的半径(最外面的，最里面的，中间的）

	--坠落火焰特效
	local start_time = GameRules:GetGameTime() --开始的时间
	TimerUtil.createTimerWithDelay(0.05, function()
		local now_time = GameRules:GetGameTime()--现在的时间
		if now_time - start_time >= fire_duration then
			return nil
		end
		for i=1,2 do --控制火焰数量，不建议太多
			local p2 = ParticleManager:CreateParticle( "particles/abilities/xb_yunshi/yunshi_attack.vpcf", PATTACH_ABSORIGIN, caster )
			local randompoint = FindRandomPoint(point,radio-50)
			ParticleManager:SetParticleControl( p2, 0, randompoint )
		end
		return 0.05
	end)
	--=============================================================================================
	local time = 0
	local nowtime=0

	TimerUtil.createTimer(function()
		local enemies=  FindEnemiesInRadiusEx(caster,point,radio) 
		if enemies~=nil then
			local damageTable = {
				victim=nil,
				attacker=caster,
				damage=damage_yunshi*0.2,
				damage_type=DAMAGE_TYPE_MAGICAL
			}
			for _,unit in pairs(enemies) do
				damageTable.victim = unit
				ApplyDamage(damageTable)
				--双倍法伤，显示特效
				if baoji == 2 then
					DoubleMagicalDamageParticle(unit,damageTable.damage)
				end
			end
		end
		if nowtime>=fire_duration then
			ParticleManager:DestroyParticle(p1,false)
			return nil
		end
		nowtime=nowtime+1
		return 1
	end)


	TimerUtil.createTimerWithDelay(0.75,
		function()
			local enemystemp=FindUnitsInRadius(caster:GetTeamNumber(),point,nil,radio,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			caster:EmitSound("Hero_Invoker.ChaosMeteor.Impact")

		
			if enemystemp~=nil then
				local damageTable = {
						victim=nil,
						attacker=caster,
						damage=damage_yunshi,
						damage_type=DAMAGE_TYPE_MAGICAL
					}
				for _,unit in pairs(enemystemp) do
					damageTable.victim = unit
					ApplyDamage(damageTable)
					--眩晕效果
					keys.ability:ApplyDataDrivenModifier(caster,unit,"modifier_hero_xiaobai_yaozhenposhenhuang_stun",{duration=stun_time})
					--双倍法伤，显示特效
					if baoji == 2 then
						DoubleMagicalDamageParticle(unit,damage_yunshi)
					end
				end
			end
		end
	)
end
