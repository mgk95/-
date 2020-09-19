local m = {}



---设置是否禁用英雄默认的复活逻辑。禁用以后，英雄死亡了则不会自动进入复活倒计时，也不会复活
function m.SetRespawnDisabled(hero,disabled)
	hero.NotUseDefaultRespawnLogic = disabled;
end

function m.RespawnHero(diedHero,force)
	if diedHero:IsAlive() then
		return
	end
	--NotUseDefaultRespawn，有些特殊的逻辑会禁用默认的复活，比如张小凡的灵锻武器本身带有复活，就不用这个复活了
	if diedHero.NotUseDefaultRespawnLogic and not force then
		return;
	end
	
	local point= Entities:FindByName(nil,"point_caomiao_spawn"):GetAbsOrigin()  --草庙村复活点坐标
	point = point+RandomVector(RandomFloat(0, 800))

	local timeToRespwan = 3 --复活时间
	
	local playerID = diedHero:GetPlayerID();
	--复活时间计时器
	TimerUtil.createTimer(function ()
		--计时结束英雄还没有复活，就复活英雄。 有些时候timeToRespwan会变成nil，这里一样认为可以复活
		if (timeToRespwan == nil  or timeToRespwan <= 0) and not diedHero:IsAlive() then
			m.doRespawn(diedHero,point);
			return;
		end
		if not GameRules:IsGamePaused() then
			NotifyUtil.Bottom(playerID,timeToRespwan,1,"red",false)
			NotifyUtil.Bottom(playerID,"#zxj_respwan_hint",1,"red",true)

			timeToRespwan = timeToRespwan - 1
			--当断线重连的时候，会出现负值，所以如果出现负值，则立刻复活英雄（目前还没找到原因，先这么处理）
			if timeToRespwan < 0 then
				m.doRespawn(diedHero,point);
				return 
			end
		end
		return 1;  --函数1秒执行一次
	end)
end

---复活英雄，血量为60%，蓝量为50%
--@param #table diedHero 复活后的英雄
--@param #Vector point 复活地点
function m.doRespawn(diedHero,point)
	Teleport(diedHero,point)
	diedHero:RespawnHero(false, false) --复活
	diedHero:SetHealth(diedHero:GetMaxHealth() * 0.6)
	diedHero:SetMana(diedHero:GetMaxMana() * 0.5)
end