-- 引用刷怪配置
local spawner_config = require("Ashuaguai.config_mob_spawn")

if MobSpawner == nil then
    MobSpawner = class({})
end

-- 启动刷怪逻辑
function MobSpawner:Start()
    -- 注册 Thinker https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/ThinkerFunctions
    GameRules:GetGameModeEntity():SetThink("OnThink", self)
    -- 初始化波数，当前第0波
    self.wave = 0
end

-- 每1秒判断一次，时间到了就刷怪，然后停止这个 Thinker
function MobSpawner:OnThink()
    local now = GameRules:GetDOTATime(false, true)
    if self.wave >= 0 and now >= spawner_config.spawn_start_time then
        if self.wave <= 5 then
          local i =   self:SpawnNextWave()
        else 
            return nil
        end
        
    end
    return 15
 end

-- 根据每波多少个怪，开始循环，每次循环就调用 刷单个怪
function MobSpawner:SpawnNextWave()
    self.wave = self.wave + 1
    for i = 1,self.wave do
        local wave_info = spawner_config.waves[self.wave]
        if wave_info then
            for i = 1, wave_info.num do
                self:SpawnMob(wave_info.name, wave_info.location, wave_info.level, wave_info.path)
            end
        else
            print("Chu Guai")
        end
    end
end


MobSpawner.creep = 
{
    -- 僵尸
    "niu",
    -- 骷髅
    "yang",
    -- 巨魔
    "huoren",
    -- 巫师
    "wolf",
}
local random_value = 0
-- 随机小怪
function MobSpawner:RandomCreepName()
    random_value = RandomInt(1, #MobSpawner.creep)
    return MobSpawner.creep[random_value]
end



--刷单个怪
function MobSpawner:SpawnMob(name, location, level, path)

    local name = self:RandomCreepName()
    -- 找刷怪点实体 https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API/CEntities.FindByName
    local location_ent = Entities:FindByName(nil, location)
    -- 拿到刷怪点的坐标 
    local position = location_ent:GetOrigin()
    -- 创建单位 https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API/Global.CreateUnitByName
    local mob = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    -- 设置怪物等级
    mob:CreatureLevelUp(level)
    if path then
        -- 设置怪物必须按路线走
        mob:SetMustReachEachGoalEntity(true)
        local path_ent = Entities:FindByName(nil, path)
        -- 设置怪物寻路的第一个路径点
        mob:SetInitialGoalEntity(path_ent)
    end
end
