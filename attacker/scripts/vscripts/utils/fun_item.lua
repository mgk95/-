--背包中，装备位置（只有前6个装备会生效）
local body_equip_space = 6;

--物品相关的操作
local m = {}

print("wp")
---尝试合成物品
--@param #number PlayerID 玩家id
function m.try_combine(PlayerID)
	if type(PlayerID) ~= "number" then
		return 
	end

	local hero = PlayerUtil.GetHero(PlayerID)
	local courier = PlayerUtil.GetXinShi(PlayerID)

	local composeSuccess = false;
	--遍历所有的物品合成公式。index是物品合成公式的索引，formula是合成公式
	for index, formula in pairs(CombineList.recipes) do
		--检查是否可以合成当前物品，遍历所有的材料(从第二个开始)，如果所有材料都有，并且数量满足要求，则可以进行合成
		local canCombine = true;
		local forDelete = {};--记录各个部件和数量，用来做删除
		for materialIndex=2, #formula do
			local material = formula[materialIndex]--材料名字
			local needNum = 1;
			if type(material) == "table" then --如果材料是table类型的，则认为有两个元素：name和num，即物品名称和需要的数量
				needNum = material[2] or 1 --如果为空，默认为1。最好不要空
				material = material[1]
			end
			
			--如果所需要的物品锁定了，就忽略当前这个公式
			if Backpack.isItemLocked(PlayerID,material) then
				canCombine = false;
				break;
			else --物品没有锁定，判断数量是否够，不够也忽略当前公式
				local hasNum = m.GetItemCount(hero,material) --英雄持有的数量+信使持有的数量

				if hasNum < needNum then
					canCombine = false;
					break;
				else
					forDelete[material] = needNum;
				end
			end
		end

		if canCombine then
			--先删除需要的材料
			for material, num in pairs(forDelete) do
				m.removeItemByNameAndNum(hero,material,num)
			end
			local resultItemName = formula[1] --合成的物品名称
			--发送提示信息
			NotifyUtil.Bottom(PlayerID,"#item_combine_tip",3,"yellow")
			NotifyUtil.Bottom(PlayerID,"#DOTA_Tooltip_ability_"..resultItemName,3,"#CD00CD",true)
			--添加合成后的物品
			m.addItemToPlayer(PlayerID,resultItemName);
			--标记有合成成功的
			composeSuccess = true
			
			--合成成功直接返回，即每次只能合成一个物品（去掉自动合成20160829，如需要重新开启自动合成，去掉return即可）
			return
		end
	end

	if composeSuccess then--如果合成成功，则递归，有可能能连续合成，比如AB合成了C，然后C又可以和身上的D进行合成，这个时候仍然要进一步合成
		m.try_combine(PlayerID)
	else
		--提示：合成失败，请检查合成材料是否在身上或者储藏室
		NotifyUtil.BottomUnique(PlayerID,"#Compose_Faild_Hint",5,"Yellow")
	end

end

---给玩家添加一个物品。<span style="color:red;">无论是否拥有，都会添加一个新物品，所以如果是增加可叠加物品数量，使用addItemByNameAndNum</span><p>
--<pre>
--1.如果玩家对应的英雄存在并且物品栏或者背包有空间，则给英雄；
--2.否则尝试给鸟；
--3.如果两者都没有空间，则判断是否允许放在地上（allowGround），如果允许，则放置在英雄所在位置的地上。默认允许
--</pre>
--@param #any PlayerID 玩家id或者属于某个玩家的单位实体
--@param #any item 物品实体或者物品的名字
--@param #boolean allowGround 是否允许放在地上，只有为false的时候，才不放在地上
function m.addItemToPlayer(PlayerID,item,allowGround)
	return Backpack.addItem(PlayerID,item,allowGround == false)
end

---根据物品名称为玩家生成多个物品。<p>
--如果鸟、英雄、储藏室有空间，就生成到单位身上或者储藏室，没有空间就掉落在出生点<br>
--当物品可叠加的时候，会先判断是否存在该物品，如果存在，则叠加数量，否则新增
--@param #handle unit 单位实体
--@param #string itemName 物品名称
--@param #number num 数量，如果为0则不处理，如果为空，则默认为1
function m.addItemByNameAndNum(unit,itemName,num)
	return Backpack.addItemByNameAndNum(unit,itemName,num)

end

---根据名字移除   单位身上   的第一个匹配的物品
--<span style="color:red;font-weight:bold;">注意是移除一个item。对于可叠加的物品，因为叠加物品属于一个item，所将忽视叠加数量，直接删除，</span>
--@param #handle unit 单位实体
--@param #string itemName 要删除的物品名称
--@return #boolean 是否删除成功，存在该物品，并且移除了则返回true，否则是false
--@return #handle purchaser，该物品原来的拥有者。这个主要是用来处理别人代刷物品的场景，比如耀光戒，有很多人都会丢给挂机凡去升级，但是这个物品的归属应该始终是属于原玩家的。
--所以在删除低级物品后，要返回所属玩家，这样在生成新物品的时候，就可以保持其拥有者不变了
function m.removeBodyItem(unit,itemName)
	local item = Backpack.removeBodyItem(unit,itemName,true)
	if item then
		local purchaser = item:GetPurchaser()
		--删掉物品
		unit:RemoveItem(item)
		return true,purchaser
	end
	return false
