if myHero.charName ~= "Irelia" then return end
local Irelia = myHero
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local SagaHeroCount = Game.HeroCount()
local SagaTimer = Game.Timer
local Latency = Game.Latency
local ping = Latency() * .001
local Q = { Range = 625}
local W = { Range = 825, Delay = .60 + ping, Speed = 1400, Radius = 100}
local E = { Range = 725, Delay = .75 + ping, Speed = 2000, Radius = 50}
local R = { Range = 1000, Delay = .24 + ping , Speed = 2000, Radius = 160}
local atan2 = math.atan2
local MathPI = math.pi
local _movementHistory = {}
local clock = os.clock
local sHero = Game.Hero
local TEAM_ALLY = Irelia.team
local TEAM_ENEMY = 300 - TEAM_ALLY
local myCounter = 1
local SagaMCount = Game.MinionCount
local SagasBitch = Game.Minion
local shitaround = Game.ObjectCount
local shit = Game.Object
local ItsReadyDumbAss = Game.CanUseSpell
local CastItDumbFuk = Control.CastSpell
local _EnemyHeroes
local TotalHeroes
local LocalCallbackAdd = Callback.Add
local Killsteal
local ignitecast
local eStun = 0
local igniteslot
local ECast = false
local HKITEM = { [ITEM_1] = 49, [ITEM_2] = 50, [ITEM_3] = 51, [ITEM_4] = 52, [ITEM_5] = 53, [ITEM_6] = 54 }
local visionTick = 0
local wClock = 0
local settime = 0
local eClock = 0
local charging = false
local _OnVision = {}
local LocalGameTurretCount 	= Game.TurretCount;
local LocalGameTurret = Game.Turret;
local sqrt = math.sqrt  	
local abs = math.abs 
local deg = math.deg 
local acos = math.acos 
local e1clock = 0
local stonecoldstunner = {}
local Espot,Espot2, EUnit
local spaceE = 0



local isEvading = ExtLibEvade and ExtLibEvade.Evading
	local validTarget,
		GetDistanceSqr,
        GetDistance,
        GetImmobileTime,
        GetTargetMS,
        GetTarget,
        GetPathNodes,
        GetItemSlotCustom,
        PredictUnitPosition,
        UnitMovementBounds,
        GetRecallingData,
        PredictReactionTime,
        GetSpellInterceptTime,
        CanTarget,
        Angle,
        UpdateMovementHistory,
        GetHitchance,
        GetOrbMode,
        SagaOrb,
        Sagacombo,
        Sagaharass,
        SagalastHit,
        SagalaneClear,
        SagaSDK,
        SagaSDKCombo,
        SagaSDKHarass,
        SagaSDKJungleClear,
        SagaSDKLaneClear,
        SagaSDKLastHit,
        SagaSDKSelector,
        SagaGOScombo,
        SagaGOSharass,
        SagaGOSlastHit,
        SagaGOSlaneClear,
        SagaSDKModes,
        SagaSDKFlee,
        minionCollision,
        VectorPointProjectionOnLineSegment,
        SagaSDKMagicDamage,
        SagaSDKPhysicalDamage,
        Combo,
        OnVision,
        onVisionF,
        GetIgnite,
        SagaGOSjungleClear,
        SagaGOScanmove,
        SagaGOScanattack,
        SagajungleClear,
        Sagacanmove,
        Sagacanattack,
        IsFacing



    local Saga_Menu, Saga


    local sqrt = math.sqrt
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

GetDistanceSqr = function(p1, p2)
		p2 = p2 or Irelia
		p1 = p1.pos or p1
		p2 = p2.pos or p2
		
	
		local dx, dz = p1.x - p2.x, p1.z - p2.z 
		return dx * dx + dz * dz
	end

GetEnemyHeroes = function()
        _EnemyHeroes = {}
        for i = 1, Game.HeroCount() do
            local unit = Game.Hero(i)
            if unit.team == TEAM_ENEMY  then
                _EnemyHeroes[myCounter] = unit
                myCounter = myCounter + 1
            end
        end
        myCounter = 1
        return #_EnemyHeroes
    end

	GetDistance = function(p1, p2)
		
		return sqrt(GetDistanceSqr(p1, p2))
    end
    


validTarget = function(unit)
        if unit and unit.isEnemy and unit.valid and unit.isTargetable and not unit.dead and not unit.isImmortal and not (GotBuff(unit, 'FioraW') == 1) and
        not (GotBuff(unit, 'XinZhaoRRangedImmunity') == 1 and unit.distance < 450) and unit.visible then
            return true
        else 
            return false
        end
    end

    IsFacing = function(unit)
	    local V = Vector((unit.pos - myHero.pos))
	    local D = Vector(unit.dir)
	    local Angle = 180 - deg(acos(V*D/(V:Len()*D:Len())))
	    if abs(Angle) < 80 then 
	        return true  
	    end
	    return false
	end

GetImmobileTime = function(unit)
    local duration = 0
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if
            buff.count > 0 and buff.duration > duration and
                (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39)
         then
            duration = buff.duration
        end
    end
    return duration
end

GetTargetMS = function(target)
    local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
    return ms
end

