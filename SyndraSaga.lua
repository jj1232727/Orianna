if myHero.charName ~= 'Syndra' then return end


require "MapPosition"

Latency = Game.Latency
    local PurpleBallBitch = myHero
    local ping = Game.Latency()/1000
    local itsReadyBitch = Game.CanUseSpell
    local BallHeroes = Game.HeroCount
    local HeroBalls = Game.Hero
    local smallshits = Game.MinionCount
    local littleshit = Game.Minion
    local shitaround = Game.ObjectCount
    local shit = Game.Object
    local cock = os.clock
	local SagaIcon = "https://raw.githubusercontent.com/jj1232727/Orianna/master/images/saga.png"
	local Q = {Range = 800, Width = 50, Delay = 0.6 + ping, Speed = 1000, Collision = false, aoe = false, Type = "circular", Radius = 150, From = PurpleBallBitch}
	local W = {Delay = 0.25 + ping, Speed = 1450, Collision = false, aoe = false, Type = "circular", Radius = 210, From = PurpleBallBitch, Range = 950}
	local E = {Range = 1000, Width = 50, Delay = ping, Speed = 2000, Radius = 0,Collision = false, aoe = false, Type = "line", From = PurpleBallBitch}
	local R = {Delay = 0.6 + ping, Speed = 1200, Collision = false, aoe = false, Type = "circular", Radius = 310, From = PurpleBallBitch, Range = 800}
	local Qdamage = {50, 95, 140, 185, 230}
    local visionTick = GetTickCount()
    local hugeballs = math.huge
    local MathPI = math.pi
    local atan2 = math.atan2
    local miniballs = math.min
    local Timer  = Game.Timer
    local LocalCallbackAdd = Callback.Add
    local IDList = {}
    local bitch, bitchpos
    local thesenuts
    local _EnemyHeroes
    local _OnVision = {}
    local TotalHeroes
    local TEAM_ALLY = PurpleBallBitch.team
    local TEAM_ENEMY = 300 - TEAM_ALLY
    local bitchList = {"Annie", "Malzahar", "Zyra", "Ivern", "Kalista", "Yorick", "Heimerdinger"}
    local myCounter = 1
    local IDListNumber
    local rDMG
    local finaldamage
    local rlvl = PurpleBallBitch:GetSpellData(_R).level
    local qlvl = PurpleBallBitch:GetSpellData(_Q).level
    local dmgQ
    local qDMG
    local eBola
    local isEvading = ExtLibEvade and ExtLibEvade.Evading
    local Tard_RangeCount = 0 -- <3 yaddle
    local ball_counter = 0
    local hpredTick = 0
    local wCounter = 0
    local _movementHistory = {}
    
    
    --WR PREDICTION USAGE ---
    local _STUN = 5
    local _TAUNT = 8    
    local _SLOW = 10    
    local _SNARE = 11
    local _CHARM = 22
    local _SUPRESS = 24        
    local _AIRBORNE = 30
    local _SLEEP = 18
    ---WR PREDICTION USAGE -----

    local DamageReductionTable = {
        ['Braum'] = {
            buff = 'BraumShieldRaise',
            amount = function(target)
                return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level]
            end
        },
        ['Urgot'] = {
            buff = 'urgotswapdef',
            amount = function(target)
                return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level]
            end
        },
        ['Alistar'] = {
            buff = 'Ferocious Howl',
            amount = function(target)
                return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level]
            end
        },
        ['Amumu'] = {
            buff = 'Tantrum',
            amount = function(target)
                return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level]
            end,
            damageType = 1
        },
        ['Galio'] = {
            buff = 'GalioIdolOfDurand',
            amount = function(target)
                return 0.5
            end
        },
        ['Garen'] = {
            buff = 'GarenW',
            amount = function(target)
                return 0.7
            end
        },
        ['Gragas'] = {
            buff = 'GragasWSelf',
            amount = function(target)
                return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level]
            end
        },
        ['Annie'] = {
            buff = 'MoltenShield',
            amount = function(target)
                return 1 - ({0.16, 0.22, 0.28, 0.34, 0.4})[target:GetSpellData(_E).level]
            end
        },
        ['Malzahar'] = {
            buff = 'malzaharpassiveshield',
            amount = function(target)
                return 0.1
            end
        }
    }

    local
        GetEnemyHeroes,
		findEmemy,
		ClearJungle,
		HarassMode,
		ClearMode,
        validTarget,
        ValidTargetM,
		GetDistanceSqr,
        GetDistance,
        DamageReductionMod,
        OnVision,
        OnVisionF,
		CalcMagicalDamage,
		PassivePercentMod,
        GetItemSlot,
        Angle,
        Saga
    
    local sqrt = math.sqrt
	GetDistanceSqr = function(p1, p2)
		p2 = p2 or PurpleBallBitch
		p1 = p1.pos or p1
		p2 = p2.pos or p2
		
	
		local dx, dz = p1.x - p2.x, p1.z - p2.z 
		return dx * dx + dz * dz
	end

	GetDistance = function(p1, p2)
		
		return sqrt(GetDistanceSqr(p1, p2))
    end
    
    GetEnemyHeroes = function()
        if _EnemyHeroes then
            return _EnemyHeroes
        end
        _EnemyHeroes = {}
        for i = 1, BallHeroes() do
            local unit = HeroBalls(i)
            if unit.team == TEAM_ENEMY  then
                _EnemyHeroes[myCounter] = unit
                myCounter = myCounter + 1
            end
        end
        myCounter = 1
        return #_EnemyHeroes
    end

    findEmemy = function(range)
        local target
        for i=1, BallHeroes() do
            local unit= HeroBalls(i)
            if unit and unit.isEnemy and unit.valid and unit.distance <= range and unit.isTargetable and not unit.dead and not unit.isImmortal and not (GotBuff(unit, 'FioraW') == 1) and
                not (GotBuff(unit, 'XinZhaoRRangedImmunity') == 1 and unit.distance < 450) and unit.visible then
                target = unit
            end
        end
        return target
    end

    CalcMagicalDamage = function(source, target, amount)
        local mr = target.magicResist
        local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)
      
        if mr < 0 then
          value = 2 - 100 / (100 - mr)
        elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
          value = 1
        end
        return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 2)))
      end
    
      DamageReductionMod = function(source,target,amount,DamageType)
        if source.type == Obj_AI_Hero then
          if GotBuff(source, "Exhaust") > 0 then
            amount = amount * 0.6
          end
        end
        if target.type == Obj_AI_Hero then
          for i = 0, target.buffCount do
            if target:GetBuff(i).count > 0 then
              local buff = target:GetBuff(i)
              if buff.name == "MasteryWardenOfTheDawn" then
                amount = amount * (1 - (0.06 * buff.count))
              end
              if DamageReductionTable[target.charName] then
                if buff.name == DamageReductionTable[target.charName].buff and (not DamageReductionTable[target.charName].damagetype or DamageReductionTable[target.charName].damagetype == DamageType) then
                  amount = amount * DamageReductionTable[target.charName].amount(target)
                end
              end
              if target.charName == "Maokai" and source.type ~= Obj_AI_Turret then
                if buff.name == "MaokaiDrainDefense" then
                  amount = amount * 0.8
                end
              end
              if target.charName == "MasterYi" then
                if buff.name == "Meditate" then
                  amount = amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[target:GetSpellData(_W).level] / (source.type == Obj_AI_Turret and 2 or 1)
                end
              end
            end
          end
        if target.charName == "Kassadin" and DamageType == 2 then
            amount = amount * 0.85
          end
        end
        return amount
      end
    
      PassivePercentMod = function(source, target, amount, damageType)
        local SiegeMinionList = {"Red_Minion_MechCannon", "Blue_Minion_MechCannon"}
        local NormalMinionList = {"Red_Minion_Wizard", "Blue_Minion_Wizard", "Red_Minion_Basic", "Blue_Minion_Basic"}
        if source.type == Obj_AI_Turret then
          if table.contains(SiegeMinionList, target.charName) then
            amount = amount * 0.7
          elseif table.contains(NormalMinionList, target.charName) then
            amount = amount * 1.14285714285714
          end
        end
        if source.type == Obj_AI_Hero then 
          if target.type == Obj_AI_Hero then
            if (GetItemSlot(source, 3036) > 0 or GetItemSlot(source, 3034) > 0) and source.maxHealth < target.maxHealth and damageType == 1 then
              amount = amount * (1 + math.min(target.maxHealth - source.maxHealth, 500) / 50 * (GetItemSlot(source, 3036) > 0 and 0.015 or 0.01))
            end
          end
        end
        return amount
        end
        
        GetItemSlot = function(unit, id)
            for i = ITEM_1, ITEM_7 do
                if unit:GetItemData(i).itemID == id then
                    return i
                end
            end
            return 0
        end

        local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
        CastSpell = function(spell,pos,range,delay)
        
            local range = range or hugeballs
            local delay = delay or 250
            local ticker = GetTickCount()
        
            if castSpell.state == 0 and GetDistance(PurpleBallBitch.pos, pos) < range and ticker - castSpell.casting > delay + Latency() then
                castSpell.state = 1
                castSpell.mouse = mousePos
                castSpell.tick = ticker
            end
            if castSpell.state == 1 then
                if ticker - castSpell.tick < Latency() then
                    Control.SetCursorPos(pos)
                    Control.KeyDown(spell)
                    Control.KeyUp(spell)
                    castSpell.casting = ticker + delay
                    DelayAction(function()
                        if castSpell.state == 1 then
                            Control.SetCursorPos(castSpell.mouse)
                            castSpell.state = 0
                        end
                    end,Latency()/1000)
                end
                if ticker - castSpell.casting > Latency() then
                    Control.SetCursorPos(castSpell.mouse)
                    castSpell.state = 0
                end
            end
        end

    CastSpellMM = function(spell, pos, range, delay)

	local range = range or hugeballs
	local delay = delay or 250
	local ticker = GetTickCount()

	if castSpell.state == 0 and GetDistance(myHero.pos, pos) < range and ticker - castSpell.casting > delay + Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Latency() then
			local castPosMM = pos:ToMM()
			Control.SetCursorPos(castPosMM.x,castPosMM.y)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Latency()/1000)
		end
		if ticker - castSpell.casting > Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

        OnVision = function(unit)
            _OnVision[unit.networkID] = _OnVision[unit.networkID] == nil and {state = unit.visible, tick = GetTickCount(), pos = unit.pos} or _OnVision[unit.networkID]
            if _OnVision[unit.networkID].state == true and not unit.visible then
                _OnVision[unit.networkID].state = false
                _OnVision[unit.networkID].tick = GetTickCount()
            end
            if _OnVision[unit.networkID].state == false and unit.visible then
                _OnVision[unit.networkID].state = true
                _OnVision[unit.networkID].tick = GetTickCount()
            end
            return _OnVision[unit.networkID]
        end
        
        OnVisionF = function()
            if GetTickCount() - visionTick > 100 then
                for i = 1, TotalHeroes do
                    OnVision(_EnemyHeroes[i])
                end
                visionTick = GetTickCount()
            end
        end

        findMinion = function()
            for i = 1, smallshits() do
                local minion = littleshit(i)
                if i > 1000 then return end
                if minion and minion.pos:DistanceTo() < W.Range and minion.isTargetable and minion.isEnemy and not minion.dead and minion.visible then
                    return minion, minion.pos
                end
            end
        end

    LocalCallbackAdd(
    'Load',
	function()
        
        TotalHeroes = GetEnemyHeroes()
        IDListNumber = GetHeroesWithBitches()
        Saga_Menu()
        

		local orbwalkername = ""
		local orb
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"
			orb = _G.SDK
		elseif _G.EOW then
			orb = _G.EOW
			orbwalkername = "EOW"
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
			orb = _G.GOS
		else
			orbwalkername = "Orbwalker not found"
		end
    end
)