end

---根据名字移除物品(有多个的时候，只移除第一个)
--<span style="color:red;font-weight:bold;">注意是移除一个item。对于可叠加的物品，因为叠加物品属于一个item，所将忽视叠加数量，直接删除，</span>
--@param #table unit 目标单位，可以是英雄或者信使或者其他被玩家拥有的单位
--@param #string itemName 要删除物品的名称
--@return true表示存在对应的物品，并已经删除；false表示不存在对应物品
function m.removeItemByname(unit,itemName)
	local item = Backpack.removeItem(unit,itemName,true)
	if item then
		EntityHelper.remove(item)
	end
	return item ~= nil
end


---将itemName指定的物品减少decrement个<p>
--<span style="color:red;font-weight:bold;">注意：如果拥有的总数量小于要减少的数量，将会删除全部。所以最好和GetItemCount()结合着用</span>
--@param #table unit 拥有者
--@param #string itemName 物品名称
--@param #number decrement 要减少的数量，为空则数量减少1；为0，则不操作
--@return 返回一共移除掉了多少个
function m.removeItemByNameAndNum(unit,itemName,decrement)
	return Backpack.reduceItemByNameAndNum(unit,itemName,decrement)
end


---减少物品的数量（可叠加物品减少叠加数量），当要减少的数量超过物品当前的数量时，将删除该物品，但是不影响其他的同名物品。<p>
--如果必须要移除指定数量的同名物品，用removeItemByNameAndNum
--@param #handle unit 单位实体
--@param #handle item 物品实体
--@param #number needRemoveNum 需要减少的数量，默认是1，为0不处理
--@return #number 返回移除的数量
function m.reduceItemNum(unit,item,reduceCount)
	if type(unit) == "table" and type(item) == "table" and reduceCount ~= 0 then
		reduceCount = reduceCount or 1
		if item:IsStackable() then
			local charges = item:GetCurrentCharges()
			if charges > reduceCount then
				item:SetCurrentCharges(charges - reduceCount)
				return reduceCount
			else
				Backpack.removeItem(unit,item,false)
				return charges
			end
		else
			Backpack.removeItem(unit,item,false)
			return reduceCount
		end
	end
	return 0
end

---检查某单位是否有某个名字的物品
--依次检查该单位所属玩家的：英雄、背包、信使
function m.HasItem(unit,itemName)
	if unit == nil or itemName == nil then
		return false
	end
	return Backpack.getFirstItem(PlayerUtil.GetOwnerID(unit),itemName) ~= nil
end

---检查单位是否装备了某件物品（在物品栏）
--@param #handle unit 单位实体
--@param #any nameOrIndex 物品名字或者实体索引
function m.HasItemInBody( unit,nameOrIndex )
	if not unit or not nameOrIndex then
		return false
	end
	return Backpack.getBodyItem(unit,nameOrIndex) ~= nil
end

---检查对应单位身上是否装备了指定的物品（在物品栏），将物品名字中第二节（以下划线分节）的名字作为类型
function m.EquipedItemWithType( unit,type )
	for i=0,body_equip_space-1 do
		local item = unit:GetItemInSlot(i)
		if EntityNotNull(item) then
			local itemName = item:GetName()
			local itemtype_table = Split(itemName, "_")
			if itemtype_table[2] == type then
				return true
			end
		end
	end
	return false
end

---丢弃物品
--@param #handle item 物品实体
--@param #handle unit 单位实体
function m.DropItem(item,unit)
	EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", unit:GetPlayerOwner())
	Backpack.dropItemStart(unit,item,nil,nil)
end

---获取某玩家持有的同名物品的数量。包括英雄、背包、信使身上
--@param #handle unit 某个玩家拥有的单位实体
--@param #string itemName 物品名称
function m.GetItemCount( unit,itemName)
	if type(unit) ~= "table" or type(itemName) ~= "string" then
		return 0;
	end

	local PlayerID = unit:GetPlayerOwnerID();
	
	local items = Backpack.getAllItem(PlayerID,itemName)

	local total = 0;
	if items then
		for key, item in pairs(items) do
			if item:IsStackable() then --可叠加的
				total = total + item:GetCurrentCharges();
			else
				total = total + 1;
			end
		end
	end

	return total
end

---检查该单位是否已经装备了武器，如果是，则将已经装备的武器放在背包，如果背包满了，就扔在地上
function m:DropExistWeapon( unit ,ignore)
	for i=0,body_equip_space - 1 do
		local bagItem = unit:GetItemInSlot(i)
		if bagItem then
			if ItemInfo.isWeapon(bagItem:GetAbilityName()) and bagItem ~= ignore then
				Backpack.MoveToBackpack(unit,bagItem,nil,true)
			end
		end
	end
end

return m
