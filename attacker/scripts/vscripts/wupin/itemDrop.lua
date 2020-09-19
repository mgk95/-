--掉落物品

function RollDrops(unit)
    local DropInfo = GameRules.DropTable[unit:GetUnitName()]
    if DropInfo then
        for k,ItemTable in pairs(DropInfo) do
            --If its an ItemSet entry, decide which item to drop
            local item_name
            if ItemTable.ItemSets then
                -- Count how many there are to choose from
                local count = 0
                for i,v in pairs(ItemTable.ItemSets) do
                    count = count + 1
                end
                local random_i = RandomInt(1, count )
                item_name = ItemTable.ItemSets [tostring(random_i)]
            else
                item_name = ItemTable.Item 
            end
            local chance = ItemTable.Chance or 100
            local max_drops = ItemTable.Multiple or 1
            for i=1, max_drops do
                if RollPercentage(chance) then 
                    local item = CreateItem(item_name, nil, nil)
                    item:SetPurchaseTime(0)
                    local pos = unit:GetAbsOrigin()
                    local drop = CreateItemOnPositionSync( pos, item )
                    local pos_ launch = pos + RandomVector( RandomFloat(150 ,200))
                    --弹射物品
                    --item:LaunchLoot(false, 200, 0.75,pos_launch)
                end
            end 
        end 
    end
end
    