LocalCallbackAdd(
    'Tick',
    function()
            OnVisionF()
            
            if myHero.dead or Game.IsChatOpen() == true  or isEvading then return end

            if ball_counter + 500 < GetTickCount() then
                ballsearch()
            end


            if Saga.Auto.useAutoQ:Value() then
                AutoQ()
            end
            if Saga.Combo.comboActive:Value() and PurpleBallBitch.attackData.state ~= 2 then
                Combo()
            end
            if Saga.Harass.harassActive:Value() then
                HarassMode()
            end
            if Saga.Clear.clearActive:Value() then
                ClearMode()
                ClearJungle()
            end
            if Saga.Lasthit.lasthitActive:Value() then
                LastHitMode()
            end
            UpdateDamage()

            if  cock() - hpredTick > 10 then
                UpdateMovementHistory()
            end
            hpredTick = cock()
        end)

        LocalCallbackAdd(
    'Draw', function()
        if Saga.Drawings.Q.Enabled:Value() then Draw.Circle(PurpleBallBitch.pos, Q.Range, 0, Saga.Drawings.Q.Color:Value()) end
        if Saga.Drawings.W.Enabled:Value() then Draw.Circle(PurpleBallBitch.pos, W.Range, 0, Saga.Drawings.W.Color:Value()) end
        if Saga.Drawings.E.Enabled:Value() then Draw.Circle(PurpleBallBitch.pos, E.Range, 0, Saga.Drawings.E.Color:Value()) end
        if Saga.Drawings.R.Enabled:Value() then Draw.Circle(PurpleBallBitch.pos, R.Range, 0, Saga.Drawings.R.Color:Value()) end
        
    end)

    validTarget = function(unit)
        if unit and unit.isEnemy and unit.valid and unit.isTargetable and not unit.dead and not unit.isImmortal and not (GotBuff(unit, 'FioraW') == 1) and
        not (GotBuff(unit, 'XinZhaoRRangedImmunity') == 1 and unit.distance < 450) and unit.visible then
            return true
        else 
            return false
        end
    end    

