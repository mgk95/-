function CAddonTemplateGameMode:OnNPCSpawned(keys)
    local npc = EnIndexToHScript(keys.entindex)
    --判断是否是英雄
    if npc:isRealHero() then
        --前面是创建位置，后面是持续时间
        CreateTempTree(npc:GetOrigin(), 10)
    end
end

