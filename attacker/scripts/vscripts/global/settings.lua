-- 各种设置信息，在游戏初始化的时候读取
print("asdasdasd")
---游戏设置时间，包括英雄选择等等
GAME_SETUP_TIME = 60
---选择英雄后到游戏开始之间的时间
PRE_GAME_TIME = 30
if IsInToolsMode() then
	GAME_SETUP_TIME = 6000000
	PRE_GAME_TIME = 10
end
-- 游戏结束后显示计分板的时间（超时将断开连接）
POST_GAME_TIME = 60                  

-- 英雄最大等级
MAX_LEVEL = 100                          	  
-- 每一级的升级所需经验，这个经验要包括之前所有等级的经验，是一个经验总量，而不是当前等级升级还需要的经验。
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
	local xp = 0;
	if i > 1 then
		xp = 499 + math.pow(i-1,2) + XP_PER_LEVEL_TABLE[i - 1]  --升级到25需要约1.7W，满级是37W
	end
	XP_PER_LEVEL_TABLE[i] = xp
end
---默认所有人都选择这个虚拟的单位，在英雄选择完毕，开始游戏的时候，替换成所选的英雄
--这样做主要是为了解决部分玩家在选英雄时掉线，重连以后就没有英雄的问题
--注意：虽然在英雄定义的时候都有一个name，但是实际运用的时候都得用对应的原生dota名字。
--所以在设置默认选择单位的时候，不是kv定义的name，而是它覆盖的英雄的名字
DUMMY_HERO = "npc_dota_hero_wisp" 

--设置各种游戏规则
local m = {};

function m.ConfigGame()
	GameRules:SetHeroRespawnEnabled( false ) --设置是否使用默认英雄复活规则

	GameRules:SetUseUniversalShopMode( false ) --为真时，所有物品当处于任意商店范围内时都能购买到，包括神秘商店商店物品
	
	--自定义游戏设置阶段
	GameRules:EnableCustomGameSetupAutoLaunch(true)
	GameRules:SetCustomGameSetupTimeout(0)

	--英雄选择阶段
	GameRules:SetStartingGold( 0 )  --设置 初始金钱为0。
	GameRules:SetHeroSelectionTime( 0 ) --设置选择英雄的时间，因为都设置了自动选择英雄，并且
	GameRules:SetStrategyTime( 0 ) --设置英雄选择后的决策时间
	GameRules:SetShowcaseTime( 0 )  --设置 天辉vs夜魇 界面的显示时间。
	

--	GameRules:SetPreGameTime( PRE_GAME_TIME) --这是游戏准备时间（英雄选择后到游戏开始）
	GameRules:SetPreGameTime(0) --这是游戏准备时间（英雄选择后到游戏开始）
	GameRules:SetPostGameTime( POST_GAME_TIME ) --设置在结束游戏后服务器与玩家断线前的时间
	
	GameRules:SetGoldTickTime(5)  --设置获得金币的时间间隔
	GameRules:SetGoldPerTick(1) --设置每个时间间隔获得的金币

	GameRules:SetHideKillMessageHeaders( true )  --设置是否隐藏击杀提示。
	GameRules:SetCustomGameAllowHeroPickMusic( false )
 	GameRules:SetCustomGameAllowBattleMusic( false )
	GameRules:SetCustomGameAllowMusicAtGameStart( false )
	
	
	local mode = GameRules:GetGameModeEntity()
	mode:SetRecommendedItemsDisabled( true ) --是否禁止显示商店中的推荐购买物品

	mode:SetBuybackEnabled( false ) -- 是否允许买活

	mode:SetFogOfWarDisabled(false) -- 是否关闭战争迷雾（对两方都有效）
	mode:SetUnseenFogOfWarEnabled(true) --启用/禁用战争迷雾（上边为false才有用）。启用的情况下，未探测区域显示不透明的黑色，探测后变成透明的灰色；禁用的情况下，未探测区域是透明的灰色覆盖

	mode:SetUseCustomHeroLevels ( true )  -- 是否允许使用自定义英雄等级（不使用，则默认只有25级）
	mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )  -- 定义英雄经验值表(table)，通过这个表来确定总共有多少级
	
	mode:SetGoldSoundDisabled( false ) -- 是否关闭英雄获得金币时的声音
	mode:SetRemoveIllusionsOnDeath( false )  -- 英雄死亡后是否移除其幻象
	mode:SetLoseGoldOnDeath( false ) -- 死亡是否损失金钱

	mode:SetAlwaysShowPlayerInventory( false ) -- 不论任何单位被选中，始终在界面上显示英雄的物品库存
	mode:SetAnnouncerDisabled( true ) -- 禁用播音员
	
	mode:SetFountainConstantManaRegen( -1 )  -- 设定泉水给予的固定魔法的恢复速率（-1表示使用dota默认设置）
	mode:SetFountainPercentageHealthRegen( -1 ) -- 设定泉水给予的的百分比生命恢复速率（-1表示使用dota默认设置）
	mode:SetFountainPercentageManaRegen( -1 ) -- 设定泉水给予的百分比魔法恢复速率（-1表示使用dota默认设置）
	
	
	--攻击速度是一个复杂的体系。简单来说，同一攻击间隔，最大攻击速度越大，满攻速时候的攻击频率就越高
	mode:SetMaximumAttackSpeed( 600 ) -- 设置单位的最大攻击速度
	mode:SetMinimumAttackSpeed( 20 ) -- 设置单位的最小攻击速度
	
	mode:SetStashPurchasingDisabled ( false ) -- 是否关闭/开启储藏处购买功能。如果该功能被关闭，英雄必须在商店范围内购买物品
	
	mode:SetSelectionGoldPenaltyEnabled( false ) --英雄选择界面超时未选择英雄的金币减少惩罚
	
	GameRules:SetSameHeroSelectionEnabled( true ) --允许选择重复英雄，因为默认都要选择同一个马甲单位，以解决选英雄阶段掉线的问题
	--默认所有人选择同一个单位，这个操作会导致游戏直接进入pregame阶段。
	mode:SetCustomGameForceHero(DUMMY_HERO)
end

return m