AutoQ = function()
    local targetQ = findEmemy(Q.Range)
                if targetQ then
                    if PurpleBallBitch.attackData.state ~= 2 and itsReadyBitch(0) == 0 and targetQ.pos:DistanceTo() < Q.Range then 
                    local Qpos = GetBestCastPosition(targetQ, Q)
                    if Qpos:DistanceTo() > Q.Range then 
                    Qpos = PurpleBallBitch.pos + (Qpos - PurpleBallBitch.pos):Normalized()*Q.Range
                    end
                    Qpos = PurpleBallBitch.pos + (Qpos - PurpleBallBitch.pos):Normalized()*(GetDistance(Qpos, PurpleBallBitch.pos) + 0.5*targetQ.boundingRadius)
                    if Qpos:To2D().onScreen then
                        CastSpell(HK_Q, Qpos, Q.Range, Q.Delay*1000) 
                    else
                        CastSpellMM(HK_Q, Qpos, Q.Range, Q.Delay*1000)
                    end
                    end
                end 
end
Combo = function()
    local targetR = findEmemy(R.Range)
-----------------------------R USAGE ----------------------------------------------------
                if PurpleBallBitch.attackData.state ~= 2 and itsReadyBitch(3) == 0 and Saga.Combo.UseR:Value() then
                    rDMG = 0
                    local balls = PurpleBallBitch:GetSpellData(_R).ammo
                        if targetR then
                            local ap = .2*PurpleBallBitch.ap
                            rDMG = (finaldamage + ap ) * balls

                    local totalrDMG = CalcMagicalDamage(PurpleBallBitch, targetR, rDMG)
                    
                    if totalrDMG > (targetR.health + targetR.shieldAD + targetR.shieldAP) and targetR.pos:DistanceTo() < R.Range and Saga.KillSteal.rKS[targetR.charName]:Value() then
                        CastSpell(HK_R, targetR)
                    end
                end
                end

                -----------------------------------------------Q USAGE---------------------------------------------
---------------------------------QE Usage------------------------------------------------------------------
local target = findEmemy(1100)
if target then
--if PurpleBallBitch.dead or Game.IsChatOpen() == true  or IsEvading() == true then return end
if PurpleBallBitch.attackData.state ~= 2 and itsReadyBitch(0) == 0 and  itsReadyBitch(2) == 0 and Saga.Combo.UseE:Value() then
    if target.pos:DistanceTo() > Q.Range then
    local posE, posEC, hitchance = GetBestCastPosition(target, E)
    local pos = PurpleBallBitch.pos + (posE - PurpleBallBitch.pos):Normalized() * 600
    if itsReadyBitch(2) == 0 and itsReadyBitch(0) == 0 then
    if pos:To2D().onScreen then
        CastSpell(HK_Q, pos, Q.Range, Q.Delay*1000)
        CastSpell(HK_E, pos, E.Range, E.Delay*1000)
    else
        CastSpellMM(HK_Q, pos, Q.Range, Q.Delay*1000)
        CastSpellMM(HK_E, pos, E.Range, E.Delay*1000)
    end
    end
    elseif target.pos:DistanceTo() <= Q.Range then
        local posE, posEC, hitchance = GetBestCastPosition(target, E)
        if posE:DistanceTo() > Q.Range and hitchance > 2 then
            pos = PurpleBallBitch.pos + (posE - PurpleBallBitch.pos):Normalized()*Q.Range
            end
            pos = PurpleBallBitch.pos + (posE - PurpleBallBitch.pos):Normalized()*(GetDistance(posE, PurpleBallBitch.pos) + 0.5*target.boundingRadius)
            if hitchance >= 2 then
                if pos:To2D().onScreen then
                    CastSpell(HK_Q, pos, Q.Range, Q.Delay*1000)
                    CastSpell(HK_E, pos, E.Range, E.Delay*1000)
                else
                    CastSpellMM(HK_Q, pos, Q.Range, Q.Delay*1000)
                    CastSpellMM(HK_E, pos, E.Range, E.Delay*1000)
                end
        
        end
        
    end

