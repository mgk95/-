-- 修改1：引入文件
if CAddonTemplateGameMode == nil then
	_G.CAddonTemplateGameMode = class({})
end

--刷怪
require("Ashuaguai.mob_spawner")
require("libraries.reg.LibRegister")
--物品掉落
require("GameEventListeners")
require("wupin.itemDrop")
require("wupin.events")
require("Fuhuo.fuhuo")
require("CombineList")


UtilRegister = require("utils.reg.UtilRegister")

GameRules.DropTable = LoadKeyValues("scripts/kv/item_drops.txt")



function Precache(context)
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end


--注册过滤器
if Filter == nil then
    Filter = {}
end


--设置伤害倍率
function Filter:DamageFilter(keys)
    --body
    keys.damage = keys.damage*10
    return true 
end


function CAddonTemplateGameMode:InitGameMode()

	--取消载入
	GameRules:SetHeroSelectionTime(10)

	-- 设置战前准备时间
	GameRules:SetPreGameTime(10)

	--取消载入
	GameRules:SetHeroSelectPenaltyTime(0)

	-- 设置起始金钱
	GameRules:SetStartingGold(2000)

	-- 修改2：把备战时间调短
	GameRules:SetShowcaseTime(0)

	--策略时间
	GameRules:SetStrategyTime(0)

	--设置是否使用默认英雄复活规则
	GameRules:SetHeroRespawnEnabled( false )
	
--[[
	-- 是否允许买活
	GameRules:SetBuybackEnabled( false ) 

	--英雄选择界面超时未选择英雄的金币减少惩罚
	GameRules:SetSelectionGoldPenaltyEnabled( false ) 
]]

	-- 修改3：创建并启动刷怪器
	self.mob_spawner = MobSpawner()
	self.mob_spawner:Start()
	print("Template addon is loaded.")
	--监听事件
	ListenToGameEvent("NPCSpawned", Dynamic_Wrap(CAddonTemplateGameMode,"OnNPCSpawned"), self)

	GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 2)

	ListenToGameEvent('entity_killed', Dynamic_Wrap(CAddonTemplateGameMode,'OnEntityKilled'), self)

	--self:_RegisterCustomGameEventListeners()

	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(Filter,"DamageFilter"),Filter)
end




-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	--print("Template addon script is running.")
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end


--[[
	--监听死亡，掉落
function CAddonTemplateGameMode:OnEntityKilled(event)
    --body
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    RollDrops(killedUnit)
end

--[[
function Filter:DamageFilter( keys )
	local damage = keys.damage
	local damageType = keys.damagetype_const
	local attacker = EntIndexToHScript(keys.entindex_attacker_const or -1)
	local victim = EntIndexToHScript (keys.entindex_victim_const or -1)
	local victim_unitname = victim:GetUnitName()
	return true
end
]]