GetTarget = function(range)

	if SagaOrb == 1 then
		if Irelia.ap > Irelia.totalDamage then
			return EOW:GetTarget(range, EOW.ap_dec, Irelia.pos)
		else
			return EOW:GetTarget(range, EOW.ad_dec, Irelia.pos)
		end
	elseif SagaOrb == 2 and SagaSDKSelector then
		if Irelia.ap > Irelia.totalDamage then
			return SagaSDKSelector:GetTarget(range, SagaSDKMagicDamage)
		else
			return SagaSDKSelector:GetTarget(range, SagaSDKPhysicalDamage)
		end
	elseif _G.GOS then
		if Irelia.ap > Irelia.totalDamage then
			return GOS:GetTarget(range, "AP")
		else
			return GOS:GetTarget(range, "AD")
        end
    elseif _G.gsoSDK then
		return _G.gsoSDK.TS:GetTarget()
	end
end

GetPathNodes = function(unit)
    local nodes = {}
    nodes[myCounter] = unit.pos
    if unit.pathing.hasMovePath then
        for i = unit.pathing.pathIndex, unit.pathing.pathCount do
            local path = unit:GetPath(i)
            myCounter = myCounter + 1
            nodes[myCounter] = path
        end
    end
    myCounter = 1
    return nodes, #nodes
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

GetIgnite = function()
    if myHero:GetSpellData(SUMMONER_2).name:lower() == "summonerdot" then
        igniteslot = 5
        ignitecast = HK_SUMMONER_2

    elseif myHero:GetSpellData(SUMMONER_1).name:lower() == "summonerdot" then
        igniteslot = 4
        ignitecast = HK_SUMMONER_1
    else
        igniteslot = nil
        ignitecast = nil
    end


    
end

minionCollision = function(target, me, position)
    local targemyCounter = 0
    for i = SagaMCount(), 1, -1 do 
        local minion = SagasBitch(i)
        if minion.isTargetable and minion.team == TEAM_ENEMY and minion.dead == false then
            local linesegment, line, isOnSegment = VectorPointProjectionOnLineSegment(me, position, minion.pos)
            if linesegment and isOnSegment and (GetDistanceSqr(minion.pos, linesegment) <= (minion.boundingRadius + W.Width) * (minion.boundingRadius + W.Width)) then
                targemyCounter = targemyCounter + 1
            end
        end
    end
    return targemyCounter
end
PredictUnitPosition = function(unit, delay)
    local predictedPosition = unit.pos
    local timeRemaining = delay
    local pathNodes = GetPathNodes(unit)
    for i = 1, #pathNodes - 1 do
        local nodeDistance = sqrt(GetDistanceSqr(pathNodes[i], pathNodes[i + 1]))
        local targetMs = GetTargetMS(unit)
        local nodeTraversalTime = nodeDistance / targetMs
        if timeRemaining > nodeTraversalTime then
            --This node of the path will be completed before the delay has finished. Move on to the next node if one remains
            timeRemaining = timeRemaining - nodeTraversalTime
            predictedPosition = pathNodes[i + 1]
        else
            local directionVector = (pathNodes[i + 1] - pathNodes[i]):Normalized()
            predictedPosition = pathNodes[i] + directionVector * targetMs * timeRemaining
            break
        end
    end
    return predictedPosition
end

UnitMovementBounds = function(unit, delay, reactionTime)
    local startPosition = PredictUnitPosition(unit, delay)
    local radius = 0
    local deltaDelay = delay - reactionTime - GetImmobileTime(unit)
    if (deltaDelay > 0) then
        radius = GetTargetMS(unit) * deltaDelay
    end
    return startPosition, radius
end

