if myHero.charName ~= "Jinx" then return end
local jinx = myHero
--local leftside = MapPosition:inLeftBase(myHero.pos)
local finalrange
local Tard_RangeCount = 0
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local fishbones = myHero:GetSpellData(_Q).toggleState == 2
local SagaHeroCount = Game.HeroCount()
local SagaTimer = Game.Timer
local Latency = Game.Latency
local ping = Latency() * .001
local Q = { Range1 = 600 , Speed = 1125}
local W = { Range = 1450,	Width = 60,Speed = 650,Delay = .6, From = myHero, collision = true }
local E = { Range = 900, Speed = math.huge, Width = 250,	Delay = 1.5}
local R = { Range = 20000, Speed = 1500, Width = 40,Delay = .6, Radius = 150}
local atan2 = math.atan2
local MathPI = math.pi
local _movementHistory = {}
local clock = os.clock
local hpredTick = 0
local sHero = Game.Hero
local TEAM_ALLY = jinx.team
local TEAM_ENEMY = 300 - TEAM_ALLY
local myCounter = 1
local SagaMCount = Game.MinionCount
local SagasBitch = Game.Minion
local ItsReadyDumbAss = Game.CanUseSpell
local CastItDumbFuk = Control.CastSpell
local _EnemyHeroes
local TotalHeroes
local LocalCallbackAdd = Callback.Add
local rlvl = myHero:GetSpellData(_R).level
local qlvl = myHero:GetSpellData(_Q).level
local finalrange = qlvl == 1 and jinx.range+75 or qlvl ==2 and jinx.range+100 or 
qlvl == 3 and jinx.range+125 or  qlvl == 4 and  jinx.range+150 or  qlvl == 5 and  jinx.range+175
local finaldamage = rlvl == 0 and 0 or rlvl == 1 and 250 or rlvl == 2 and 250 or rlvl == 3 and 450
local missingHP = rlvl == 0 and 0 or rlvl == 1 and .25 or rlvl == 2 and .3 or rlvl == 3 and .35
local visionTick = 0
local priority = 9999
local _OnVision = {}
local abs = math.abs 
local deg = math.deg 
local acos = math.acos 
local tClose = 0


local isEvading = ExtLibEvade and ExtLibEvade.Evading
	local validTarget,
		GetDistanceSqr,
        GetDistance,
        GetImmobileTime,
        GetTargetMS,
        GetTarget,
        GetPathNodes,
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
        minionCollision,
        VectorPointProjectionOnLineSegment,
        SagaSDKMagicDamage,
        SagaSDKPhysicalDamage,
        UpdateRange,
        GetQstacks,
        Combo,
        Saga,
        Saga_Menu


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
		p2 = p2 or jinx
		p1 = p1.pos or p1
		p2 = p2.pos or p2
		
	
		local dx, dz = p1.x - p2.x, p1.z - p2.z 
		return dx * dx + dz * dz
	end

GetEnemyHeroes = function()
        _EnemyHeroes = {}
        for i = 1, SagaHeroCount do
            local unit = sHero(i)
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

    IsFacing = function(unit)
	    local V = Vector((unit.pos - myHero.pos))
	    local D = Vector(unit.dir)
	    local Angle = 180 - deg(acos(V*D/(V:Len()*D:Len())))
	    if abs(Angle) < 80 then 
	        return true  
	    end
	    return false
	end

    local recalling = {}