end

end

local targetQ = findEmemy(Q.Range)
    if targetQ then
        if PurpleBallBitch.attackData.state ~= 2 and itsReadyBitch(0) == 0 and targetQ.pos:DistanceTo() < Q.Range and itsReadyBitch(2) ~= 0 and itsReadyBitch(1) ~= 0 and Saga.Combo.UseQ:Value() then 
            local Qpos = GetBestCastPosition(targetQ, Q)
            if Qpos:DistanceTo() > Q.Range then 
                Qpos = PurpleBallBitch.pos + (Qpos - PurpleBallBitch.pos):Normalized()*Q.Range
                end
            Qpos = PurpleBallBitch.pos + (Qpos - PurpleBallBitch.pos):Normalized()*(GetDistance(Qpos, PurpleBallBitch.pos) + 0.5*targetQ.boundingRadius)
            if Qpos:To2D().onScreen then
                CastSpell(HK_Q, Qpos, Q.Range, Q.Delay*1000) 
            else
                CastSpellMM(HK_Q, Qpos, Q.Range, Q.Delay*1000)
            end
          end
    end 
-----------------------------------------W Usage-----------------------------------------------                
                local targetW = findEmemy(W.Range)
                if targetW then
                if PurpleBallBitch.attackData.state ~= 2 and itsReadyBitch(1) == 0 and targetW.pos:DistanceTo() < W.Range and GotBuff(myHero, "syndrawtooltip") == 0 and Saga.Combo.UseW:Value() and wCounter + 100 < GetTickCount() then
                    if IDList then 
                    local bitch, bitchpos = findPet() end
                    if bitch  then
                        CastSpell(HK_W, bitchpos, W.Range, W.Delay*1000)
                        wCounter = GetTickCount()
                    elseif not bitch and #thesenuts ~= 0 then
                        for i = 1, #thesenuts do 
                            local ballQ = thesenuts[i]
                            if ballQ and ballQ:DistanceTo() < W.Range then
                                CastSpell(HK_W, ballQ, W.Range, W.Delay*1000)
                                wCounter = GetTickCount()
                            end
                            end
                        elseif not bitch and #thesenuts == 0 then 
                        local minionb, minionposb = findMinion()
                        if not minionb then return end
                        CastSpell(HK_W, minionposb, W.Range, W.Delay*1000)
                        wCounter = GetTickCount()
                    end
                end
            if  PurpleBallBitch.attackData.state ~= 2 and itsReadyBitch(1) == 0 and targetW.pos:DistanceTo() < W.Range and Saga.Combo.UseW:Value() and GotBuff(myHero, "syndrawtooltip") == 1 and wCounter + 500 < GetTickCount()then
                
                local targetW2 = findEmemy(W.Range)
                local W2Pos, WCPos, hitchance = GetBestCastPosition(targetW2, W)
                if W2Pos:DistanceTo() > W.Range and hitchance >= 2 then 
                    W2Pos = PurpleBallBitch.pos + (W2Pos - PurpleBallBitch.pos):Normalized()*W.Range
                    
                    end
                    if W2Pos:DistanceTo() < W.Range and hitchance >= 2 then
                    W2Pos = PurpleBallBitch.pos + (W2Pos - PurpleBallBitch.pos):Normalized()*(GetDistance(W2Pos, PurpleBallBitch.pos) + 0.5*targetW2.boundingRadius) end
                    if W2Pos:To2D().onScreen then
                        CastSpell(HK_W, W2Pos, W.Range, Q.Delay*1000)
                    else
                        CastSpellMM(HK_W, W2Pos, W.Range, Q.Delay*1000)
                    end
                    wCounter = GetTickCount()
            end
        end 





            -----------------------------------E Usage--------------------------
           if PurpleBallBitch.attackData.state ~= 2 and itsReadyBitch(2) == 0 and itsReadyBitch(0) ~= 0 and Saga.Combo.UseER:Value() then
                local targetER = findEmemy(1000)
                eBola(targetER, PurpleBallBitch.pos) 
                
           end
           ----------------------------------------------------------------------
end