GetRecallingData = function(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.name == 'recall' and buff.duration > 0 then
            return true, SagaTimer() - buff.startTime
        end
    end
    return false
end

PredictReactionTime = function(unit, minimumReactionTime)
    local reactionTime = minimumReactionTime
    --If the target is auto attacking increase their reaction time by .15s - If using a skill use the remaining windup time
    if unit.activeSpell and unit.activeSpell.valid then
        local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - SagaTimer()
        if windupRemaining > 0 then
            reactionTime = windupRemaining
        end
    end
    --If the target is recalling and has been for over .25s then increase their reaction time by .25s
    local isRecalling, recallDuration = GetRecallingData(unit)
    if isRecalling and recallDuration > .25 then
        reactionTime = .25
    end
    return reactionTime
end

GetSpellInterceptTime = function(startPos, endPos, delay, speed)
    local interceptTime = Latency() / 2000 + delay + sqrt(GetDistanceSqr(startPos, endPos)) / speed
    return interceptTime
end

CanTarget = function(target)
    return target.team == TEAM_ENEMY and target.alive and target.visible and target.isTargetable
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
        local unit = sHero(i)
        if not _movementHistory[unit.charName] then
            _movementHistory[unit.charName] = {}
            _movementHistory[unit.charName]['EndPos'] = unit.pathing.endPos
            _movementHistory[unit.charName]['StartPos'] = unit.pathing.endPos
            _movementHistory[unit.charName]['PreviousAngle'] = 0
            _movementHistory[unit.charName]['ChangedAt'] = SagaTimer()
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
            _movementHistory[unit.charName]['ChangedAt'] = SagaTimer()
        end
    end
end


GetHitchance = function(source, target, range, delay, speed, radius)
    local hitChance = 1
    local aimPosition = PredictUnitPosition(target, delay + sqrt(GetDistanceSqr(source, target.pos)) / speed)
    local interceptTime = GetSpellInterceptTime(source, aimPosition, delay, speed)
    local reactionTime = PredictReactionTime(target, .1)
    --If they just now changed their path then assume they will keep it for at least a short while... slightly higher chance
    if _movementHistory and _movementHistory[target.charName] and SagaTimer() - _movementHistory[target.charName]['ChangedAt'] < .25 then
        hitChance = 2
    end
    --If they are standing still give a higher accuracy because they have to take actions to react to it
    if not target.pathing or not target.pathing.hasMovePath then
        hitChance = 2
    end
    local origin, movementRadius = UnitMovementBounds(target, interceptTime, reactionTime)
    --Our spell is so wide or the target so slow or their reaction time is such that the spell will be nearly impossible to avoid
    if movementRadius - target.boundingRadius <= radius / 2 then
        origin, movementRadius = UnitMovementBounds(target, interceptTime, 0)
        if movementRadius - target.boundingRadius <= radius / 2 then
            hitChance = 4
        else
            hitChance = 3
        end
    end
    --If they are casting a spell then the accuracy will be fairly high. if the windup is longer than our delay then it's quite likely to hit.
    --Ideally we would predict where they will go AFTER the spell finishes but that's beyond the scope of this prediction
    if target.activeSpell and target.activeSpell.valid then
        if target.activeSpell.startTime + target.activeSpell.windup - SagaTimer() >= delay then
            hitChance = 5
        else
            hitChance = 3
        end
    end
    --Check for out of range
    
    return hitChance, aimPosition
end

GetEnemiesinRangeCount = function(target,range)
	local inRadius =  {}
	
    for i = 1, TotalHeroes do
		local unit = _EnemyHeroes[i]
		if unit.pos ~= nil and validTarget(unit) then
			if  GetDistance(target.pos, unit.pos) <= range then
								
				inRadius[myCounter] = unit
                myCounter = myCounter + 1
            end
        end
	end
		myCounter = 1
    return #inRadius, inRadius
end

GetEnemiesinRangeCountQ = function(target,range)
    local closest = 9999
    local cMinion
		for i = 1, SagaMCount() do 
            local minion = SagasBitch(i)
            if minion and not minion.dead and minion.visible and minion.isTargetable then
                if GetDistanceSqr(myHero.pos, target.pos) < 625 * 625 then 
                    closest = GetDistanceSqr(myHero.pos, target.pos)
                    cMinion = minion
                end
                if GetDistanceSqr(minion.pos, target.pos) < 625 * 625 and GetDistanceSqr(minion.pos, target.pos) < 625 * 625 and GetDistanceSqr(myHero.pos, minion.pos) < closest * closest and GetDamage(HK_Q, minion) > minion.health then
                    closest = GetDistanceSqr(minion.pos, target.pos)
                    cMinion = minion
                end
                if GetDistanceSqr(minion.pos, target.pos) < 625 * 625 and GetDistanceSqr(minion.pos, target.pos) < 625 * 625 and GetDistanceSqr(myHero.pos, minion.pos) < closest * closest and GotBuff(minion, "ireliamark") == 1 then
                    closest = GetDistanceSqr(minion.pos, target.pos)
                    cMinion = minion
                end
            end
            
        end
        return cMinion
        

end

checkItems = function()
	local itemss = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			itemss[id] = slot
		end
	end
	return itemss
end

SIGroup = function(target)
	local items = checkItems()
	local Bilge = items[3144] or items[3153]
	if target then
		if Bilge  and myHero:GetSpellData(Bilge).currentCd == 0  and myHero.pos:DistanceTo(target.pos) < 550 then
			Control.CastSpell(HKITEM[Bilge], target.pos)
		end
		
		
		local Tiamat = items[3077] or items[3748] or items[3074]
		if Tiamat and myHero:GetSpellData(Tiamat).currentCd == 0  and myHero.pos:DistanceTo(target.pos) < 400 and myHero.attackData.state == 2 then
			Control.CastSpell(HKITEM[Tiamat], target.pos)
		end

		local YG = items[3142]
		if YG and myHero:GetSpellData(YG).currentCd == 0  and myHero.pos:DistanceTo(target.pos) < 1575 then
			Control.CastSpell(HKITEM[YG])
		end
		
		
		if ignitecast and igniteslot then
			if target and Game.CanUseSpell(igniteslot) == 0 and GetDistanceSqr(myHero, target) < 450 * 450 and 25 >= (100 * target.health / target.maxHealth) then
				Control.CastSpell(ignitecast, target)
			end
		end

	end

end



LocalCallbackAdd("Load", function()
TotalHeroes = GetEnemyHeroes()
GetIgnite()
Saga_Menu()


if _G.EOWLoaded then
     SagaOrb = 1
elseif _G.SDK and _G.SDK.Orbwalker then
     SagaOrb = 2
elseif _G.GOS then
     SagaOrb = 3
elseif _G.gsoSDK then
    SagaOrb = 4
end

if  SagaOrb == 1 then
    local mode = EOW:Mode()

	Sagacombo = mode == 1
	Sagaharass = mode == 2
	SagalastHit = mode == 3
	SagalaneClear = mode == 4
	SagajungleClear = mode == 4

	Sagacanmove = EOW:CanMove()
    Sagacanattack = EOW:CanAttack()
elseif  SagaOrb == 2 then
     SagaSDK = SDK.Orbwalker
     SagaSDKCombo = SDK.ORBWALKER_MODE_COMBO
     SagaSDKHarass = SDK.ORBWALKER_MODE_HARASS
     SagaSDKJungleClear = SDK.ORBWALKER_MODE_JUNGLECLEAR
     SagaSDKJungleClear = SDK.ORBWALKER_MODE_JUNGLECLEAR
     SagaSDKLaneClear = SDK.ORBWALKER_MODE_LANECLEAR
     SagaSDKLastHit = SDK.ORBWALKER_MODE_LASTHIT
     SagaSDKFlee = SDK.ORBWALKER_MODE_FLEE
     SagaSDKSelector = SDK.TargetSelector
     SagaSDKMagicDamage = _G.SDK.DAMAGE_TYPE_MAGICAL
     SagaSDKPhysicalDamage = _G.SDK.DAMAGE_TYPE_PHYSICAL
elseif  SagaOrb == 3 then
    

	SagaGOScanmove = GOS:CanMove()
    SagaGOScanattack = GOS:CanAttack()
end
end)







DisableMovement = function(bool)

	if SagaOrb == 2 then
		SagaSDK:SetMovement(not bool)
	elseif SagaOrb == 1 then
		EOW:SetMovements(not bool)
	elseif SagaOrb == 3 then
		GOS.BlockMovement = bool
	end
end

DisableAttacks = function(bool)

	if SagaOrb == 2 then
		SagaSDK:SetAttack(not bool)
	elseif SagaOrb == 1 then
		EOW:SetAttacks(not bool)
	elseif SagaOrb == 3 then
		GOS.BlockAttack = bool
	end
end


GetOrbMode = function()
    
    if SagaOrb == 1 then
        if Sagacombo == 1 then
            return 'Combo'
        elseif Sagaharass == 2 then
            return 'Harass'
        elseif SagalastHit == 3 then
            return 'Lasthit'
        elseif SagalaneClear == 4 then
            return 'Clear'
        end
    elseif SagaOrb == 2 then
        SagaSDKModes = SDK.Orbwalker.Modes
        if SagaSDKModes[SagaSDKCombo] then
            return 'Combo'
        elseif SagaSDKModes[SagaSDKHarass] then
            return 'Harass'
        elseif SagaSDKModes[SagaSDKLaneClear] or SagaSDKModes[SagaSDKJungleClear] then
            return 'Clear'
        elseif SagaSDKModes[SagaSDKLastHit] then
            return 'Lasthit'
        elseif SagaSDKModes[SagaSDKFlee] then
            return 'Flee'
        end
    elseif SagaOrb == 3 then
        return GOS:GetMode()
    elseif SagaOrb == 4 then
        return _G.gsoSDK.Orbwalker:GetMode()
    end
end

LocalCallbackAdd("Tick", function()
    
    if Game.Timer() > Saga.Rate.champion:Value() and #_EnemyHeroes == 0 then
        TotalHeroes = GetEnemyHeroes()
    end
    if #_EnemyHeroes == 0 then return end

    if isEvading then return end
    
    UpdateMovementHistory()
    
    Killsteal()
    
   
    if GetOrbMode() == 'Combo' then
        
        Combo()
    end

    if GetOrbMode() == 'Harass' then
        
        Harass()
    end

    if GetOrbMode() == 'Clear' then
        
        Laneclear()
    end

    if GetOrbMode() == 'Lasthit' then
        
        LastHit()
    end

    if GetOrbMode() == 'Flee' then
        Flee()
    end


    end)

    LocalCallbackAdd("Draw", function()
        
        if Saga.Drawings.Q.Enabled:Value() then 
            Draw.Circle(myHero.pos, Q.Range, 0, Saga.Drawings.Q.Color:Value())
        end
        
        if Saga.Drawings.W.Enabled:Value() then 
            Draw.Circle(myHero.pos, W.Range, 0, Saga.Drawings.W.Color:Value())
        end

        if Saga.Drawings.E.Enabled:Value() then 
            Draw.Circle(myHero.pos, E.Range - 150, 0, Saga.Drawings.E.Color:Value())
        end

        if Saga.Drawings.R.Enabled:Value() then 
            Draw.Circle(myHero.pos, R.Range, 0, Saga.Drawings.R.Color:Value())
        end

        
        local unit = GetTarget(E.Range)
        if unit and Game.CanUseSpell(2) == 0 and GetDistanceSqr(unit) < E.Range * E.Range then
            local  aim = GetPred(unit,math.huge,0.25+ Game.Latency()/1000)
                Espot = unit.pos + (myHero.pos - unit.pos): Normalized() * 875
            
                Espot2 = aim + (myHero.pos - aim): Normalized() * -150
            if  Espot2 and Espot then
                if myHero:GetSpellData(_E).toggleState == 1 then
                Draw.Circle(Espot, 50, 4, Saga.Drawings.R.Color:Value())
                Draw.Circle(Espot2, 50, 4, Saga.Drawings.R.Color:Value())
                Draw.Line(Espot:To2D().x, Espot:To2D().y, Espot2:To2D().x, Espot2:To2D().y, E.Width, Draw.Color(255, 155, 105, 240))
                end

                if myHero:GetSpellData(_E).toggleState == 0 then
                    Draw.Circle(Espot2, 50, 4, Saga.Drawings.R.Color:Value())
                end
            end
            end


        for i= 1, TotalHeroes do
            local hero = _EnemyHeroes[i]
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = Game.CanUseSpell(0) == 0 and GetDamage(HK_Q,hero) or 0
				local WDamage = Game.CanUseSpell(1) == 0 and GetDamage(HK_W,hero) or 0
				local EDamage = Game.CanUseSpell(2) == 0 and GetDamage(HK_E,hero) or 0
				local RDamage = Game.CanUseSpell(3) == 0 and GetDamage(HK_R,hero) or 0
                local damage = QDamage + WDamage + RDamage + EDamage
				if damage > hero.health then
					Draw.Text("KILL NOW", 30, hero.pos2D.x - 50, hero.pos2D.y + 50,Draw.Color(200, 255, 87, 51))				
                end
				end
				end
    
    end)

    CastSpell = function(spell,pos,range,delay)
    
        local range = range or math.huge
        local delay = delay or 250
        local ticker = GetTickCount()
    
        if castSpell.state == 0 and GetDistance(myHero.pos, pos) < range and ticker - castSpell.casting > delay + Latency() then
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

CastItBlindFuck = function(spell, pos, range, delay)
	local range = range or math.huge
	local delay = delay or 250
	local ticker = GetTickCount()

	if castSpell.state == 0 and GetDistance(Irelia.pos, pos) < range and ticker - castSpell.casting > delay + Latency() then
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
			end,ping)
		end
		if ticker - castSpell.casting > Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end