--[[function OnProcessRecall(Object,recallProc)
	local rec = {}
	rec.hero = Object
	rec.info = recallProc
	rec.pos = Object.pos
	rec.starttime = GetTickCount()
	rec.killtime = nil
	rec.result = nil
    recalling[Object.networkID] = rec
    

    if os.clock() - rec.starttime <= 5 and Saga.QToggle.recallRocket:Value() then
        if not rec.hero.dead and rec.hero.isEnemy then
            local totalAD = myHero.bonusDamage * 1.5
            local spot
            local d = GetDistance(myHero.pos, rec.hero.pos)
            local mHp  = missingHP * (rec.hero.maxHealth - rec.hero.health)
            local maxDMG = finaldamage + totalAD + mHp
            local minDMG = maxDMG*.1
            if d > 1500 then
                d = 1500
            end
            for i = 1, Game.TurretCount() do

                local turret = Game.Turret(i);
                if turret then
                    if tClose == 0 then tClose = turret end
                    if turret.valid then
                        
                        if turret.pos:DistanceTo() < 2500 then
                            tClose = turret
                        end
                    end
                    
                    if leftside and turret.valid and turret.isEnemy and string.find(turret.name, "_L_") then
                        Draw.Circle(turret.pos, 2000, 3, Draw.Color(200, 255, 255, 255))
                        if GetDistanceSqr(rec.hero.pos, turret.pos) < 2500 * 2500 and GetDistanceSqr(myHero.pos, turret.pos) < 2500 * 2500 then
                            spot = rec.hero.pos
                        end
                    end
                    if leftside and turret.valid and string.find(turret.name, "_R_") then
                        if GetDistanceSqr(rec.hero.pos, turret.pos) < 2500 * 2500 and GetDistanceSqr(myHero.pos, turret.pos) < 2500 * 2500 then

                            spot = rec.hero.pos
                        end
                    end
                    if leftside and turret.valid and string.find(turret.name, "_L_") then
                        if GetDistanceSqr(rec.hero.pos, turret.pos) < 2500 * 2500 and GetDistanceSqr(myHero.pos, turret.pos) > 2500 * 2500 then

                            spot = rec.hero.pos + (myHero.pos - rec.hero.pos): Normalized():Perpendicular2() * -325
                        end
                    end
            
                    if leftside and turret.valid  and string.find(turret.name, "_R_") then
                        if GetDistanceSqr(rec.hero.pos, turret.pos) < 2500 * 2500 and GetDistanceSqr(myHero.pos, turret.pos) > 2500 * 2500 then

                            spot = rec.hero.pos + (myHero.pos - rec.hero.pos): Normalized():Perpendicular() * -324
                       end
                    end
            
                    if leftside and turret.valid  and string.find(turret.name, "_C_") then
                        if GetDistanceSqr(rec.hero.pos, turret.pos) < 2500 * 2500 and GetDistanceSqr(myHero.pos, turret.pos) > 2500 * 2500 and tClose then
                            if string.find(tClose.name, "_L_") then

                                spot = rec.hero.pos + (myHero.pos - rec.hero.pos): Normalized():Perpendicular() * -325
                            end
                            if string.find(tClose.name, "_R_") then

                                spot = rec.hero.pos + (myHero.pos - rec.hero.pos): Normalized():Perpendicular2() * -325
                            end
                        end
                    end
            
                    
                    
            
                end
            end


            
            
            local totaldmg = minDMG + ((.06 * minDMG) * (d*.1))
            local rDMG = CalculatePhysicalDamage(rec.hero, totaldmg)
            if spot and rDMG > rec.hero.health and Game.CanUseSpell(3) == 0 and not rec.hero.visible then 
                CastItBlindFuck(HK_R, spot)			
            end

        end
    end
end]]--

    


validTarget = function(unit)
        if unit and unit.isEnemy and unit.valid and unit.isTargetable and not unit.dead and not unit.isImmortal and not (GotBuff(unit, 'FioraW') == 1) and
        not (GotBuff(unit, 'XinZhaoRRangedImmunity') == 1 and unit.distance < 450) and unit.visible then
            return true
        else 
            return false
        end
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
		if jinx.ap > jinx.totalDamage then
			return EOW:GetTarget(range, EOW.ap_dec, jinx.pos)
		else
			return EOW:GetTarget(range, EOW.ad_dec, jinx.pos)
		end
	elseif SagaOrb == 2 and SagaSDKSelector then
		if jinx.ap > jinx.totalDamage then
			return SagaSDKSelector:GetTarget(range, SagaSDKMagicDamage)
		else
			return SagaSDKSelector:GetTarget(range, SagaSDKPhysicalDamage)
		end
	elseif _G.GOS then
		if jinx.ap > jinx.totalDamage then
			return GOS:GetTarget(range, "AP")
		else
			return GOS:GetTarget(range, "AD")
        end
    elseif _G.gsoSDK then
		return _G.gsoSDK.TS:GetTarget()
	end
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

minionCollision = function(target, me, position)
    local targemyCounter = 0
    for i = SagaMCount(), 1, -1 do 
        local minion = SagasBitch(i)
        if minion.isTargetable and minion.team == TEAM_ENEMY and minion.dead == false then
            local aim = GetPred(minion,math.huge,0.6 + Game.Latency()/1000)
            local linesegment, line, isOnSegment = VectorPointProjectionOnLineSegment(me, position, aim)
            if linesegment and isOnSegment and (GetDistanceSqr(aim, linesegment) <= (minion.boundingRadius + W.Width) * (minion.boundingRadius + W.Width)) then
                targemyCounter = targemyCounter + 1
            end
        end
    end
    return targemyCounter
