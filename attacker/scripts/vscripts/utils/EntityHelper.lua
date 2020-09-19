require("libraries.DotaEx")

print("jzlzzzzzzzzzzz")
---判断一个实体是否不为空：lua对象不为空，并且对应的c++实体也不为空
--@param #table entity 实体对象
function EntityNotNull(entity)
	return entity and not entity:IsNull()
end

---判断一个实体是否为空：lua对象为空，或对应的c++实体为空
--@param #table entity 实体对象
function EntityIsNull(entity)
	return not entity or entity:IsNull()
end
---判断一个实体是否存活：lua对象不为空，并且对应的c++实体也不为空，并且活着
function EntityIsAlive(entity)
	return EntityNotNull(entity) and entity:IsAlive()
end

--*****************************************************************************************************************************
--实体操作工具类，封装了dota2的接口以便于使用(写代码的时候可以在ide中通过提示获取方法，而不容易出错，也便于查找)
--*****************************************************************************************************************************
local m = {}
--根据实体的索引获取实体对象
function m.findEntityByIndex(index)
	if index then
		return EntIndexToHScript( index )
	end
end

--根据实体对象获取实体索引
function m.getEntityIndex(entity)
	if entity then
		return entity:entindex();
	end
end

---根据实体名称获取实体对象
function m.findEntityByName(name)
	if name then
		return Entities:FindByName(nil,name)
	end
end

---移除一个不为空的实体。这个会移除掉对应的c++对象，但是lua对象还是可用的
function m.remove(entity)
	if EntityNotNull(entity) then
		entity:RemoveSelf();
	end
end

--获取拥有这个实体的玩家id
function m.getPlayerID(entity)
	if entity and entity.GetPlayerOwnerID ~= nil then
		return entity:GetPlayerOwnerID();
	end
end

---building类的npc在v社某次更新后不会自动播放动画了,用这个方法强制播放动画。
function m.letNPCMove()
	local buildings = Entities:FindAllByClassname("npc_dota_building");
	for _, entity in pairs(buildings) do
		entity:StartGesture(ACT_DOTA_IDLE);
	end
end

--单位是否是林惊羽
function m.IsLJY(unit)
	if unit then
		local name = unit:GetUnitName();
		return "npc_dota_hero_dragon_knight" == name;
	end
end

--单位是否是陆雪琪
function m.IsLXQ(unit)
	if unit then
		local name = unit:GetUnitName();
		return "npc_dota_hero_crystal_maiden" == name;
	end
end

--判断给定单位是否是小白
function m.IsXB(unit)
	if unit then
		local name = unit:GetUnitName();
		return "npc_dota_hero_lina" == name;
	end
end

--单位是否是张小凡
function m.IsZXF(unit)
	if unit then
		local name = unit:GetUnitName();
		return "npc_dota_hero_phantom_lancer" == name;
	end
end

--单位是否是法相
function m.IsFX(unit)
	if unit then
		local name = unit:GetUnitName();
		return "npc_dota_hero_terrorblade" == name;
	end
end

--判断给定单位是否是金瓶儿
function m.IsJPEr(unit)
	if unit then
		local name = unit:GetUnitName();
		return "npc_dota_hero_phantom_assassin" == name;
	end
end

---在地图上某个实体点的位置显示提示信息
function m.ShowOnMiniMap(entity)
	if entity and entity.GetAbsOrigin then
		SendToAllClient("zxj_ping_minimap",{loc=entity:GetAbsOrigin()})
	end
end

---判断给定实体是否是英雄：不为空，并且是英雄的时候才返回true
function m.IsHero(entity)
	return EntityNotNull(entity) and entity.IsHero and entity:IsHero()
end

--给定的实体是否是力量型英雄
function m.IsStrengthHero(entity)
	return m.IsHero(entity) and entity:GetPrimaryAttribute() ==  DOTA_ATTRIBUTE_STRENGTH;
end

--给定的实体是否是敏捷型英雄
function m.IsAgilityHero(entity)
	return m.IsHero(entity) and entity:GetPrimaryAttribute() ==  DOTA_ATTRIBUTE_AGILITY;
end

--给定的实体是否是智力型英雄
function m.IsIntellectHero(entity)
	return m.IsHero(entity) and entity:GetPrimaryAttribute() ==  DOTA_ATTRIBUTE_INTELLECT;
end


return m;