function GetDistance2D(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local _OnWaypoint = {}
function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		-- print("OnWayPoint:"..unit.charName.." | "..math.floor(Game.Timer()))
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
			DelayAction(function()
				local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
					-- print("OnDash: "..unit.charName)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end

function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

function GetPred(unit,speed,delay)
	local speed = speed or math.huge
	local delay = delay or 0.25
	local unitSpeed = unit.ms
	if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
	if OnVision(unit).state == false then
		local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
		local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unitPos)/speed)))
		if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
		return predPos
	else
		if unitSpeed > unit.ms then
			local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unit.pos)/speed)))
			if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
			return predPos
		elseif IsImmobileTarget(unit) then
			return unit.pos
		else
			return unit:GetPrediction(speed,delay)
		end
	end
end

GetItemSlotCustom= function(unit, id)
    for i = ITEM_1, ITEM_7 do
        if unit:GetItemData(i).itemID == id then
            return i
        end
    end
    return 0
end

IsEvading = function()
if ExtLibEvade and ExtLibEvade.Evading then
    
    return true
end
end

function CalcPhysicalDamage(source, target, amount)
    local ArmorPenPercent = source.armorPenPercent
    local ArmorPenFlat = (0.4 + target.levelData.lvl / 30) * source.armorPen
    local BonusArmorPen = source.bonusArmorPenPercent
  
    if source.type == Obj_AI_Minion then
      ArmorPenPercent = 1
      ArmorPenFlat = 0
      BonusArmorPen = 1
    elseif source.type == Obj_AI_Turret then
      ArmorPenFlat = 0
      BonusArmorPen = 1
      if source.charName:find("3") or source.charName:find("4") then
        ArmorPenPercent = 0.25
      else
        ArmorPenPercent = 0.7
      end
    end
  
    if source.type == Obj_AI_Turret then
      if target.type == Obj_AI_Minion then
        amount = amount * 1.25
        if string.ends(target.charName, "MinionSiege") then
          amount = amount * 0.7
        end
        return amount
      end
    end
  
    local armor = target.armor
    local bonusArmor = target.bonusArmor
    local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)
  
    if armor < 0 then
      value = 2 - 100 / (100 - armor)
    elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
      value = 1
    end
    return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 1)))
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

  function DamageReductionMod(source,target,amount,DamageType)
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
    if GetItemSlotCustom(target, 1054) > 0 then
		amount = amount - 8
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
		if (GetItemSlotCustom(source, 3036) > 0 or GetItemSlotCustom(source, 3034) > 0) and source.maxHealth < target.maxHealth and damageType == 1 then
		  amount = amount * (1 + math.min(target.maxHealth - source.maxHealth, 500) / 50 * (GetItemSlotCustom(source, 3036) > 0 and 0.015 or 0.01))
		end
	  end
	end
	return amount
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

    function UnderTurret(pos)

        for i = 1, LocalGameTurretCount() do
            local turret = LocalGameTurret(i);
            if turret then
                if turret.valid and turret.health > 0 and turret.isEnemy then
                    local turretPos = turret.pos
                    if GetDistance(pos, turretPos) <= 900 then 
                        return true
                    end
                end
            end
        end
        return false
    end
    Priority = function(charName)
        local p1 = {"Alistar", "Amumu", "Blitzcrank", "Braum", "Cho'Gath", "Dr. Mundo", "Garen", "Gnar", "Maokai", "Hecarim", "Jarvan IV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "TahmKench", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac", "Poppy", "Ornn"}
        local p2 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gragas", "Irelia", "Jax", "Lee Sin", "Morgana", "Janna", "Nocturne", "Pantheon", "Rengar", "Rumble", "Swain", "Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai", "Bard", "Nami", "Sona", "Camille", "Kled", "Ivern", "Illaoi"}
        local p3 = {"Akali", "Diana", "Ekko", "FiddleSticks", "Fiora", "Gangplank", "Fizz", "Heimerdinger", "Jayce", "Kassadin", "Kayle", "Kha'Zix", "Lissandra", "Mordekaiser", "Nidalee", "Riven", "Shaco", "Vladimir", "Yasuo", "Zilean", "Zyra", "Ryze", "Kayn", "Rakan", "Pyke"}
        local p4 = {"Ahri", "Anivia", "Annie", "Ashe", "Azir", "Brand", "Caitlyn", "Cassiopeia", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "Karma", "Karthus", "Irelia", "Kennen", "KogMaw", "Kindred", "Leblanc", "Lucian", "Lux", "Malzahar", "MasterYi", "MissFortune", "Orianna", "Quinn", "Sivir", "Syndra", "Talon", "Teemo", "Tristana", "TwistedFate", "Twitch", "Varus", "Vayne", "Veigar", "Velkoz", "Viktor", "Xerath", "Zed", "Ziggs", "Jhin", "Soraka", "Zoe", "Xayah","Kaisa", "Taliyah", "AurelionSol"}
        if table.contains(p1, charName) then return 1 end
        if table.contains(p2, charName) then return 1.25 end
        if table.contains(p3, charName) then return 1.75 end
        return table.contains(p4, charName) and 2.25 or 1
      end

	GetTarget2 = function(range,t,pos)
		local t = t or "AD"
		local pos = pos or myHero.pos
		local target = {}
			for i = 1, TotalHeroes do
				local hero = _EnemyHeroes[i]
				if hero.isEnemy and not hero.dead then
					OnVision(hero)
				end
				if hero.isEnemy and hero.valid and not hero.dead and (OnVision(hero).state == true or (OnVision(hero).state == false and GetTickCount() - OnVision(hero).tick < 650)) and hero.isTargetable and not hero.isImmortal and not (GotBuff(hero, 'FioraW') == 1) and
				not (GotBuff(hero, 'XinZhaoRRangedImmunity') == 1 and hero.distance < 450) then
					local heroPos = hero.pos
					if OnVision(hero).state == false then heroPos = hero.pos + Vector(hero.pos,hero.posTo):Normalized() * ((GetTickCount() - OnVision(hero).tick)/1000 * hero.ms) end
					if GetDistance(pos,heroPos) <= range then
						if t == "AD" then
							target[(CalcPhysicalDamage(myHero,hero,100) / hero.health)*Priority(hero.charName)] = hero
						elseif t == "AP" then
							target[(CalcMagicalDamage(myHero,hero,100) / hero.health)*Priority(hero.charName)] = hero
						elseif t == "HYB" then
							target[((CalcMagicalDamage(myHero,hero,50) + CalcPhysicalDamage(myHero,hero,50))/ hero.health)*Priority(hero.charName)] = hero
						end
					end
				end
			end
			local bT = 0
			for d,v in pairs(target) do
				if d > bT then
					bT = d
				end
			end
			
			if bT ~= 0 then return target[bT]  end
			
		end

    