end

local manaManager = function(unit)
    return (unit.mana / unit.maxMana) * 100
end

heroCollision = function(target, me, position)
    local targemyCounter = 0
    for i = TotalHeroes, 1, -1 do 
        local hero = _EnemyHeroes[i]
        if hero.isTargetable and hero.team == TEAM_ENEMY and hero.dead == false and not target then
            local linesegment, line, isOnSegment = VectorPointProjectionOnLineSegment(me, position, hero.pos)
            if linesegment and isOnSegment and (GetDistanceSqr(hero.pos, linesegment) <= (hero.boundingRadius + R.Width) * (hero.boundingRadius + R.Width)) then
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
            return true
        end
    end
    return false
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
    
    if CheckMinionCollision(source.pos, aimPosition, delay, speed, radius) then
        hitChance = -1
    end
    
    return hitChance, aimPosition
end

function CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)
    if not frequency then
		frequency = radius
    end
	local directionVector = (endPos - origin):Normalized()
    local checkCount = GetDistance(origin, endPos) / frequency
	for i = 1, checkCount do
		local checkPosition = origin + directionVector * i * frequency
        local checkDelay = delay + GetDistance(origin, checkPosition) / speed
		if IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
			return true
		end
	end
	return false
end
function IsMinionIntersection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 500
	end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and CanTarget(minion) and IsInRange(minion.pos, location, maxDistance) then
			local predictedPosition = PredictUnitPosition(minion, delay)
			if IsInRange(location, predictedPosition, radius + minion.boundingRadius) then
				return true
			end
		end
	end
	return false
end

function IsInRange(p1, p2, range)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(1)
		print("Undefined IsInRange target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return false
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) < range * range 
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

GetMinionsinRangeCount = function(target,range)
	local inRadius =  {}
	
    for i = SagaMCount(), 1, -1 do 
        local minion = SagasBitch(i)
		if minion.pos ~= nil and minion.isTargetable and minion.team == TEAM_ENEMY and minion.dead == false then
			if  GetDistance(target.pos, minion.pos) <= range then	
				inRadius[myCounter] = minion
                myCounter = myCounter + 1
            end
        end
	end
		myCounter = 1
    return #inRadius, inRadius
end