HarassMode = function()
    local targetQ = findEmemy(Q.Range)
                if targetQ then
                    if itsReadyBitch(0) == 0 and targetQ.pos:DistanceTo() < Q.Range and Saga.Harass.UseQ:Value()then 
                    local Qpos, posQC, hitchance = GetBestCastPosition(targetQ, Q)
                    if Qpos:DistanceTo() > Q.Range then 
                    Qpos = PurpleBallBitch.pos + (Qpos - PurpleBallBitch.pos):Normalized()*Q.Range
                    end
                    Qpos = PurpleBallBitch.pos + (Qpos - PurpleBallBitch.pos):Normalized()*(GetDistance(Qpos, PurpleBallBitch.pos) + 0.5*targetQ.boundingRadius)
                    if hitchance >= 2 then 
                    CastSpell(HK_Q, Qpos, Q.Range, Q.Delay*1000) end 
                    end
                end
                
                local targetW = findEmemy(W.Range)
                if targetW then
                if PurpleBallBitch.attackData.state ~= 2 and itsReadyBitch(1) == 0 and targetW.pos:DistanceTo() < W.Range and GotBuff(myHero, "syndrawtooltip") == 0 and Saga.Combo.UseW:Value() and wCounter + 100 < GetTickCount() then
                    if IDList then 
                    local bitch, bitchpos = findPet() end
                    if bitch  then
                        CastSpell(HK_W, bitchpos, W.Range, W.Delay*1000)
                        wCounter = GetTickCount()
                    elseif not bitch and #thesenuts ~= 0 then
                        for i = 1, #thesenuts do 
                            local ballQ = thesenuts[i]
                            if ballQ and ballQ:DistanceTo() < W.Range then
                                CastSpell(HK_W, ballQ, W.Range, W.Delay*1000)
                                wCounter = GetTickCount()
                            end
                            end
                        elseif not bitch and #thesenuts == 0 then 
                        local minionb, minionposb = findMinion()
                        if not minionb then return end
                        CastSpell(HK_W, minionposb, W.Range, W.Delay*1000)
                        wCounter = GetTickCount()
                    end
                end
            if  PurpleBallBitch.attackData.state ~= 2 and itsReadyBitch(1) == 0 and targetW.pos:DistanceTo() < W.Range and Saga.Combo.UseW:Value() and GotBuff(myHero, "syndrawtooltip") == 1 and wCounter + 500 < GetTickCount()then
                
                local targetW2 = findEmemy(W.Range)
                local W2Pos, WCPos, hitchance = GetBestCastPosition(targetW2, W)
                if W2Pos:DistanceTo() > W.Range and hitchance >= 2 then 
                    W2Pos = PurpleBallBitch.pos + (W2Pos - PurpleBallBitch.pos):Normalized()*W.Range
                    
                    end
                    if W2Pos:DistanceTo() < W.Range and hitchance >= 2 then
                    W2Pos = PurpleBallBitch.pos + (W2Pos - PurpleBallBitch.pos):Normalized()*(GetDistance(W2Pos, PurpleBallBitch.pos) + 0.5*targetW2.boundingRadius) end
                    if W2Pos:To2D().onScreen then
                        CastSpell(HK_W, W2Pos, W.Range, Q.Delay*1000)
                    else
                        CastSpellMM(HK_W, W2Pos, W.Range, Q.Delay*1000)
                    end
                    wCounter = GetTickCount()
            end
        end  

end

ValidTargetM = function(target, range)
    range = range and range or math.huge
    return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

ClearMode = function()
    if Game.CanUseSpell(0) == 0 then
        local qMinions = {}
        for i = 1, Game.MinionCount() do
            local minion = Game.Minion(i)
            if  ValidTargetM(minion,Q.Range)  then
                if minion.team == TEAM_ENEMY  then
                    qMinions[#qMinions+1] = minion
                end	
        end	
            local BestPos, BestHit = GetBestCircularCastPos(Q, nil, qMinions)
            if BestHit and BestHit >= Saga.Clear.QCount:Value() and Saga.Clear.UseQ:Value() and Game.CanUseSpell(0) == 0 then
                CastSpell(HK_Q, BestPos, Q.Range, Q.Delay*1000) end
            
    end
end
end

ClearJungle = function()
	 
    
            for i = 1, Game.MinionCount() do
                local minion = Game.Minion(i)
                
                
                if string.find(minion.name, "SRU") then
                    if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 825 and Game.CanUseSpell(0) == 0 and not minion.dead and minion.visible then
                        CastSpell(HK_Q,minion.pos, Q.Range, Q.Delay*1000)
                    end
                    
                    if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 825 and Game.CanUseSpell(1) == 0 and not minion.dead and PurpleBallBitch:GetSpellData(_W).toggleState == 1 and minion.visible and thesenuts then
                    for k = 1, #thesenuts do
                        local thisnut = thesenuts[k]
                        if thisnut and thisnut:DistanceTo() < W.Range then 
                        CastSpell(HK_W, thisnut ,W.Range, W.Delay*1000)
                        end
                    end
                        
                    end

                if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 825 and Game.CanUseSpell(1) == 0 and not minion.dead and PurpleBallBitch:GetSpellData(_W).toggleState == 2 and minion.visible then
                    CastSpell(HK_W, minion.pos, W.Range, W.Delay*1000) end 
                    end
                end
end

LastHitMode = function()
    if Game.CanUseSpell(0) == 0 and Saga.Lasthit.UseQ:Value() then
            for i = 1, Game.MinionCount() do
            local minion = Game.Minion(i)
            if Game.CanUseSpell(0) ~= 0 then dmgQ = 0 else
                if qlvl < 5 then 
                    qDMG = CalcMagicalDamage(myHero,minion,dmgQ + 0.65 * myHero.ap) 
                elseif qlvl == 5 then
                    qDMG = CalcMagicalDamage(myHero,minion,264.5 + 0.7475 * myHero.ap)
                end
            end
            if minion.pos:DistanceTo() < Q.Range and Saga.Lasthit.UseQ:Value() and minion.isEnemy and not minion.dead and Game.CanUseSpell(0) == 0 then
                if dmgQ >= minion.health then
                    CastSpell(HK_Q,minion, Q.Range, Q.Delay*1000)
                end
            end
        end
    end
end


GetHeroesWithBitches = function()
    for i = 1, TotalHeroes do
    local unit = _EnemyHeroes[i]
    for k = 1, #bitchList do
    local bitches = bitchList[k]
        if bitches and unit  then
           if unit.charName == bitches then
           IDList[myCounter] = unit
           myCounter = myCounter + 1
           end
        end
        end
    end
    myCounter = 1
    return #IDList
end

findPet = function()
    if not IDList  then return end
    local minion
    for i = 1, IDListNumber do
        local bitchOwner = IDList[i]
        
        for q = 1, smallshits() do
            minion = littleshit(q)
            if minion.owner and minion.pos:DistanceTo() < W.Range and minion.owner.charName == bitchOwner.charName and minion.isTargetable and minion.isEnemy and not minion.dead and minion.visible then
                return minion, minion.pos
            end
        end
    end
end

ballsearch = function()
    local thesenutties = {}
    if ball_counter + 50 > GetTickCount() then return end
	for i = 1, shitaround() do
        local object = shit(i)
		if object and object.valid and not object.dead and object.visible then
			if object.charName:lower() == "syndrasphere" and not table.contains(thesenutties, object.pos) and object.pos:DistanceTo() < W.Range then
                thesenutties[myCounter] = object.pos
                myCounter = myCounter + 1
			end
		end
    end
    myCounter = 1
    thesenuts = thesenutties
    ball_counter = GetTickCount()
end

VectorPointProjectionOnLineSegment = function(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), z = ay + rS * (by - ay)}
	return pointSegment, pointLine, isOnSegment