CastQ =  function(unit)
    if unit and Game.CanUseSpell(0) == 0 and GetDistanceSqr(unit) < (Q.Range * Q.Range) then
		Control.CastSpell(HK_Q, unit)
	end
end

CastW = function(target)
    if target and Game.CanUseSpell(1) == 0 and GetDistanceSqr(target) < W.Range  * W.Range then
        local hitchance, aim = GetHitchance(Irelia, target , W.Range, W.Delay, W.Speed, W.Radius)
        if not charging and GotBuff(myHero, "ireliawdefense") == 0 then
            Control.KeyDown(HK_W)
            wClock = clock()
            settime = clock()
            charging = true
        end
        if GotBuff(myHero, "ireliawdefense") == 1 and (target.pos:DistanceTo() > 600) then
            CastSpell(HK_W, aim)
            charging = false
        elseif GotBuff(myHero, "ireliawdefense") == 1 and clock() - wClock >= .5 and target.pos:DistanceTo() < 825then
                CastSpell(HK_W,aim)
                charging = false
        end
        
        
    end
    if clock() - wClock >= 1.5 then
    Control.KeyUp(HK_W)
    charging = false
    end 
end

function CastETarget(unit)
    local aim
    if unit and Game.CanUseSpell(2) == 0 and GetDistanceSqr(unit) < E.Range * E.Range then
    aim = GetPred(unit,math.huge,0.25+ Game.Latency()/1000)
        
        
        
    EUnit = unit
    
        
    if myHero.attackData.state ~= 2 and myHero:GetSpellData(_E).name == "IreliaE" then
        if  myHero:GetSpellData(_E).name == "IreliaE2" then  return end
        Espot = myHero.pos + ( unit.pos - myHero.pos): Normalized() * - E.Range
        Control.CastSpell(HK_E, Espot)
        spaceE = os.clock()
        
        
        
    end
    
    end
    if myHero.attackData.state ~= 2 and myHero:GetSpellData(_E).name == "IreliaE2" then
        Espot2 = unit.pos + (myHero.pos - unit.pos): Normalized() * -150
        DisableMovement(true)
        CastSpell(HK_E, Espot2, E.Range, .25)
        DisableMovement(false)
        eStun = os.clock()
    --[[if myHero:GetSpellData(_E).name == "IreliaE2" then
        --local hitchance2, aim2 = GetHitchance(Irelia, unit , E.Range, E.Delay, E.Speed, E.Radius)
        --Espot2 = aim + (myHero.pos - aim): Normalized() * -150
        Espot2 = unit.pos
        CastSpell(HK_E, Espot2, E.Range, E.Delay * 1000)
        --ECast = false
        eClock = clock()
    end]]--
    end