LocalCallbackAdd("Load", function()
TotalHeroes = GetEnemyHeroes()
--leftside = MapPosition:inLeftBase(myHero.pos)
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


LocalCallbackAdd("Draw", function()
    local killlist = {}
    if Saga.Drawings.W.Enabled:Value() then 
        Draw.Circle(myHero.pos, W.Range, 0, Saga.Drawings.W.Color:Value())
    end

    if Saga.Drawings.E.Enabled:Value() then 
        Draw.Circle(myHero.pos, E.Range, 0, Saga.Drawings.E.Color:Value())
    end

    if Saga.Drawings.R.Enabled:Value() then 
        Draw.Circle(myHero.pos, Saga.rRange.sliderC:Value(), 0, Saga.Drawings.R.Color:Value())
    end
    if Saga.Drawings.kills.Enabled:Value() then
        for i= 1, TotalHeroes do
            local hero = _EnemyHeroes[i]
            if not hero.dead and hero.visible then
                local totalAD = myHero.bonusDamage * 1.5
                local d = GetDistance(myHero.pos, hero.pos)
                local mHp  = missingHP * (hero.maxHealth - hero.health)
                local maxDMG = finaldamage + totalAD + mHp
                local minDMG = maxDMG*.1
                if d > 1500 then
                    d = 1500
                end

                local totaldmg = minDMG + ((.06 * minDMG) * (d*.1))
                local rDMG = CalculatePhysicalDamage(hero, totaldmg)
                
                if rDMG > hero.health and Game.CanUseSpell(3) == 0 then 
                    killlist[myCounter] = hero
                    myCounter = myCounter + 1
                    --Draw.Text(hero.charName, 30, 100,100, Draw.Color(200, 255, 87, 51))				
                end

            end
        end
        myCounter = 1
        for i = 1, #killlist do 
            local dHero = killlist[i]
                Draw.Text(dHero.charName, 30, 700,i*30, Draw.Color(200, 255, 87, 51))
            if Saga.Drawings.kills.mEnabled:Value() then
                Draw.CircleMinimap(dHero.pos,800,3,Draw.Color(200, 255, 87, 51))
            end
        end
    end
end)

LocalCallbackAdd("Tick", function()

    if Game.Timer() > Saga.Rate.champion:Value() and #_EnemyHeroes == 0 then
        TotalHeroes = GetEnemyHeroes()
    end

    if isEvading or myHero.dead or Game.IsChatOpen() == true then return end
    Killsteal()
    useRonKey()
    AutoE()
    if GetOrbMode() == 'Combo' then
        Combo()
        
    end

    if GetOrbMode() == 'Harass' then
        Harass()
    end

    if GetOrbMode() == 'Clear' and Saga.Clear.UseQ:Value() then
        LaneClear()
    end

    if GetOrbMode() == 'Flee' then
        Flee()
    end

        UpdateMovementHistory()
        UpdateRange()
    end)


GetQstacks =  function()

	for i = 1, jinx.buffCount do
		local buff = myHero:GetBuff(i)
		if buff then 
			if buff.count > 0 and buff.name:lower() == "jinxqramp" then 
				return buff.count
			end
		end
	end
end

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

GetItemSlot = function(unit, id)
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


    function CalculatePhysicalDamage(target, damage)

        if target and damage then
            local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
            local damageReduction = 100 / ( 100 + targetArmor)
            if targetArmor < 0 then
                damageReduction = 2 - (100 / (100 - targetArmor))
            end		
            damage = damage * damageReduction	
            return damage
        end
        return 0
    end

AutoE = function()
    local target2 = GetTarget(E.Range)
    if target2 and Saga.QToggle.UseAuto:Value() then
        
    local aim2 = GetPred(target2,math.huge,1.5 + Game.Latency()/1000)
    if aim2 ~= nil and validTarget(target2) and IsImmobileTarget(target2) then
		if ItsReadyDumbAss(2) == 0 and myHero.attackData.state ~= 2 then
			CastSpell(HK_E, aim2, E.Range, E.Delay)
        end
    end
    end

end

Combo =  function()
    
    local target4 = GetTarget(Saga.rRange.sliderC:Value())
    local totalAD = myHero.bonusDamage * 1.5
    
if target4 and Game.CanUseSpell(3) == 0 and Saga.Combo.UseR:Value() then
    
    local d = GetDistance(myHero.pos, target4.pos)
    local mHp  = missingHP * (target4.maxHealth - target4.health)
    local maxDMG = finaldamage + totalAD + mHp
    local minDMG = maxDMG*.1
    if d > 1500 then
        d = 1500
    end 

    local totaldmg = minDMG + ((.06 * minDMG) * (d*.1))
    local rDMG = CalculatePhysicalDamage(target4, totaldmg)
    --local hitchance4, aim4 = GetHitchance(jinx.pos, target4, R.Range, R.Delay, R.Speed, R.Width, false)
    local aim4 = GetPred(target4,math.huge,0.6 + Game.Latency()/1000)
    if aim4 and validTarget(target4) then
		if ItsReadyDumbAss(3) == 0  and aim4:To2D().onScreen and rDMG > target4.health and d > finalrange and myHero.attackData.state ~= 2 then
            CastSpell(HK_R, aim4, R.Range, R.Delay*1000)
        elseif ItsReadyDumbAss(3) == 0  and rDMG > target4.health and d > finalrange and myHero.attackData.state ~= 2 then
            CastItBlindFuck(HK_R, aim4, R.Range, R.Delay * 1000)
        end
    end
end

    local target = GetTarget(W.Range)
    if target and Saga.Combo.UseW:Value() then
    local d = GetDistance(myHero.pos, target.pos)
    local aim = GetPred(target,math.huge,0.6 + Game.Latency()/1000)
    if aim ~= nil and validTarget(target) and myHero.attackData.state ~= 2 then
        if GetDistance(myHero, aim) > W.Range then
            aim = myHero.pos + (aim- myHero.pos):Normalized() * W.Range
        end
		if ItsReadyDumbAss(1) == 0 and  GetDistanceSqr(target) > finalrange * finalrange and aim:To2D().onScreen and (Game.Timer() - OnWaypoint(target).time < 0.15 or Game.Timer() - OnWaypoint(target).time > 1.0) and minionCollision(target, jinx.pos, aim) == 0 then
            CastSpell(HK_W, aim, W.Range, W.Delay)
        end
    end
    end

    local target2 = GetTarget(E.Range)
    if target2 and Saga.Combo.UseE:Value() then
        
    local aim2 = GetPred(target2,math.huge,1.5 + Game.Latency()/1000)
    if aim2 ~= nil and validTarget(target2) then
		if ItsReadyDumbAss(2) == 0  and myHero.attackData.state ~= 2 and (Game.Timer() - OnWaypoint(target).time < 0.15 or Game.Timer() - OnWaypoint(target).time > 1.0)then
			CastSpell(HK_E, aim2, E.Range, E.Delay * 1000)
        end
    end
    end
    local FishStacks = GetQstacks() or 0
    local target3 = GetTarget(2000)
    if target3 and Saga.Combo.UseQ:Value() then
        local aim3 = GetPred(target3,math.huge)
        if myHero:GetSpellData(_Q).toggleState == 1 and aim3 then
            
            if FishStacks == 3 and Saga.QToggle.UseQ:Value() and aim3:DistanceTo() < finalrange and  ItsReadyDumbAss(0) ~= 32 and ItsReadyDumbAss(0) == 0 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
            if  aim3:DistanceTo() > 550 + target3.boundingRadius and ItsReadyDumbAss(0) ~= 32 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
            
            if GetEnemiesinRangeCount(target3, 150) > 1 and ItsReadyDumbAss(0) ~= 32 and FishStacks > 2 and ItsReadyDumbAss(0) == 0 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
        else
            if myHero:GetSpellData(_Q).toggleState == 2 then
            if GetEnemiesinRangeCount(target3, 150) > 1 then
                return
            end
            if FishStacks < 3 and aim3:DistanceTo() < 575 + target3.boundingRadius and ItsReadyDumbAss(0) ~= 32 and ItsReadyDumbAss(0) == 0 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
            if aim3:DistanceTo() < 575 + target3.boundingRadius and ItsReadyDumbAss(0) ~= 32 and ItsReadyDumbAss(0) == 0 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
            if GetEnemiesinRangeCount(myHero, finalrange) < 1 and ItsReadyDumbAss(0) ~= 32  and ItsReadyDumbAss(0) == 0 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
        end
        end
    end
end

Harass = function()

    local target = GetTarget(W.Range)
    if target and Saga.Harass.UseW:Value() then
    local d = GetDistanceSqr(myHero.pos, target.pos)
    local aim = GetPred(target,math.huge,0.6 + Game.Latency()/1000)
	if d > finalrange * finalrange and aim and validTarget(target) and myHero.attackData.state ~= 2 then
		if manaManager(jinx) >= Saga.mana.manaH.Wmana:Value() and ItsReadyDumbAss(1) == 0 and aim:To2D().onScreen and minionCollision(target, jinx.pos, aim) == 0  then
            if GetDistance(myHero, aim) > W.Range then
                aim = myHero.pos + (aim- myHero.pos):Normalized() * W.Range
            end
            CastSpell(HK_W, aim, W.Range, W.Delay * 1000)
        end
    end
    end

    local FishStacks = GetQstacks() or 0
    local target3 = GetTarget(1000)
    if target3 and Saga.Harass.UseQ:Value() then
        local aim3 = GetPred(target3,math.huge)
        if myHero:GetSpellData(_Q).toggleState == 1 and aim3 then

            if FishStacks == 3 and manaManager(jinx) >= Saga.mana.manaH.Qmana:Value() and Saga.QToggle.UseQ:Value() and aim3:DistanceTo() < finalrange and ItsReadyDumbAss(0) == 0 and ItsReadyDumbAss(0) ~= 32 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
            if  Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and manaManager(jinx) >= Saga.mana.manaH.Qmana:Value() and aim3:DistanceTo() > 550 + target3.boundingRadius and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
            if manaManager(jinx) >= Saga.mana.manaH.Qmana:Value() and GetEnemiesinRangeCount(target3, 150) > 1 and FishStacks > 2 and ItsReadyDumbAss(0) == 0 and ItsReadyDumbAss(0) ~= 32 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
        else
            if myHero:GetSpellData(_Q).toggleState == 2 then
                if manaManager(jinx) >= Saga.mana.manaL.Qmana:Value() and Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and myHero:GetSpellData(_Q).toggleState == 2 then
                    Control.CastSpell(HK_Q)
                end
            if GetEnemiesinRangeCount(target3, 150) > 1 then
                return
            end
            if FishStacks < 3 and aim3:DistanceTo() < 575 + target3.boundingRadius and ItsReadyDumbAss(0) == 0 and ItsReadyDumbAss(0) ~= 32 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
            if aim3:DistanceTo() < 575 + target3.boundingRadius and ItsReadyDumbAss(0) == 0 and ItsReadyDumbAss(0) ~= 32 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
        end
        end
    end

end

LaneClear = function() 
    local mp
    
    local target = GetTarget(W.Range)
        if target and Saga.Clear.UseW:Value() then
        local d = GetDistanceSqr(myHero.pos, target.pos)
        local aim = GetPred(target,math.huge,0.6 + Game.Latency()/1000)
        if d > finalrange * finalrange  and aim and validTarget(target) and myHero.attackData.state ~= 2 then
            if GetDistance(myHero, aim) > W.Range then
                aim = myHero.pos + (aim- myHero.pos):Normalized() * W.Range
            end
            if (Game.Timer() - OnWaypoint(target).time < 0.15 or Game.Timer() - OnWaypoint(target).time > 1.0) and manaManager(jinx) >= Saga.mana.manaL.Wmana:Value() and ItsReadyDumbAss(1) == 0 and   aim:To2D().onScreen and minionCollision(target, jinx.pos, aim) == 0 then
                CastSpell(HK_W, aim, W.Range, W.Delay*1000)
            end
        end
        end

    for i = SagaMCount(), 1, -1 do 
        local minion = SagasBitch(i)
        if manaManager(jinx) >= Saga.mana.manaL.Qmana:Value() and minion.isTargetable and minion.team == TEAM_ENEMY and minion.dead == false and minion.health < priority then
            priority = minion.health
            mp = minion
            
            if Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and mp.pos:DistanceTo() > 600 and mp.pos:DistanceTo() < finalrange and myHero:GetSpellData(_Q).toggleState == 1 then
                Control.CastSpell(HK_Q)
            end
            
            if Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and myHero.attackData.target == mp.handle then
                if GetMinionsinRangeCount(mp, 150) > 2 and myHero:GetSpellData(_Q).toggleState == 1 and mp.pos:DistanceTo() > 600 and mp.pos:DistanceTo() < finalrange  then
                    Control.CastSpell(HK_Q)
                end
            end

            if Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and mp.pos:DistanceTo() < 600 and myHero:GetSpellData(_Q).toggleState == 2  and GetMinionsinRangeCount(mp, 150) < 2 then
                Control.CastSpell(HK_Q)
            end

            if Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and Game.CanUseSpell(0) == 0 and myHero:GetSpellData(_Q).toggleState == 2 or manaManager(jinx) < Saga.mana.manaH.Wmana:Value() then
                Control.CastSpell(HK_Q)
            end

        end
    end
        priority = 9999

    local target3 = GetTarget(1000)
    if target3 and Saga.Clear.UseQT:Value() then
        local aim3 = GetPred(target3,math.huge)
        if myHero:GetSpellData(_Q).toggleState == 1 and aim3 and manaManager(jinx) >= Saga.mana.manaL.Qmana:Value() then
            if  Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and manaManager(jinx) >= Saga.mana.manaL.Qmana:Value() and aim3:DistanceTo() > 550 + target3.boundingRadius and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
            if Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and manaManager(jinx) >= Saga.mana.manaL.Qmana:Value() and GetEnemiesinRangeCount(target3, 150) > 1 and FishStacks > 2 and ItsReadyDumbAss(0) == 0 and myHero.attackData.state ~= 2 then
                CastItDumbFuk(HK_Q)
            end
        else
            if myHero:GetSpellData(_Q).toggleState == 2 then
                if  Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and myHero:GetSpellData(_Q).toggleState == 2 then
                    Control.CastSpell(HK_Q)
                end
                if GetEnemiesinRangeCount(target3, 150) > 1 then
                    return
                end
                if Game.CanUseSpell(0) == 0 and ItsReadyDumbAss(0) ~= 32 and aim3:DistanceTo() < 575 + target3.boundingRadius and ItsReadyDumbAss(0) == 0 and myHero.attackData.state ~= 2 then
                    CastItDumbFuk(HK_Q)
                end
            end
        end
    end


end

function useRonKey()
    local target4 = GetTarget(20000)
    local totalAD = myHero.bonusDamage * 1.5
	if Saga.Combo.useRkey:Value() and target4 then
		if Game.CanUseSpell(3) == 0 then
			local d = GetDistance(myHero.pos, target4.pos)
        local mHp  = missingHP * (target4.maxHealth - target4.health)
        local maxDMG = finaldamage + totalAD + mHp
        local minDMG = maxDMG*.1
        if d > 1500 then
            d = 1500
        end 

        local totaldmg = minDMG + ((.06 * minDMG) * (d*.1))
        local rDMG = CalculatePhysicalDamage(target4, totaldmg)
        --local hitchance4, aim4 = GetHitchance(jinx.pos, target4, R.Range, R.Delay, R.Speed, R.Width, false)
        local aim4 = GetPred(target4,math.huge,0.6 + Game.Latency()/1000)
        if aim4 and validTarget(target4) then
            if (Game.Timer() - OnWaypoint(target4).time < 0.15 or Game.Timer() - OnWaypoint(target4).time > 1.0) and ItsReadyDumbAss(3) == 0  and aim4:To2D().onScreen and rDMG > target4.health and d > finalrange and myHero.attackData.state ~= 2 then
                CastSpell(HK_R, aim4, R.Range, R.Delay * 1000)
            elseif (Game.Timer() - OnWaypoint(target4).time < 0.15 or Game.Timer() - OnWaypoint(target4).time > 1.0) and ItsReadyDumbAss(3) == 0  and rDMG > target4.health and d > finalrange and myHero.attackData.state ~= 2 then
                CastItBlindFuck(HK_R, aim4, R.Range, R.Delay * 1000)
            end
        end
	end
    end
end


Killsteal = function()
    local target4 = GetTarget(Saga.rRange.sliderA:Value())
    local totalAD = myHero.bonusDamage * 1.5


    if target4 and Game.CanUseSpell(3) == 0 and rlvl > 0 and Saga.Killsteal.rKS:Value() then
        local d = GetDistance(myHero.pos, target4.pos)
        local mHp  = missingHP * (target4.maxHealth - target4.health)
        local maxDMG = finaldamage + totalAD + mHp
        local minDMG = maxDMG*.1
        if d > 1500 then
            d = 1500
        end 
        local totaldmg = minDMG + ((.06 * minDMG) * (d*.1))
        local rDMG = CalculatePhysicalDamage(target4, totaldmg)
        local aim4 = GetPred(target4,math.huge,0.6 + Game.Latency()/1000)
        if aim4 and validTarget(target4) then
            if ItsReadyDumbAss(3) == 0  and aim4:To2D().onScreen and rDMG > target4.health and d > finalrange and myHero.attackData.state ~= 2 then
                CastSpell(HK_R, aim4, R.Range, W.Delay*1000)
            end
        end
    end

    local target = GetTarget(W.Range)
    if target and Saga.Killsteal.wKS:Value() then
    local d = GetDistance(myHero.pos, target.pos)
    local wDmg = CalculatePhysicalDamage(target, (myHero:GetSpellData(_W).level * 50 - 40) + myHero.totalDamage * 1.4)
    local aim = GetPred(target,math.huge,0.6 + Game.Latency()/1000)
	if aim ~= nil and validTarget(target) and myHero.attackData.state ~= 2 then
		if d > finalrange * finalrange and ItsReadyDumbAss(1) == 0 and wDmg > (target.health+target.shieldAD+target.shieldAP) and   minionCollision(target, jinx.pos, aim) == 0 then
            CastSpell(HK_W, aim, W.Range, W.Delay * 1000)
        end
    end
    end

end


Flee = function()
    
    local target = GetTarget(W.Range)
    if target and Saga.Combo.UseW:Value() then
    local d = GetDistance(myHero.pos, target.pos)
    local wDmg = CalculatePhysicalDamage(target, (myHero:GetSpellData(_W).level * 50 - 40) + myHero.totalDamage * 1.4)
    local aim = GetPred(target,math.huge,0.6 + Game.Latency()/1000)
    if aim ~= nil and validTarget(target) and myHero.attackData.state ~= 2 then
		if ItsReadyDumbAss(1) == 0 and   aim:To2D().onScreen and minionCollision(target, jinx.pos, aim) == 0 then
            
            CastSpell(HK_W, aim, W.Range, W.Delay * 1000)
        end
    end
    end
end


UpdateRange = function()
    if os.clock() - Tard_RangeCount >  1 then
        qlvl = myHero:GetSpellData(_Q).level
        rlvl = myHero:GetSpellData(_R).level
        finalrange = qlvl == 0 and 0 or qlvl == 1 and jinx.range+75 or qlvl ==2 and jinx.range+100 or 
         qlvl == 3 and jinx.range+125 or  qlvl == 4 and  jinx.range+150 or  qlvl == 5 and  jinx.range+175
        finaldamage = rlvl == 0 and 0 or rlvl == 1 and 250 or rlvl == 2 and 250 or rlvl == 3 and 450
        missingHP = rlvl == 0 and 0 or rlvl == 1 and .25 or rlvl == 2 and .3 or rlvl == 3 and .35
        Tard_RangeCount = os.clock()
    end
end

Saga_Menu = 
function()
	Saga = MenuElement({type = MENU, id = "Irelia", name = "Saga's Jinx: Lets See Pow Pow Thinks", icon = AIOIcon})
	MenuElement({ id = "blank", type = SPACE ,name = "Version 3.0.0"})
	--Combo
	Saga:MenuElement({id = "Combo", name = "Combo", type = MENU})
    Saga.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	Saga.Combo:MenuElement({id = "UseW", name = "W", value = true})
	Saga.Combo:MenuElement({id = "UseE", name = "E", value = true})
    Saga.Combo:MenuElement({id = "UseR", name = "R", value = true})
    Saga.Combo:MenuElement({id = "useRkey", name = "On Key Press Killable(Ult)", key = string.byte("T")})

	Saga:MenuElement({id = "Harass", name = "Harass", type = MENU})
	Saga.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
	Saga.Harass:MenuElement({id = "UseW", name = "W", value = true})

    
	Saga:MenuElement({id = "Clear", name = "Clear", type = MENU})
    Saga.Clear:MenuElement({id = "UseQ", name = "Q", value = true})
    Saga.Clear:MenuElement({id = "UseQT", name = "Q Logic on Champ", value = true})
    Saga.Clear:MenuElement({id = "UseW", name = "W", value = true, tooltip = "On Champs"})
    
    Saga:MenuElement({id = "rRange", name = "Ult Range Slider", type = MENU})
    Saga.rRange:MenuElement({id = 'sliderC', name = 'Range for ult using Spacebar', value = 2000, min = 0, max = 20000,step = 100, tooltip = "Holding SpaceBar"})
    Saga.rRange:MenuElement({id = 'sliderA', name = 'Range for ult using Auto', value = 2000, min = 0, max = 20000,step = 100, tooltip = "Auto Use"})
    
    Saga:MenuElement({id = "Rate", name = "Recache Rate", type = MENU})
	Saga.Rate:MenuElement({id = "champion", name = "Value", value = 30, min = 1, max = 120, step = 1})
    
    --[[
    
	Saga:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
    Saga.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
    ]]--
    Saga:MenuElement({id = "mana", name = "Mana Manager", type = MENU})
    Saga.mana:MenuElement({id = "manaH", name = "Harass", type = MENU})
    Saga.mana.manaH:MenuElement({id = 'Qmana', name = 'Min. Mana For Q', value = 25, min = 0, max = 100, tooltip = "Percentage"})
    Saga.mana.manaH:MenuElement({id = 'Wmana', name = 'Min. Mana for W', value = 25, min = 0, max = 100, tooltip = "Percentage"})
    Saga.mana:MenuElement({id = "manaL", name = "LaneClear", type = MENU})
    Saga.mana.manaL:MenuElement({id = 'Qmana', name = 'Min. Mana For Q', value = 25, min = 0, max = 100, tooltip = "Percentage"})
    Saga.mana.manaL:MenuElement({id = 'Wmana', name = 'Min. Mana for W', value = 25, min = 0, max = 100, tooltip = "Percentage"})

	Saga:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
    Saga.Killsteal:MenuElement({id ="rKS", name = "UseR", value = true})
    Saga.Killsteal:MenuElement({id ="wKS", name = "UseW", value = true})
	
    Saga:MenuElement({id = "Escape", name = "RUN NINJA MODE (Flee)", type = MENU})
    Saga.Escape:MenuElement({id = "UseW", name = "W", value = true})

    Saga:MenuElement({id = "QToggle", name = "Misc", type = MENU})
    Saga.QToggle:MenuElement({id = "UseQ", name = "Q Passive Toggle", tooltip = "Wont Rocket in minigun range",value = false})
    Saga.QToggle:MenuElement({id = "UseAuto", name = "AutoE Immobile", value = true})
    --Saga.QToggle:MenuElement({id = "recallRocket", name = "Ult on Recall[Beta]", value = true})
    


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

    Saga.Drawings:MenuElement({id = "kills", name = "Show Kill List", type = MENU})
    Saga.Drawings.kills:MenuElement({id = "Enabled", name = "Enabled List", value = true})
    Saga.Drawings.kills:MenuElement({id = "mEnabled", name = "Enabled Minimap Draw", value = true})

end