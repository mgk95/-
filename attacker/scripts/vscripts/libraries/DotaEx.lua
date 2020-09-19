--DoUniqueString("xx")--xx不能少 
--IsServer()
--IsClient()
--IsInToolsMode()

---玩家队伍
ZXJ_TEAM_PLAYER = DOTA_TEAM_GOODGUYS
---敌人队伍
ZXJ_TEAM_ENEMY = DOTA_TEAM_BADGUYS

---在给定的位置和范围内搜寻某队伍的敌军单位
--@param #any team 队伍id或者单位实体。
--@param #table point 坐标点Vector值  (GetAbsOrigin)
--@param #number radius 范围
--@param #boolean ignoreInvisiable 是否忽略隐身单位，为true则不会获得到隐身单位
function FindEnemiesInRadiusEx(team,point,radius,ignoreInvisiable)
	if type(team) ~= "number" and type(team.GetTeamNumber) == "function" then
		team = team:GetTeamNumber()
	end
	local flag = DOTA_UNIT_TARGET_FLAG_NONE;
	if ignoreInvisiable then
		flag = DOTA_UNIT_TARGET_FLAG_NO_INVIS
	end
	return FindUnitsInRadius( team, point, nil,radius, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
				flag, FIND_ANY_ORDER, false)
end