end







function CastR(unit)
	if Game.CanUseSpell(3) == 0 and GetDistanceSqr(unit) < R.Range * R.Range and not myHero.pathing.isDashing then
        local hitchance, aim = GetHitchance(Irelia,  unit, R.Range, R.Delay, R.Speed, R.Radius)
        if aim:To2D().onScreen and hitchance >= 2 then
            CastSpell(HK_R, unit, R.Range, R.Delay * 1000)
        end
	end
end

function GetDamage(spell, unit)
    local damage = 0
    local AD = myHero.totalDamage
	local AP = myHero.ap
	


    if spell == HK_Q then
		if Game.CanUseSpell(0) == 0 then
			damage = CalcPhysicalDamage(Irelia ,unit, (Irelia:GetSpellData(_Q).level * 20 - 10) + AD * 0.7)
        end
    elseif spell == HK_W then
        damage = CalcPhysicalDamage(Irelia, unit, (Irelia:GetSpellData(_W).level * 20 - 10) + (AD * 0.6) + (AP * 0.4))

    elseif spell == HK_E then
        if Game.CanUseSpell(2) == 0 then
            damage = CalcMagicalDamage(Irelia,unit, (Irelia:GetSpellData(_E).level * 40 + 40) + (AP * 0.8))
        end
    elseif spell == HK_R then
        if Game.CanUseSpell(3) == 0 then
            damage = CalcMagicalDamage(Irelia, unit, (Irelia:GetSpellData(_R).level * 100 + 25) + (AP * 0.7))
        end

    end
    return damage