end 

eBola = function(target, me)
    for i = 1, #thesenuts do 
        local ball = thesenuts[i]
        if target and ball and ball:DistanceTo() < 700 and PurpleBallBitch.attackData.state ~= 2 then
            local posE, posEC, hitchance = GetBestCastPosition(target, E)
            local linesegment, line, isOnSegment = VectorPointProjectionOnLineSegment(me, posE, ball)
            if linesegment and isOnSegment and (GetDistanceSqr(ball, linesegment) <= Q.Width * Q.Width) and itsReadyBitch(2) == 0 and target.pos:DistanceTo() < E.Range then
                CastSpell(HK_E, posE, E.Range, E.Delay*1000)
            end
        end
    end
end



VectorMovementCollision = function (startPoint1, endPoint1, v1, startPoint2, v2, delay)
	local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
	local d, e = eP1x-sP1x, eP1y-sP1y
	local dist, t1, t2 = sqrt(d*d+e*e), nil, nil
	local S, K = dist~=0 and v1*d/dist or 0, dist~=0 and v1*e/dist or 0
	local function GetCollisionPoint(t) return t and {x = sP1x+S*t, y = sP1y+K*t} or nil end
	if delay and delay~=0 then sP1x, sP1y = sP1x+S*delay, sP1y+K*delay end
	local r, j = sP2x-sP1x, sP2y-sP1y
	local c = r*r+j*j
	if dist>0 then
		if v1 == hugeballs then
			local t = dist/v1
			t1 = v2*t>=0 and t or nil
		elseif v2 == hugeballs then
			t1 = 0
		else
			local a, b = S*S+K*K-v2*v2, -r*S-j*K
			if a==0 then
				if b==0 then --c=0->t variable
					t1 = c==0 and 0 or nil
				else --2*b*t+c=0
					local t = -c/(2*b)
					t1 = v2*t>=0 and t or nil
				end
			else --a*t*t+2*b*t+c=0
				local sqr = b*b-a*c
				if sqr>=0 then
					local nom = sqrt(sqr)
					local t = (-nom-b)/a
					t1 = v2*t>=0 and t or nil
					t = (nom-b)/a
					t2 = v2*t>=0 and t or nil
				end
			end
		end
	elseif dist==0 then
		t1 = 0
	end
	return t1, GetCollisionPoint(t1), t2, GetCollisionPoint(t2), dist
end

IsDashing = function(unit, spell)
	local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From.pos
	local OnDash, CanHit, Pos = false, false, nil
	local pathData = unit.pathing
	--
	if pathData.isDashing then
		local startPos = Vector(pathData.startPos)
		local endPos = Vector(pathData.endPos)
		local dashSpeed = pathData.dashSpeed
		local timer = Timer()
		local startT = timer - Latency()/2000
		local dashDist = GetDistance(startPos, endPos)
		local endT = startT + (dashDist/dashSpeed)
		--
		if endT >= timer and startPos and endPos then
			OnDash = true
			--
			local t1, p1, t2, p2, dist = VectorMovementCollision(startPos, endPos, dashSpeed, from, speed, (timer - startT) + delay)
			t1, t2 = (t1 and 0 <= t1 and t1 <= (endT - timer - delay)) and t1 or nil, (t2 and 0 <= t2 and t2 <=  (endT - timer - delay)) and t2 or nil
			local t = t1 and t2 and miniballs(t1, t2) or t1 or t2
			--
			if t then
				Pos = t == t1 and Vector(p1.x, 0, p1.y) or Vector(p2.x, 0, p2.y)
				CanHit = true
			else
				Pos = Vector(endPos.x, 0, endPos.z)
				CanHit = (unit.ms * (delay + GetDistance(from, Pos)/speed - (endT - timer))) < radius
			end
		end
	end

	return OnDash, CanHit, Pos
end

IsImmobile = function(unit, spell)
	if unit.ms == 0 then return true, unit.pos, unit.pos end
	local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From.pos
	local debuff = {}
	for i = 1, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.duration > 0 then
			
			local ExtraDelay = speed == hugeballs and 0 or (GetDistance(from, unit.pos) / speed)
			if buff.expireTime + (radius / unit.ms) > Timer() + delay + ExtraDelay then
				debuff[buff.type] = true
			end
		end
	end
	if  debuff[_STUN] or debuff[_TAUNT] or debuff[_SNARE] or debuff[_SLEEP] or
		debuff[_CHARM] or debuff[_SUPRESS] or debuff[_AIRBORNE] then
		return true, unit.pos, unit.pos
	end
	return false, unit.pos, unit.pos
end

IsSlowed = function(unit, spell)
	local delay, speed, from = spell.Delay, spell.Speed, spell.From.pos
	for i = 1, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.type == _SLOW and buff.expireTime >= Timer() and buff.duration > 0 then
			if buff.expireTime > Timer() + delay + GetDistance(unit.pos, from) / speed then
				return true
			end
		end
	end
	return false
end