---在给定的位置和范围内搜寻某队伍的友军单位
--@param #any team 队伍id或者单位实体。
--@param #table point 坐标点Vector值 (GetAbsOrigin)
--@param #number radius 范围
function FindAlliesInRadiusEx(team,point,radius)
	if type(team) ~= "number" and type(team.GetTeamNumber) == "function" then
		team = team:GetTeamNumber()
	end
	return FindUnitsInRadius( team, point, nil,radius, 
				DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL,
				DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
end

---对某个单位造成伤害
--@param #table victim 受害者
--@param #table attacker 攻击者
--@param #number damage 伤害量
--@param #number damageType 伤害类型
--<ul>
--	<li>DAMAGE_TYPE_PHYSICAL = 1</li>
--	<li>DAMAGE_TYPE_MAGICAL = 2</li>
--	<li>DAMAGE_TYPE_PURE = 4</li>
--</ul>
--@param #number damageFlags 伤害标记(查看对应常量)，可选
--<ul>
--	<li>DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR = 1</li>
--	<li>DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR = 2</li>
--	<li>DOTA_DAMAGE_FLAG_REFLECTION = 16 反弹伤害</li>
--	<li>DOTA_DAMAGE_FLAG_HPLOSS = 32</li>
--</ul>
--@param #table ability 造成伤害的技能，可选
--@return 返回造成的实际伤害
function ApplyDamageEx(victim, attacker, damage, damageType, damageFlags, ability)
	local damageTable = {
		victim = victim,
		attacker = attacker,
		damage = damage,
		damage_type = damageType,
		damage_flags = damageFlags, --Optional.
		ability = ability, --Optional.
	}
	return ApplyDamage(damageTable)
end

---对所有单位都造成固定魔法伤害
--@param #table victimArray 所有的受害者，为空或者不是table，则不会造成伤害
--@param #table attacker 攻击者
--@param #number damage 伤害量,为空则不会造成伤害
function BatchApplyMagicalDamage(victimArray, attacker, damage)
	if type(victimArray) ~= "table"  or not damage then
		return;
	end
	local damageTable = {
		victim = nil,
		attacker = attacker,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	for _, victim in pairs(victimArray) do
		damageTable.victim = victim;
		ApplyDamage(damageTable)
	end
end

---对指定地点周围的<span style="color:red;">敌方单位</span>造成固定<span style="color:red;">魔法伤害</span>
--@param #Vector point 攻击点坐标
--@param #number radius 伤害范围
--@param #table attacker 攻击者
--@param #number damage 伤害量,为空则不会造成伤害
function DamageEnemiesWithinRadius(point, radius,attacker, damage)
	local enemies= FindEnemiesInRadiusEx(attacker,point,radius)
	if enemies~=nil then
		BatchApplyMagicalDamage(enemies,attacker,damage)
	end
end

---获取一个随机坐标(Vector)
--@param #Vector point 原坐标
--@param #number radius 随机范围
--@return #Vector 随机坐标
function FindRandomPoint(point,radius)
	if point then
		radius = radius or 100
		local re_point=point + RandomVector(RandomFloat(0, radius))
		return re_point;
	end

end

---两点之间的水平距离
function twoPointDistance(vector1,vector2)
	local x1 = vector1.x;
	local y1 = vector1.y;
	local x2 = vector2.x;
	local y2 = vector2.y;
	return math.sqrt(math.pow((y2-y1),2)+math.pow((x2-x1),2))
end

---将给定的vector旋转angle度
function RotateVector2D(v,angle)
	angle = math.rad(angle)
	local xp = v.x * math.cos(angle) - v.y * math.sin(angle)
	local yp = v.x * math.sin(angle) + v.y * math.cos(angle)
	return Vector(xp,yp,v.z)
end


---懒癌发作，封装dota自带的随机。随机一个[1-100]的数字，如果小于等于给定值，则返回true
--@param #number num 目标数，只能是整数，最小支持1
--@return #boolean (1-100)<=num
function RollPercent(num)
	return RollPercentage(num)
end

---随机一个[0-100]的整数（实际是包括0和100的），如果小于等于给定值，返回true
--RandomInt包含区间两头的值
--@param #number num 目标数，<font color="red">如果是0，则直接返回false</font>
--@return #number [0-100]<=num
function RandomLessInt(num)
	if num == 0 then
		return false;
	end
	return RandomInt(0,100) <= num
end

---随机一个[0-100]的浮点数（实际是包括0和100的），如果小于等于给定值，返回true
--@param #number num 目标数，<font color="red">如果是0，则直接返回false</font>
--@return #boolean [0-100]<=num
function RandomLessFloat(num)
	if num == 0 then
		return false;
	end
	return RandomFloat(0,100) <= num
end

---是否是作弊模式(IsInToolsMode 开发模式)
function IsCheatMode()
	return GameRules:IsCheatMode()
end

---获取游戏时间(游戏开始后)，不包括暂停时间
function GetGameTimeWithoutPause()
	return GameRules:GetGameTime();
end

---创建一个特效，返回特效ID
--<p>删除使用：ParticleManager:DestroyParticle(int particleID, bool immediately)
--@param #string path 特效路径
--@param #number AttachType 特效附着类型，常见类型：
--<ul>
--	<li>PATTACH_ABSORIGIN(0)：将特效附着在一个位置（origin）（一般应该是owner的位置，但是不会动）</li>
--	<li>PATTACH_ABSORIGIN_FOLLOW(1)：将特效附着在一个位置（origin），并随着owner移动。可以理解为附着在owner上</li>
--	<li>PATTACH_CUSTOMORIGIN(2)：将特效附着在一个自定义的位置上，通常还需要通过设置一个控制点（一般是0）来指明位置（Vector值）</li>
--	<li>PATTACH_CUSTOMORIGIN_FOLLOW(3)</li>
--	<li>PATTACH_POINT(4)</li>
--	<li>PATTACH_POINT_FOLLOW(5)：附着到指定点上，一般是一个attach point，在模型上的点，比如 attack_hitloc</li>
--	<li>PATTACH_EYES_FOLLOW(6)：将特效附着到对应实体的“眼睛”上（如果有的话）</li>
--	<li>PATTACH_OVERHEAD_FOLLOW(7)：将特效附着到对应实体的头顶</li>
--	<li>PATTACH_WORLDORIGIN(8)：将特效附着到地上</li>
--</ul>
--@param #table owner 特效拥有者
--@param #number duration 特效有效时间，结束后将销毁特效
--@param #boolean immediately 销毁的时候是否立刻销毁
--@return #number 特效ID
function CreateParticleEx(path,AttachType,owner,duration,immediately)
	local id = ParticleManager:CreateParticle(path,AttachType,owner)
	if type(duration) == "number" and duration >= 0 then
		TimerUtil.createTimerWithDelay(duration,function()
			if immediately == nil then
				immediately = false
			end
			ParticleManager:DestroyParticle(id, immediately)
		end)
	end
	return id
end

---设置特效的控制点数据
--另外几个是：<br/>
--SetParticleControlEnt(int particleIndex, int cpIndex?, handle owner, int attachType, string 附着点名称？, Vector 坐标？, bool bool_7)<br/>
--SetParticleControlForward(int nFXIndex, int nPoint, vForward)
--SetParticleControlOrientation(int nFXIndex, int nPoint, vForward, vRight, vUp)
function SetParticleControlEx(particleID,controlPoint,value)
	ParticleManager:SetParticleControl(particleID,controlPoint,value)
end

---为指定单位添加一个lua定义的modifier (移除：RemoveModifierByName) <p>
--(handle ApplyDataDrivenModifier(handle hCaster, handle hTarget, string pszModifierName, handle hModifierTable))
--@param #table caster 发出该modifer的单位
--@param #table target 被添加modifier的单位
--@param #string modifierName modifier名称
--@param #table modifierData modifier初始化参数。比如{duration=10}
--@return #table 添加成功后返回该modifier对象
function AddLuaModifier(caster,target,modifierName,modifierData,sourceAbility)
	return target:AddNewModifier(caster,sourceAbility,modifierName,modifierData or {})
end

---添加一个数据驱动的buff(移除：RemoveModifierByName) 
function AddDataDrivenModifier(ability,caster,target,modifierName,modifierData)
	return ability:ApplyDataDrivenModifier(caster,target,modifierName,modifierData or {})
end

---为某队伍添加临时视野。默认给玩家队伍
--<p>AddFOWViewer(nTeamID, vLocation, flRadius, flDuration, bObstructedVision)<br>
--bObstructedVision:阻塞视野
function AddTempFOWViewer(location,radius,duration,teamID)
	if not teamID then
		teamID = ZXJ_TEAM_PLAYER
	end
	AddFOWViewer(teamID, location, radius, duration, false)
end

-- **************自定义事件相关

---向所有客户端发送事件
function SendToAllClient(eventName,data)
	CustomGameEventManager:Send_ServerToAllClients(eventName,data);
end

---向某个玩家发送事件
--@param #number player 玩家id、玩家实体、或者单位实体。如果为nil，则发送给所有客户端
function SendToClient(player,eventName,data)
	if player == nil then
		SendToAllClient(eventName,data)
		return;
	end

	if type(player) == "number" then
		player = PlayerUtil.GetPlayer(player)
	elseif type(player) == "table" and player.GetPlayerOwner then
		player = PlayerUtil.GetOwnerID(player)
	end
	CustomGameEventManager:Send_ServerToPlayer(player,eventName,data);
end

---注册自定义事件的监听器
--@param #string eventName 时间名称
--@param #function handler 处理函数。函数参数有两个(unknown,data)，第一个是一个数字（暂时不知道有什么用），第二个是一个table，包括PlayerID（发送这个事件的玩家id）和所有客户端传送过来的其他参数。
--@return #number 处理器id，可以用来注销
function RegisterEventListener(eventName,handler)
	return CustomGameEventManager:RegisterListener(eventName,handler)
end

---dota7.07后，技能的behavior变成了用户自定义类型(uint64)，不是数字了。<br>
--但是在位运算比较类型的时候，仍然需要数字，所以将其转换为数字类型。
--虽然后来又改成了int，这里还这样处理
function GetAbilityBehaviorNum(ability)
	if ability then
		local behavior = ability:GetBehavior();
		if type(behavior) == "number" then
			return behavior
		else
			return tonumber(tostring(behavior)) 
		end
	end
end

---播放一个音效
function EmitSound(entity,soundName)
	if entity and entity.EmitSound and type(soundName) == "string" then
		entity:EmitSound(soundName)
	end
end

---播放一个音效
--@param #string soundName 音效名字
--@param #any Player 玩家实体或者玩家id
function EmitSoundForPlayer(soundName,Player)
	if Player and type(soundName) == "string" then
		if type(Player) == "number" then
			Player = PlayerUtil.GetPlayer(Player,false)
		end
		if type(Player) == "table" then
			EmitSoundOnClient(soundName,Player)
		end
	end
end

---获取技能当前等级的特殊值
--如果ability或svName为空，返回nil
--@param #handle ability 技能实体
--@param #string svName 特殊值名字
function GetAbilitySpecialValueByLevel(ability,svName)
	return ability:GetLevelSpecialValueFor(svName,  ability:GetLevel() - 1 )
end

---设置nettable的value，valueTable可以为nil，其他参数不可为空
function SetNetTableValue(tableName,key,valueTable)
	if type(tableName) == "string" and type(key) == "string" then
		CustomNetTables:SetTableValue(tableName,key,valueTable);
	end
end
---调用频率高的场景尽量别用。比如在modifier的客户端处理逻辑中，会导致内存上涨过快
function GetNetTableValue(tableName,key)
	if type(tableName) == "string" and type(key) == "string" then
		return CustomNetTables:GetTableValue(tableName,key);
	end
end

---返回YYYYMMDDHHmmss（字符串）
--@param #boolean onlyDate 只返回日期，如果是true，则只返回 YYYYMMDD
function GetDateTime(onlyDate)
	local date = Split(GetSystemDate(),"/");
	date = "20"..date[3]..date[1]..date[2]
	if onlyDate then
		return date;
	end
	local time = string.gsub(GetSystemTime(),":","")
	return date..time	
end

---
--包装FindClearSpaceForUnit函数。<p>
--使用FindClearSpaceForUnit实现传送的时候，虽然界面上是瞬间过去了，
--但是实际需要一段延迟才能触发triggerArea的enter事件。为了解决这个问题，添加了一些特殊的逻辑。<p>
--具体的可以查看modifier_custom_teleporting。
--@param #handle unit 单位实体
--@param #Vector postion 目标点坐标
--@param #boolean needCollision 传送过程中是否需要碰撞，某些特殊逻辑里面可能需要在传送过程中保持碰撞，此时设置为true
function Teleport(unit,postion,needCollision)
	if unit and postion then
		if needCollision then
			FindClearSpaceForUnit( unit, postion, true )
		else
--			AddLuaModifier(unit,unit,"modifier_custom_teleporting")
			FindClearSpaceForUnit( unit, postion, true ) --貌似最新版的只需要设置最后一个参数为true就能立刻触发触发区域的touch事件了。 先注释掉modifier，以后有变化了再说
--			unit:RemoveModifierByName("modifier_custom_teleporting")
		end
	end
end

---根据名字创建单位。
--@param #string unitName 单位名称
--@param #Vector postion 刷新位置
--@param #number team 所属队伍(ZXJ_TEAM_XXX)
function CreateUnitEX(unitName,postion,team)
	return CreateUnitByName(unitName, postion, true, nil, nil, team)
end