end

GetFullDamage = function(hero)
    local QDamage = Game.CanUseSpell(0) == 0 and GetDamage(HK_Q,hero) or 0
	local WDamage = Game.CanUseSpell(1) == 0 and GetDamage(HK_W,hero) or 0
	local EDamage = Game.CanUseSpell(2) == 0 and GetDamage(HK_E,hero) or 0
    local RDamage = Game.CanUseSpell(3) == 0 and GetDamage(HK_R,hero) or 0
    local damage = QDamage + WDamage + RDamage + EDamage
    return damage
end






Combo =  function()
    local target, targetW, targetE, targetR, targetExt
    
    if Saga.TS.cTS:Value() then
        targetE = GetTarget2(E.Range)
    else
        targetE = GetTarget(E.Range)
    end

    if targetE and Saga.Combo.UseE:Value() and Game.CanUseSpell(0) == 0 then 
        CastETarget(targetE)

    end

    if Saga.TS.cTS:Value() then
        targetExt = GetTarget2(1250)
    else
        targetExt = GetTarget(1250)
    end
    
    if targetExt and Saga.Combo.UseQExt:Value() then
    SIGroup(targetExt)
    local targetExtend = GetEnemiesinRangeCountQ(targetExt, 625)
    if targetExtend then
        if targetExt.pos:DistanceTo() >= 625 and GetDistance(targetExt.pos, targetExtend.pos) <= 625*625 then
            CastQ(targetExtend)
        end
    end
    end

    if Saga.TS.cTS:Value() then
        target = GetTarget2(625)
    else
        target = GetTarget(625)
    end


    if target and Saga.Combo.UseQ:Value() then
        if Game.CanUseSpell(2) ~= 0 and GotBuff(target, "ireliamark") == 1 then
            CastQ(target)
        elseif os.clock() - eStun > 1 and Game.CanUseSpell(2) ~= 0 and GotBuff(target, "ireliamark") == 0 and myHero:GetSpellData(_E).name == "IreliaE" then
            CastQ(target)
        end
    end

    ----------------------
    
    if Saga.TS.cTS:Value() then
        targetW = GetTarget2(Q.Range)
    else
        targetW = GetTarget(Q.Range)
    end
    if targetW and Saga.Combo.UseW:Value() then
        if Game.CanUseSpell(0) ~= 0 and Game.CanUseSpell(2) ~= 0 and myHero:GetSpellData(_E).name == "IreliaE" then
        CastW(targetW) end
    end

    
    ---------------------------


    

    -----------------------------------------------
    
    if Saga.TS.cTS:Value() then
        targetR = GetTarget2(R.Range)
    else
        targetR = GetTarget(R.Range)
    end

    if targetR and Saga.Combo.UseR:Value() and not myHero.pathing.isDashing then 
        local number, list = GetEnemiesinRangeCount(targetR, 600)
        local hitchance, aim = GetHitchance(Irelia,  targetR, R.Range, 1.5+ping, 1000, 100)
        if number >= Saga.Misc.RCount:Value() and hitchance >= 2 or GetFullDamage(targetR) > targetR.health and myHero:GetSpellData(_E).name == "IreliaE" and hitchance >= 2 then
            CastR(targetR)
        end
    end
    if ignitecast and igniteslot then
        if targetE and Game.CanUseSpell(igniteslot) == 0 and GetDistanceSqr(Irelia, target) < 450 * 450 and 25 >= (100 * targetE.health / targetE.maxHealth) then
            Control.CastSpell(ignitecast, targetE)
        end
    end 

end


function Harass()
	local target = GetTarget(Q.Range)
	if target then
		if Saga.Harass.UseQ:Value() then
			if Game.CanUseSpell(2) ~= 0 and GotBuff(target, "ireliamark") == 1 and myHero:GetSpellData(_E).name == "IreliaE" then
                CastQ(target)
            elseif Game.CanUseSpell(2) ~= 0 and GotBuff(target, "ireliamark") == 0 and myHero:GetSpellData(_E).name == "IreliaE" and clock() - eClock >= 1 then
                CastQ(target)
            end
		end

		if Saga.Harass.UseW:Value() then
			CastW(target)
        end

        if Saga.Harass.UseE:Value() and not myHero.pathing.isDashing then
			CastETarget(target)
        end

	end