CalculateTargetPosition = function(unit, spell, tempPos)
	local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From
	local calcPos = nil
	local pathData = unit.pathing
	local pathCount = pathData.pathCount
	local pathIndex = pathData.pathIndex
	local pathEndPos = Vector(pathData.endPos)
	local pathPos = tempPos and tempPos or unit.pos
	local pathPot = (unit.ms * ((GetDistance(pathPos) / speed) + delay))
	local unitBR = unit.boundingRadius
	--
	if pathCount < 2 then
		local extPos = unit.pos:Extended(pathEndPos, pathPot - unitBR)
		--
		if GetDistance(unit.pos, extPos) > 0 then
			if GetDistance(unit.pos, pathEndPos) >= GetDistance(unit.pos, extPos) then
				calcPos = extPos
			else
				calcPos = pathEndPos
			end
		else
			calcPos = pathEndPos
		end
	else
		for i = pathIndex, pathCount do
			if unit:GetPath(i) and unit:GetPath(i - 1) then
				local startPos = i == pathIndex and unit.pos or unit:GetPath(i - 1)
				local endPos = unit:GetPath(i)
				local pathDist = GetDistance(startPos, endPos)
				--
				if unit:GetPath(pathIndex  - 1) then
					if pathPot > pathDist then
						pathPot = pathPot - pathDist
					else
						local extPos = startPos:Extended(endPos, pathPot - unitBR)

						calcPos = extPos

						if tempPos then
							return calcPos, calcPos
						else
							return CalculateTargetPosition(unit, spell, calcPos)
						end
					end
				end
			end
		end
		--
		if GetDistance(unit.pos, pathEndPos) > unitBR then
			calcPos = pathEndPos
		else
			calcPos = unit.pos
		end
	end

	calcPos = calcPos and calcPos or unit.pos

	if tempPos then
		return calcPos, calcPos
	else
		return CalculateTargetPosition(unit, spell, calcPos)
	end
end

GetBestCastPosition = function (unit, spell)
	local range = spell.Range and spell.Range - 15 or hugeballs
	local radius = spell.Radius == 0 and 1 or (spell.Radius + unit.boundingRadius) - 4
	local speed = spell.Speed or hugeballs
	local from = spell.From or PurpleBallBitch
	local delay = spell.Delay + (0.07 + Latency() / 2000)
	local collision = spell.Collision or false
	
	local Position, CastPosition, HitChance = Vector(unit), Vector(unit), 0
	local TargetDashing, CanHitDashing, DashPosition = IsDashing(unit, spell)
	local TargetImmobile, ImmobilePos, ImmobileCastPosition = IsImmobile(unit, spell)
	if TargetDashing then
		if CanHitDashing then
			HitChance = 5
		else
			HitChance = 0
		end
		Position, CastPosition = DashPosition, DashPosition
	elseif TargetImmobile then
		Position, CastPosition = ImmobilePos, ImmobileCastPosition
		HitChance = 4
	else
		Position, CastPosition = CalculateTargetPosition(unit, spell)

        if _movementHistory and _movementHistory[unit.charName] and Timer() - _movementHistory[unit.charName]['ChangedAt'] < .25 then
            HitChance = 2
        end

		if unit.activeSpell and unit.activeSpell.valid then
			HitChance = 2
		end
		if GetDistanceSqr(from.pos, CastPosition) < 250 then
			
			HitChance = 2
			local newSpell = {Range = range, Delay = delay * 0.5, Radius = radius, Width = radius, Speed = speed *2, From = from}
			Position, CastPosition = CalculateTargetPosition(unit, newSpell)
		end

		local temp_angle = from.pos:AngleBetween(unit.pos, CastPosition)
		if temp_angle > 60 then
			HitChance = 1
		elseif temp_angle < 30 then
			HitChance = 2
		end
	end
	
    
    --Dont need
	if collision and HitChance > 0 then
		local newSpell = {Range = range, Delay = delay, Radius = radius * 2, Width = radius * 2, Speed = speed *2, From = from}
		if #(mCollision(from.pos, CastPosition, newSpell)) > 0 then
			HitChance = 0                    
		end
	end        
	
	return Position, CastPosition, HitChance
end

ExcludeFurthest = function(average,lst,sTar)
	local removeID = 1 
	for i = 2, #lst do 
		if GetDistanceSqr(average, lst[i].pos) > GetDistanceSqr(average, lst[removeID].pos) then 
			removeID = i 
		end 
	end 

	local Newlst = {}
	for i = 1, #lst do 
		if (sTar and lst[i].networkID == sTar.networkID) or i ~= removeID then 
			Newlst[#Newlst + 1] = lst[i]
		end
	end
	return Newlst 
end


GetBestCircularCastPos = function(spell, sTar, lst)
	local average = {x = 0, z = 0, count = 0} 
	local heroList = lst and lst[1] and (lst[1].type == PurpleBallBitch.type)
	local range = spell.Range or 2000
	local radius = spell.Radius or 50
	
	if sTar and (not lst or #lst == 0) then 
		return GetBestCastPosition(sTar,spell), 1
	end
	
	--
	if lst then
	for i = 1, #lst do 
		if validTarget(lst[i]) then
			
			local org = heroList and GetBestCastPosition(lst[i],spell) or lst[i].pos
			
			average.x = average.x + org.x 
			average.z = average.z + org.z 
			average.count = average.count + 1
		end
	end 
end
	--
	if sTar and sTar.type ~= lst[1].type then
		
		local org = heroList and GetBestCastPosition(sTar,spell) or lst[i].pos
		
		average.x = average.x + org.x 
		average.z = average.z + org.z 
		average.count = average.count + 1
	end
	--
	average.x = average.x/average.count 
	average.z = average.z/average.count 
	--
	local inRange = 0 
	if lst then
	for i = 1, #lst do 
		
		local bR = lst[i].boundingRadius
		if GetDistanceSqr(average, lst[i].pos) - bR * bR < radius * radius then 
			
			inRange = inRange + 1 
		end
	end
end
	
	--
	local point = Vector(average.x,PurpleBallBitch.pos.y,average.z)
	--
	if lst then
	if inRange == #lst then 
		return point, inRange
	else 
		if lst ~= nil and sTar ~= nil then 
		return GetBestCircularCastPos(spell, sTar, ExcludeFurthest(average, lst))
		end
	end
end
end

GetBestLinearCastPos = function(spell, sTar, list)
	startPos = spell.From.pos or PurpleBallBitch.pos
	local isHero =  list[1].type == PurpleBallBitch.type
	--
	local center = GetBestCircularCastPos(spell, sTar, list)
	local endPos = startPos + (center - startPos):Normalized() * spell.Range
	local MostHit = isHero
	return endPos, MostHit
end

Angle = function(A, B)
    local deltaPos = A - B
    local angle = atan2(deltaPos.x, deltaPos.z) * 180 / MathPI
    if angle < 0 then
        angle = angle + 360
    end
    return angle
end

UpdateMovementHistory =
    function()
    for i = 1, TotalHeroes do
        local unit = HeroBalls(i)
        if not _movementHistory[unit.charName] then
            _movementHistory[unit.charName] = {}
            _movementHistory[unit.charName]['EndPos'] = unit.pathing.endPos
            _movementHistory[unit.charName]['StartPos'] = unit.pathing.endPos
            _movementHistory[unit.charName]['PreviousAngle'] = 0
            _movementHistory[unit.charName]['ChangedAt'] = Timer()
        end

        if
            _movementHistory[unit.charName]['EndPos'].x ~= unit.pathing.endPos.x or _movementHistory[unit.charName]['EndPos'].y ~= unit.pathing.endPos.y or
                _movementHistory[unit.charName]['EndPos'].z ~= unit.pathing.endPos.z
         then
            _movementHistory[unit.charName]['PreviousAngle'] =
                Angle(
                Vector(_movementHistory[unit.charName]['StartPos'].x, _movementHistory[unit.charName]['StartPos'].y, _movementHistory[unit.charName]['StartPos'].z),
                Vector(_movementHistory[unit.charName]['EndPos'].x, _movementHistory[unit.charName]['EndPos'].y, _movementHistory[unit.charName]['EndPos'].z)
            )
            _movementHistory[unit.charName]['EndPos'] = unit.pathing.endPos
            _movementHistory[unit.charName]['StartPos'] = unit.pos
            _movementHistory[unit.charName]['ChangedAt'] = Timer()
        end
    end
end

UpdateDamage = function()
    if cock() - Tard_RangeCount >  1 then
        rlvl = PurpleBallBitch:GetSpellData(_R).level
        qlvl = PurpleBallBitch:GetSpellData(_Q).level
        finaldamage = rlvl == 1 and 90 or rlvl == 2 and 135 or rlvl == 3 and 180
        dmgQ = qlvl == 1 and 50 or qlvl == 2 and 95 or qlvl == 3 and 140 or qlvl == 4 and 185 or qlvl == 5 and 230
        Tard_RangeCount = cock()
    end
end

Saga_Menu = 
function()
	Saga = MenuElement({type = MENU, id = "Syndra", name = "Saga's Syndra: Big Purple Balls", icon = SagaIcon})
	MenuElement({ id = "blank", type = SPACE ,name = "Version 2.3.2"})
	--Combo
    Saga:MenuElement({id = "Combo", name = "Combo", type = MENU})
    Saga.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	Saga.Combo:MenuElement({id = "UseW", name = "W", value = true})
    Saga.Combo:MenuElement({id = "UseE", name = "QE", value = true})
    Saga.Combo:MenuElement({id = "UseER", name = "E", value = true})
    Saga.Combo:MenuElement({id = "UseR", name = "R", value = true})
	Saga.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})

    Saga:MenuElement({id = "Harass", name = "Harass", type = MENU})
	Saga.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
	Saga.Harass:MenuElement({id = "UseW", name = "W", value = true})
	Saga.Harass:MenuElement({id = "harassActive", name = "Harass Key", key = string.byte("C")})
	
	Saga:MenuElement({id = "Clear", name = "Clear", type = MENU})
	Saga.Clear:MenuElement({id = "UseQ", name = "Q", value = true})
	Saga.Clear:MenuElement({id = "QCount", name = "Use Q on X minions", value = 3, min = 1, max = 4, step = 1})
	Saga.Clear:MenuElement({id = "UseW", name = "W", value = true})
	Saga.Clear:MenuElement({id = "WCount", name = "Use W on X minions", value = 3, min = 1, max = 4, step = 1})
	Saga.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
    

    Saga:MenuElement({id = "KillSteal", name = "KillSteal", type = MENU})
    Saga.KillSteal:MenuElement({id = "rKS", name = "R KS on: ", value = false, type = MENU})
    for i = 1, TotalHeroes do
        local hero = _EnemyHeroes[i]
    Saga.KillSteal.rKS:MenuElement({id = hero.charName, name = "Use R on: "..hero.charName, value = true})
    end

	Saga:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	Saga.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
    Saga.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
    
    Saga:MenuElement({id = "Auto", name = "AutoQ", type = MENU})
    Saga.Auto:MenuElement({id = "useAutoQ", name = "Enable", key = string.byte("M"), toggle = true})


    
    Saga:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
    Saga.Drawings:MenuElement({id = "Q", name = "Draw Q range", type = MENU})
    Saga.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Saga.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Saga.Drawings.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})

    Saga.Drawings:MenuElement({id = "E", name = "Draw Long E range", type = MENU})
    Saga.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Saga.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Saga.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})

    Saga.Drawings:MenuElement({id = "W", name = "Draw W range", type = MENU})
    Saga.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Saga.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Saga.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
    
    Saga.Drawings:MenuElement({id = "R", name = "Draw R range", type = MENU})
    Saga.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Saga.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Saga.Drawings.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
end