end

function Laneclear()
    for i = 0, SagaMCount() do
        local minion = SagasBitch(i)
		if minion and minion.isTargetable and minion.team == TEAM_ENEMY and minion.dead == false then

			if Saga.Clear.UseQ:Value() and GetDamage(HK_Q, minion) > minion.health and not UnderTurret(minion.pos) then 
				CastQ(minion) 
			end

			if Saga.Clear.UseW:Value() then
				CastW(minion) 
			end
		end
	end
end

function LastHit()
    for i = 0, SagaMCount() do
        local minion = SagasBitch(i)
		if minion and minion.isTargetable and minion.team == TEAM_ENEMY and minion.dead == false then
			if Saga.Lasthit.UseQ then
				if minion.health <= GetDamage(HK_Q, minion) then
					CastQ(minion)
				end
			end
		end
	end
end



Killsteal = function ()
        local rActive = myHero.activeSpell.name == "IreliaR"
            for i = 1, TotalHeroes do
                local enemy = _EnemyHeroes[i]
            --Q
            if  Game.CanUseSpell(0) == 0 and Saga.Killsteal.qKS:Value() then
                if enemy and validTarget(enemy) and enemy.health <= GetDamage(HK_Q, enemy) then
					CastQ(enemy)
				end
			end
			-- W
			if  Game.CanUseSpell(1) == 0 and Saga.Killsteal.wKS:Value() then
				if enemy and validTarget(enemy) and enemy.health <= GetDamage(HK_W, enemy) then
                    CastW(enemy)
				end
			end
			
        end
end

function Flee()
    local unit
	if Saga.Escape.UseQ:Value() then
		if GetDistance(mousePos) > Q.Range then
            unit = Irelia.pos + (mousePos - Irelia.pos):Normalized() * Q.Range
        else
            unit = Irelia.pos + (mousePos - Irelia.pos)
        end
        if Game.CanUseSpell(2) == 0 then
            for i = 1, SagaMCount() do 
                local minion = SagasBitch(i)
                if minion and unit and not minion.dead and minion.visible and minion.isTargetable and minion.isEnemy then
                    if GetDistance(minion.pos, unit) < 650 and GetDamage(HK_Q, minion) > minion.health then
                        Control.CastSpell(HK_Q, minion.pos)
                    end
                end
            end
            
		end
	end
end

Saga_Menu = 
function()
	Saga = MenuElement({type = MENU, id = "Irelia", name = "Saga's Irelia: Please Don't Nerf Me", icon = AIOIcon})
	MenuElement({ id = "blank", type = SPACE ,name = "Version 2.7.5"})
	--Combo
	Saga:MenuElement({id = "Combo", name = "Combo", type = MENU})
    Saga.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
    Saga.Combo:MenuElement({id = "UseQExt", name = "Q To Minion Gapclose", value = true})
	Saga.Combo:MenuElement({id = "UseW", name = "W", value = true})
	Saga.Combo:MenuElement({id = "UseE", name = "E", value = true})
	Saga.Combo:MenuElement({id = "UseR", name = "R", value = true})

	Saga:MenuElement({id = "Harass", name = "Harass", type = MENU})
	Saga.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
    Saga.Harass:MenuElement({id = "UseW", name = "W", value = true})
    Saga.Harass:MenuElement({id = "UseE", name = "E", value = true})

	Saga:MenuElement({id = "Clear", name = "Clear", type = MENU})
	Saga.Clear:MenuElement({id = "UseQ", name = "Q", value = true})
    Saga.Clear:MenuElement({id = "UseW", name = "W", value = true})
	

	Saga:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
    Saga.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})

	Saga:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
    Saga.Killsteal:MenuElement({id ="qKS", name = "UseQ", value = true})
    Saga.Killsteal:MenuElement({id ="wKS", name = "UseW", value = true})

	Saga:MenuElement({id = "Misc", name = "R Settings", type = MENU})
	Saga.Misc:MenuElement({id = "UseR", name = "R", value = true})
	Saga.Misc:MenuElement({id = "RCount", name = "Use R on X targets", value = 2, min = 1, max = 5, step = 1})
    
    Saga:MenuElement({id = "Rate", name = "Recache Rate", type = MENU})
	Saga.Rate:MenuElement({id = "champion", name = "Value", value = 30, min = 1, max = 120, step = 1})

    Saga:MenuElement({id = "Escape", name = "RUN NINJA MODE (Flee)", type = MENU})
    Saga.Escape:MenuElement({id = "UseQ", name = "Q", value = true})

    Saga:MenuElement({id = "TS", name = "Target Selector", type = MENU})
    Saga.TS:MenuElement({id = "cTS", name = "Built in Target Selector", value = true, tooltip = "If off it uses orbwalkers"})

    Saga:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
    Saga.Drawings:MenuElement({id = "Q", name = "Draw Q range", type = MENU})
    Saga.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Saga.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Saga.Drawings.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
        --E
    Saga.Drawings:MenuElement({id = "W", name = "Draw W range", type = MENU})
    Saga.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Saga.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Saga.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})

    Saga.Drawings:MenuElement({id = "E", name = "Draw Real E range", type = MENU})
    Saga.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = false})       
    Saga.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Saga.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	
    Saga.Drawings:MenuElement({id = "R", name = "Draw R range", type = MENU})
    Saga.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Saga.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Saga.Drawings.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	

	
end
