local Heroes = {"Orianna", "KogMaw"}
if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"
require "MapPosition"
local ball_name = ""
local ball_pos = ""
local AIOIcon = "https://raw.githubusercontent.com/jj1232727/Orianna/master/images/saga.png"
local timer = os.clock() -1      -- initialise a timer at the start of the script 




local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local barHeight = 8
local barWidth = 103
local barXOffset = 24
local barYOffset = -8
local EDMG = {}
local Version,Author,LVersion = "v1.0","Saga","8.8"
local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
hkitems = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6,[ITEM_7] = HK_ITEM_7, [_Q] = HK_Q, [_W] = HK_W, [_E] = HK_E, [_R] = HK_R }

if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
	PrintChat("TPred library loaded")
elseif FileExist(COMMON_PATH .. "HPred.lua") then
	require 'HPred'
elseif FileExist(COMMON_PATH .. "Collision.lua") then
	require 'Collision'
	PrintChat("Collision library loaded")
end




local function buffCount(unit, bName)
    for i = 0, unit.buffCount do
      local buff = unit:GetBuff(i)
      if buff and buff.count > 0 and buff.name:lower() == bName then
        return buff.count
      end
    end
    return 0
  end

function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

function HasBuff(player, buffname)
	for i = 0, player.buffCount do
		local buff = player:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function HpPred(player, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(player,delay)
	else
	hp = player.health
	end
	return hp
end


function EnemyInRange(range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end






function GetEnemyHeroes()
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end



function GetAllyHeroes()
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly and not Hero.isMe then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Ready(spellSlot)
	return IsReady(spellSlot)
end


--Gamerstron PointLineSegment
local function gsoClosestPointOnLineSegment(p, p1, p2)
	if p1 == nil or p2 == nil or p == nil then end
    local px,pz = p.x, p.z
    local ax,az = p1.x, p1.z
    local bx,bz = p2.x, p2.z
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((px - ax) * bxax + (pz - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    if t < 0 then
      return p1, false
    elseif t > 1 then
      return p2, false
    else
      return { x = ax + t * bxax, z = az + t * bzaz }, true
    end
  end




local sqrt = math.sqrt
local function GetDistanceSqr(p1, p2)
    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    return (dx * dx + dz * dz)
end

local function GetDistance(p1, p2)
    return sqrt(GetDistanceSqr(p1, p2))
end

local function GetDistance2D(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end


function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in pairs(objects) do
        local hit = CountObjectsNearPos(object.pos, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object.pos
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in pairs(objects) do
        if GetDistanceSqr(pos, object.pos) <= radius * radius then
            n = n + 1
        end
    end
    return n
end



class "Orianna"

function Orianna:LoadSpells()

	Q = {Range = 825, Width = 40, Delay = 0.40, Speed = 1200, Collision = false, aoe = false, Type = "circular"}
	W = {Delay = 0.10, Speed = 1200, Collision = false, aoe = false, Type = "circular", Radius = 240}
	E = {Range = 1100, Width = 40, Delay = 0.35, Speed = 1200, Collision = false, aoe = false, Type = "line"}
	R = {Delay = 0.35, Speed = 1200, Collision = false, aoe = false, Type = "circular", Radius = 310}

end

function Orianna:LoadMenu()
	AIO = MenuElement({type = MENU, id = "Orianna", name = "Saga's AIO Orianna", icon = AIOIcon})
	AIO:MenuElement({id = "Combo", name = "Combo", type = MENU})
	AIO.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Combo:MenuElement({id = "UseW", name = "W", value = true})
	AIO.Combo:MenuElement({id = "UseE", name = "E", value = true})
	AIO.Combo:MenuElement({id = "Rkey", name = "R Key",  key = string.byte("T")})
	AIO.Combo:MenuElement({id = "ShieldMinHealth", name="Min Health -> %",value=30,min=0,max=100})
	AIO.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})

	AIO:MenuElement({id = "Harass", name = "Harass", type = MENU})
	AIO.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Harass:MenuElement({id = "UseW", name = "W", value = true})
	AIO.Harass:MenuElement({id = "harassActive", name = "Harass Key", key = string.byte("C")})
	
	AIO:MenuElement({id = "Clear", name = "Clear", type = MENU})
	AIO.Clear:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Clear:MenuElement({id = "QCount", name = "Use Q on X minions", value = 3, min = 1, max = 4, step = 1})
	AIO.Clear:MenuElement({id = "UseW", name = "W", value = true})
	AIO.Clear:MenuElement({id = "WCount", name = "Use W on X minions", value = 3, min = 1, max = 4, step = 1})
	AIO.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
	
	AIO:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	AIO.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
	
	AIO:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	AIO.Killsteal:MenuElement({id = "RR", name = "R KS on: ", value = false, type = MENU})
	for i, hero in pairs(GetEnemyHeroes()) do
	AIO.Killsteal.RR:MenuElement({id = "UseR"..hero.charName, name = "Use R on: "..hero.charName, value = true})
	end

	AIO:MenuElement({id = "Misc", name = "R Settings", type = MENU})
	AIO.Misc:MenuElement({id = "UseR", name = "R", value = true})
	AIO.Misc:MenuElement({id = "RCount", name = "Use R on X targets", value = 2, min = 1, max = 5, step = 1})

	AIO:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	
	AIO:MenuElement({id = "dashing", name = "E Dashing Targets", type = MENU})
    AIO.dashing:MenuElement({id = "AutoE", name = "Auto E on dashing Allys", value = true})
	
	--Q
	AIO.Drawings:MenuElement({id = "Q", name = "Draw Q range", type = MENU})
    AIO.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--E
	AIO.Drawings:MenuElement({id = "E", name = "Draw E range", type = MENU})
    AIO.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	
	--Ball
	AIO.Drawings:MenuElement({id = "ballDraw", name = "Draw W and R on ball", type = MENU})
    AIO.Drawings.ballDraw:MenuElement({id = "BallR", name = "Q Enabled", value = true})       
    AIO.Drawings.ballDraw:MenuElement({id = "BallW", name = "W Enabled", value = true}) 
	
	
	
	
	
	AIO:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast",value = true})
	AIO:MenuElement({id = "delay", name = "Custom spellcast delay", value = 100, min = 0, max = 200, step = 5,tooltip = "Increase if spells are inaccurate", identifier = ""})
	
	AIO:MenuElement({id = "blank", type = SPACE , name = ""})
	AIO:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	AIO:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end


function Orianna:__init()
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)

	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	else
		orbwalkername = "Orbwalker not found"
	end
end



function Orianna:Tick()
		self:KillstealR()
		self:AutoultMe()
		self:Autoult1Ally()
		self:AutoultBall()
		--if Game.CanUseSpell(0) ~= 0 or Game.CanUseSpell(2) ~= 0 then
		self:uBall() --end
		--DelayAction(function() self:Ball() end , 0.70)
        if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true or ExtLibEvade and ExtLibEvade.Evading == true then return end
	if AIO.Combo.comboActive:Value() then
		self:OriQ()
		self:KillstealR()
		---self:AutoultMe()
		self:Autoult1Ally()
		self:AutoultBall()
		self:ComboW()
		if Ready(_W) == false or  CurrentTarget(300)then
		self:EThroughTarget() end
	end
	if AIO.Harass.harassActive:Value() then
		self:Harass()
		self:OriQH()
		self:HarassW()
		--self:EThroughTarget()
	end
	if AIO.Clear.clearActive:Value() then
		self:Clear()
		self:ClearW()
		self:ClearJungle()
	end
	if AIO.Lasthit.lasthitActive:Value() then
		self:Lasthit()
	end		
	if AIO.Combo.Rkey:Value() then
		self:RKey()
	end		
	if AIO.dashing.AutoE:Value() then
		self:eMovingAlly()
	end		
		
		
	
	end
	

function Orianna:uBall()
local X, Y = Game.CanUseSpell(0), Game.CanUseSpell(2)
if X ~= 0 or Y ~= 0 then
	for i = 1, Game.MissileCount() do
            local obj = Game.Missile(i)
			
            if obj.missileData.owner == myHero.handle and obj.missileData.target == 0 then
                ball_pos = obj.pos
            end
        end
		end
		if GotBuff(myHero, "orianaghostself") then 
			ball = ball_name
		else
			for i = 1, Game.HeroCount() do
				local hero = Game.Hero(i)
				if GotBuff(hero, "orianaghost") then 
					ball = hero.pos 
					break
				end
			end
		end
		
	
		
		
end
	
	
	function Orianna:Ball()
		local BallNames = 
{
	--Ball name on ground: Add to list if it changes with skins. Requires testing :D
	"Orianna_Base_Q_yomu_ring_green",
}

		--local BallPosition = nil
		
		--[[
		for i = 1, Game.ObjectCount() do
			local object = Game.Object(i)
			
			if object and string.find(object.name,"ball") then
				ball_name = object.name
				ball_pos = object.pos
				return
				
				end
		
		end	
		]]--
		ObjectManager = __ObjectManager()
		--This will trigger every time a particle is created
		ObjectManager:OnParticleCreate(function(args)
			--Match up the name: NOTE IT MAY CHANGE WITH SKIN USED... 
			if table.contains(BallNames, args.name) then
				ball_pos = args.pos 
			end
		end)

		--This will trigger every time a particle in the game is destroyed
		ObjectManager:OnParticleDestroy(function(args)	
			if table.contains(BallNames, args.name) then
				ball_pos = nil
			end
		end)
		
		if GotBuff(myHero, "orianaghostself") then 
			ball = ball_name
		else
			for i = 1, Game.HeroCount() do
				local hero = Game.Hero(i)
				if GotBuff(hero, "orianaghost") then 
					ball = hero.pos 
					break
				end
			end
		end
		
	end

function Orianna:Draw()
	if HasBuff(myHero, "orianaghostself") == false and AIO.Drawings.ballDraw.BallR:Value()then
		Draw.Circle(ball_pos, 240, 0, Draw.Color(200, 255, 87, 51)) end
	if HasBuff(myHero, "orianaghostself") == false and AIO.Drawings.ballDraw.BallW:Value()then
		Draw.Circle(ball_pos, 310, 0, Draw.Color(200, 255, 87, 51)) end
	
if Ready(_Q) and AIO.Drawings.Q.Enabled:Value() then Draw.Circle(myHero.pos, Q.Range, 0, AIO.Drawings.Q.Color:Value()) end
if Ready(_E) and AIO.Drawings.E.Enabled:Value() then Draw.Circle(myHero.pos, E.Range, 0, AIO.Drawings.E.Color:Value()) end
if AIO.Drawings.ballDraw.BallR:Value() and Ready(_R) and not HasBuff(myHero, "orianaghostself") then 

	else if AIO.Drawings.ballDraw.BallR:Value() and Ready(_R) and HasBuff(myHero, "orianaghostself") then
	--raw.Circle(myHero.pos, 400, 5, Draw.Color(200, 255, 255, 255))
	
	end 
end
			
		for i, hero in pairs(GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = (Ready(_Q) and getdmg("Q",hero,myHero) or 0)
				local WDamage = (Ready(_W) and getdmg("W",hero,myHero) or 0)
				local EDamage = (Ready(_E) and getdmg("E",hero,myHero) or 0)
				local RDamage = (Ready(_R) and getdmg("R",hero,myHero) or 0)
				local damage = QDamage + WDamage + RDamage + EDamage
				if damage > hero.health then
					Draw.Text("KILL NOW", 30, hero.pos2D.x - 50, hero.pos2D.y - 195,Draw.Color(200, 255, 87, 51))				
					else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					--Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, AIO.Drawings.HPColor:Value())
				end
				end
				end
				
		  if Ready(_Q) then
			local target = CurrentTarget(Q.Range)
			if target == nil then return end
			local temppred
			local collisionc = Q.ignorecol and 0 or Q.minionCollisionWidth
			
			if (TPred) then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, Q.ignorecol, Q.Type )
				Draw.Circle(castpos, 60, 3, Draw.Color(200, 255, 255, 255))
			end
end
end

function Orianna:IsImmobileTarget(player)
		if player == nil then return false end
		for i = 0, player.buffCount do
			local buff = player:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24) and buff.count > 0 then
				return true
			end
		end
		return false	
	end

function Orianna:Combo()
    
    if AIO.Combo.UseQ:Value() and target and Ready(_Q) then
	    if EnemyInRange(1300) then
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, Q.ignorecol, Q.Type )
		    if (HitChance > 0 ) then
				Control.CastSpell(HK_Q, castpos)
				--ball_pos = castpos
			end
		    end
	    end
	    end
function Orianna:OriQ()
	target = CurrentTarget(Q.Range)
    if target == nil then return end
	
	if AIO.Combo.UseQ:Value() and target and Ready(_Q) then
		if target.pos:DistanceTo(ball_pos) > 650 and Ready(_E) then 
		Control.CastSpell(HK_E, myHero)
		else
		local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, 1,nil)	
		if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
			Control.CastSpell(HK_Q, aimPosition)
			--ball_pos = aimPosition
			
		end	
		end
	end
end

function Orianna:OriQH()
	target = CurrentTarget(Q.Range)
    if target == nil then return end
	
	if AIO.Harass.UseQ:Value() and target and Ready(_Q) then
	
		local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, 1,nil)	
		if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
			Control.CastSpell(HK_Q, aimPosition)
			--ball_pos = aimPosition
		end	
	end
end

function Orianna:Harass()
    local target = CurrentTarget(Q.Range)
    if target == nil then return end
    if AIO.Harass.UseQ:Value() and target and Ready(_Q) then
	    if EnemyInRange(1300) then
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, Q.ignorecol, Q.Type )
		    if (HitChance > 0 ) then
				Control.CastSpell(HK_Q, castpos)
				--ball_pos = castpos
			end
		    end
	    end
	    end

function Orianna:HarassW()
    local target = CurrentTarget(1300)
    if target == nil then return end
    if AIO.Combo.UseW:Value() and target and Ready(_W) then
			if ball_pos and target.pos:DistanceTo(ball_pos) <= 240 then
				Control.CastSpell(HK_W)
			end
			end
	    end
		
function Orianna:ComboW()
	local target = CurrentTarget(1300)
    if target == nil then return end
    if AIO.Combo.UseW:Value() and target and Ready(_W) then
			if ball_pos and target.pos:DistanceTo(ball_pos) <= 240 then
				Control.CastSpell(HK_W)
			end
			end
			
end
	
function Orianna:BallMe()
	local target = CurrentTarget(300)
    if target == nil then return end
    if AIO.Combo.UseW:Value() and target and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 240 then
				Control.CastSpell(HK_W)
			end
		    end
	    end
function Orianna:EThroughTarget()
	local target = CurrentTarget(1000)
	if target == nil or GotBuff(myHero, "orianaghostself") == 1 or ball_pos == nil then return end
	local lineSegment1 = gsoClosestPointOnLineSegment(target.pos, myHero.pos, ball_pos)
	if AIO.Combo.UseE:Value() and lineSegment1 and Ready(_E) and GotBuff(myHero, "orianaghostself") == 0 and target.dead == false then 
	Control.CastSpell(HK_E, myHero)
	
	end
end
			
		
	    


function Orianna:Clear()
	if Ready(_Q)then
	local qMinions = {}
	local mobs = {}
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  ValidTarget(minion,825)  then
			if minion.team == 300 then
				mobs[#mobs+1] = minion
			elseif minion.isEnemy  then
				qMinions[#qMinions+1] = minion
			end	
	end	
		local BestPos, BestHit = GetBestCircularFarmPosition(825, 240, qMinions)
		
		if BestHit >= AIO.Clear.QCount:Value() and AIO.Clear.UseQ:Value() then
			Control.CastSpell(HK_Q,BestPos)
			
		end
		
	end
end
end

function Orianna:ClearJungle()
	 
	local minionlist = {}
	
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				
				
				if string.find(minion.name, "SRU") then
					if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 825 and Ready(_Q) then
						Control.CastSpell(HK_Q,minion.pos)
					end
					if minion.valid and minion.isEnemy and minion.pos:DistanceTo(ball_pos) < 240 and Ready(_W) then
						Control.CastSpell(HK_W)
					end
					end
				end
end

function Orianna:ClearW()
	if Ready(_W) then
	local qMinions = {}
	local mobs = {}
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  ValidTarget(minion,825)  then
			if minion.team == 300 then
				mobs[#mobs+1] = minion
			elseif minion.isEnemy  then
				qMinions[#qMinions+1] = minion
			end	
	end	
		local BestPos, BestHit = GetBestCircularFarmPosition(825, 240, qMinions)
		if BestHit >= AIO.Clear.WCount:Value() and AIO.Clear.UseW:Value() then
			Control.CastSpell(HK_W)
			
		end
	end
end
end

function Orianna:Lasthit()
	if Ready(_Q) and AIO.Lasthit.UseQ:Value() then
  		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			local Qdamage = Orianna:QDMG()
			if myHero.pos:DistanceTo(minion.pos) < 825 and AIO.Lasthit.UseQ:Value() and minion.isEnemy and not minion.dead then
				if Qdamage >= HpPred(minion,1) then
			    Control.CastSpell(HK_Q,minion)
				end
			end
		end
	end
end

function Orianna:QDMG()
    local level = myHero:GetSpellData(_Q).level
    local qdamage = (({60,90,120,150,180})[level] + 0.5 * myHero.ap)
	return qdamage
end

function Orianna:WDMG()
    local level = myHero:GetSpellData(_W).level
    local wdamage = (({60,105,150,195,240})[level] + 0.7 * myHero.ap)
	return wdamage
end

function Orianna:RDMG()
    local level = myHero:GetSpellData(_R).level
    local rdamage = (({150,225,300})[level] + 0.7 * myHero.ap)
	return rdamage
end



function Orianna:KillstealR()
    local target = CurrentTarget(1300)
	if target == nil then return end
	if AIO.Killsteal.RR["UseR"..target.charName]:Value() and Ready(_R) and target then
		   	local Rdamage = Orianna:RDMG()
			if Rdamage >= HpPred(target,1) + target.hpRegen * 2 then
			if myHero.pos:DistanceTo(target.pos) < 310 and HasBuff(myHero, "orianaghostself") then
			    Control.CastSpell(HK_R)
			else if ball_pos and target.pos:DistanceTo(ball_pos) < 310 then
				Control.CastSpell(HK_R)
			else for i = 1,Game.HeroCount()  do
			local hero = Game.Hero(i)
				if hero.isAlly and HasBuff(hero, "orianaghost") and hero.pos:DistanceTo(target.pos) < 240 then
				Control.CastSpell(HK_R)
			else if not ball then return end
				end
			end
		end
		end
	end
	end
	end
	
	
	




function Orianna:EnemiesNear(pos,range)
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if ValidTarget(hero,range + hero.boundingRadius) and hero.isEnemy and not hero.dead then
			N = N + 1
		end
	end
	return N	
end

function Orianna:EnemiesNearAlly(pos,range)
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if ValidTarget(hero,range + hero.boundingRadius) and hero.isEnemy and not hero.dead then
			N = N + 1
		end
	end
	return N	
end



function Orianna:AutoultMe() 

if AIO.Misc.UseR:Value() and Ready(_R)then
	local Rdamage = Orianna:RDMG()
	if self:EnemiesNear(myHero.pos,300) >= AIO.Misc.RCount:Value() and HasBuff(myHero, "orianaghostself") and Rdamage >= HpPred(target,1) + target.hpRegen * 2 then
		Control.CastSpell(HK_R)
	else if not HasBuff(myHero, "orianaghostself") and self:EnemiesNear(myHero.pos,310) >= AIO.Misc.RCount:Value() and Ready(_E) and Ready(_R) then
		Control.CastSpell(HK_E, myHero)
	end
end
end
end

function Orianna:Autoult1Ally()
	local target = CurrentTarget(E.Range)
	if target == nil then return end
	if AIO.Misc.UseR:Value() and Ready(_R) then
	for i = 1, Game.HeroCount() do
	local hero = Game.Hero(i)
	if hero.isAlly and not hero.isMe then
	if HasBuff(hero, "orianaghost") and self:EnemiesNearAlly(hero.pos,300) >= AIO.Misc.RCount:Value() and target.pos:DistanceTo(hero.pos) < 300 then
		Control.CastSpell(HK_R)
	end
end
end
end
end

function Orianna:AutoultBall()
if AIO.Misc.UseR:Value() and Ready(_R)then
   		local N = 0 
    		for i = 1, Game.HeroCount() do 
    			local hero = Game.Hero(i)
    			if hero.isEnemy and not hero.dead and hero.isTargetable then 
					if hero.pos:DistanceTo(ball_pos) < 310 then 
    					N = N + 1 
    				end
    			end
    		end
    		if N >= AIO.Misc.RCount:Value() then 
    	Control.CastSpell(HK_R)
end
end
end

function Orianna:RKey()
if Ready(_R) then
   	for i = 1, Game.HeroCount() do 
    	local hero = Game.Hero(i)
    	if hero.isEnemy and not hero.dead and hero.isTargetable then 
			if hero.pos:DistanceTo(ball_pos) < 310 then 
     	Control.CastSpell(HK_R)
	elseif HasBuff(myHero, "orianaghost") then
		if myHero.pos:DistanceTo(hero.pos) < 310 then
		Control.CastSpell(HK_R)

end
end
end
end
end
end

function Orianna:getWombos()
	self.DashingHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly then
			table.insert(self.DashingHeroes, Hero)
		end
	end
	return self.DashingHeroes
end

function Orianna:eMovingAlly()
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly then
		if hero.pathing.hasMovePath and hero.pathing.isDashing and hero.pathing.dashSpeed > 500 then 
				for i, allyHero in pairs(self:getWombos()) do 
					if myHero.pos:DistanceTo(hero.pos) < 1100 and Ready(_E) then 
							Control.CastSpell(HK_E,hero.pos)
						end
					end
				end
			end
		end
	end



class "HPred"

Callback.Add("Tick", function() HPred:Tick() end)

local _atan = math.atan2
local _pi = math.pi
local _max = math.max
local _min = math.min
local _abs = math.abs
local _sqrt = math.sqrt
local _find = string.find
local _sub = string.sub
local _len = string.len
	
local _reviveQueryFrequency = .2
local _lastReviveQuery = Game.Timer()
local _reviveLookupTable = 
	{ 
		["LifeAura.troy"] = 4, 
		["ZileanBase_R_Buf.troy"] = 3,
		["Aatrox_Base_Passive_Death_Activate"] = 3
		
		--TwistedFate_Base_R_Gatemarker_Red
			--String match would be ideal.... could be different in other skins
	}

--Stores a collection of spells that will cause a character to blink
	--Ground targeted spells go towards mouse castPos with a maximum range
	--Hero/Minion targeted spells have a direction type to determine where we will land relative to our target (in front of, behind, etc)
	
--Key = Spell name
--Value = range a spell can travel, OR a targeted end position type, OR a list of particles the spell can teleport to	
local _blinkSpellLookupTable = 
	{ 
		["EzrealArcaneShift"] = 475, 
		["RiftWalk"] = 500,
		
		--Ekko and other similar blinks end up between their start pos and target pos (in front of their target relatively speaking)
		["EkkoEAttack"] = 0,
		["AlphaStrike"] = 0,
		
		--Katarina E ends on the side of her target closest to where her mouse was... 
		["KatarinaE"] = -255,
		
		--Katarina can target a dagger to teleport directly to it: Each skin has a different particle name. This should cover all of them.
		["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, 
	}

local _blinkLookupTable = 
	{ 
		"global_ss_flash_02.troy",
		"Lissandra_Base_E_Arrival.troy",
		"LeBlanc_Base_W_return_activation.troy"
		--TODO: Check if liss/leblanc have diff skill versions. MOST likely dont but worth checking for completion sake
		
		--Zed uses 'switch shadows'... It will require some special checks to choose the shadow he's going TO not from...
		--Shaco deceive no longer has any particles where you jump to so it cant be tracked (no spell data or particles showing path)
		
	}

local _cachedRevives = {}
local _cachedTeleports = {}
local _movementHistory = {}

--Cache of all TARGETED missiles currently running
local _cachedMissiles = {}
local _incomingDamage = {}

--Cache of active enemy windwalls so we can calculate it when dealing with collision checks
local _windwall
local _windwallStartPos
local _windwallWidth

function HPred:Tick()
	--Update missile cache
	--DISABLED UNTIL LATER.
	--self:CacheMissiles()
	
	self:CacheParticles()
	
	--Check for revives and record them	
	if Game.Timer() - _lastReviveQuery < _reviveQueryFrequency then return end
	_lastReviveQuery=Game.Timer()
	
	--Remove old cached revives
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	--Cache new revives
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then
			_cachedRevives[particle.networkID] = {}
			_cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = self:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedRevives[particle.networkID]["target"] = target
				_cachedRevives[particle.networkID]["pos"] = target.pos
				_cachedRevives[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
	end
	
	--Update hero movement history	
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		self:UpdateMovementHistory(t)
	end
	
	--Remove old cached teleports	
	for _, teleport in pairs(_cachedTeleports) do
		if Game.Timer() > teleport.expireTime + .5 then
			_cachedTeleports[_] = nil
		end
	end	
	
	--Update teleport cache
	self:CacheTeleports()
	
	
end







-- Thank you Sikaka Amazing HPred Logic
--Will return the valid target who has the highest hit chance and meets all conditions (minHitChance, whitelist check, etc)
function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist)
	local _validTargets = {}
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if self:CanTarget(t) and (not whitelist or whitelist[t.charName]) then			
			local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision)		
			if hitChance >= minimumHitChance then
				_validTargets[t.charName] = {["hitChance"] = hitChance, ["aimPosition"] = aimPosition}
			end
		end
	end
	
	local rHitChance = 0
	local rAimPosition
	for targetName, targetData in pairs(_validTargets) do
		if targetData.hitChance > rHitChance then
			rHitChance = targetData.hitChance
			rAimPosition = targetData.aimPosition
		end		
	end
	
	if rHitChance >= minimumHitChance then
		return rHitChance, rAimPosition
	end	
end

function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision)	
	local hitChance = 1	
	
	local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed)	
	local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed)
	local reactionTime = self:PredictReactionTime(target, .1)
	
	--If they just now changed their path then assume they will keep it for at least a short while... slightly higher chance
	if _movementHistory and _movementHistory[target.charName] and Game.Timer() - _movementHistory[target.charName]["ChangedAt"] < .25 then
		hitChance = 2
	end

	--If they are standing still give a higher accuracy because they have to take actions to react to it
	if not target.pathing or not target.pathing.hasMovePath then
		hitChance = 2
	end	
	
	
	local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)
	--Our spell is so wide or the target so slow or their reaction time is such that the spell will be nearly impossible to avoid
	if movementRadius - target.boundingRadius <= radius /2 then
		origin,movementRadius = self:UnitMovementBounds(target, interceptTime, 0)
		if movementRadius - target.boundingRadius <= radius /2 then
			hitChance = 4
		else		
			hitChance = 3
		end
	end	
	
	--If they are casting a spell then the accuracy will be fairly high. if the windup is longer than our delay then it's quite likely to hit. 
	--Ideally we would predict where they will go AFTER the spell finishes but that's beyond the scope of this prediction
	if target.activeSpell and target.activeSpell.valid then
		if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then
			hitChance = 5
		else			
			hitChance = 3
		end
	end
	
	--Check for out of range
	if not self:IsInRange(myHero.pos, aimPosition, range) then
		hitChance = -1
	end
	
	--Check minion block
	if hitChance > 0 and checkCollision then
		if self:IsWindwallBlocking(source, aimPosition) then
			hitChance = -1		
		elseif self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then
			hitChance = -1
		end
	end
	
	return hitChance, aimPosition
end

function HPred:PredictReactionTime(unit, minimumReactionTime)
	local reactionTime = minimumReactionTime
	
	--If the target is auto attacking increase their reaction time by .15s - If using a skill use the remaining windup time
	if unit.activeSpell and unit.activeSpell.valid then
		local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer()
		if windupRemaining > 0 then
			reactionTime = windupRemaining
		end
	end
	
	return reactionTime
end

function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)

	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
			local dashEndPosition = t:GetPath(1)
			if self:IsInRange(source, dashEndPosition, range) then				
				--The dash ends within range of our skill. We now need to find if our spell can connect with them very close to the time their dash will end
				local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = self:GetSpellInterceptTime(myHero.pos, dashEndPosition, delay, speed)
				local deltaInterceptTime =skillInterceptTime - dashTimeRemaining
				if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then
					target = t
					aimPosition = dashEndPosition
					return target, aimPosition
				end
			end			
		end
	end
end

function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t.isEnemy then		
			local success, timeRemaining = self:HasBuff(t, "zhonyasringshield")
			if success then
				local spellInterceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed)
				local deltaInterceptTime = spellInterceptTime - timeRemaining
				if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = t
					aimPosition = t.pos
					return target, aimPosition
				end
			end
		end
	end
end

function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for _, revive in pairs(_cachedRevives) do	
		if revive.isEnemy then
			local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed)
			if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then
				target = revive.target
				aimPosition = revive.pos
				return target, aimPosition
			end
		end
	end	
end

function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then
			local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer()
			if windupRemaining > 0 then
				local endPos
				local blinkRange = _blinkSpellLookupTable[t.activeSpell.name]
				if type(blinkRange) == "table" then
					--Find the nearest matching particle to our mouse
					--local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange)
					--if target and distance < 240 then					
					--	endPos = target.pos		
					--end
				elseif blinkRange > 0 then
					endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z)					
					endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * _min(self:GetDistance(t.activeSpell.startPos,endPos), range)
				else
					local blinkTarget = self:GetObjectByHandle(t.activeSpell.target)
					if blinkTarget then				
						local offsetDirection						
						
						--We will land in front of our target relative to our starting position
						if blinkRange == 0 then						
							offsetDirection = (blinkTarget.pos - t.pos):Normalized()
						--We will land behind our target relative to our starting position
						elseif blinkRange == -1 then						
							offsetDirection = (t.pos-blinkTarget.pos):Normalized()
						--They can choose which side of target to come out on , there is no way currently to read this data so we will only use this calculation if the spell radius is large
						elseif blinkRange == -255 then
							if radius > 240 then
								endPos = blinkTarget.pos
							end							
						end
						
						if offsetDirection then
							endPos = blinkTarget.pos - offsetDirection * 150
						end
						
					end
				end	
				
				local interceptTime = self:GetSpellInterceptTime(myHero.pos, endPos, delay,speed)
				local deltaInterceptTime = interceptTime - windupRemaining
				if self:IsInRange(source, endPos, range) and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then
					target = t
					aimPosition = endPos
					return target,aimPosition					
				end
			end
		end
	end
end

function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if particle and _blinkLookupTable[particle.name] and self:IsInRange(source, particle.pos, range) then
			local pPos = particle.pos
			for k,v in pairs(self:GetEnemyHeroes()) do
				local t = v
				if t and t.isEnemy and self:IsInRange(t.pos, pPos, t.boundingRadius) then
					if (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then
						target = t
						aimPosition = pPos
						return target,aimPosition
					end
				end
			end
		end
	end
end

function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		local interceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed)
		if self:CanTarget(t) and self:IsInRange(source, t.pos, range) and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
			target = t
			aimPosition = t.pos	
			return target, aimPosition
		end
	end
end

function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if self:CanTarget(t) and self:IsInRange(source, t.pos, range) then
			local immobileTime = self:GetImmobileTime(t)
			
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos
				return target, aimPosition
			end
		end
	end
end

function HPred:CacheTeleports()
	--Get enemies who are teleporting to towers
	for i = 1, Game.TurretCount() do
		local turret = Game.Turret(i);
		if turret.isEnemy and not _cachedTeleports[turret.networkID] then
			local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target")
			if hasBuff then
				self:RecordTeleport(turret, self:GetTeleportOffset(turret.pos,223.31),expiresAt)
			end
		end
	end	
	
	--Get enemies who are teleporting to wards	
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i);
		if ward.isEnemy and not _cachedTeleports[ward.networkID] then
			local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target")
			if hasBuff then
				self:RecordTeleport(ward, self:GetTeleportOffset(ward.pos,100.01),expiresAt)
			end
		end
	end
	
	--Get enemies who are teleporting to minions
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i);
		if minion.isEnemy and not _cachedTeleports[minion.networkID] then
			local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target")
			if hasBuff then
				self:RecordTeleport(minion, self:GetTeleportOffset(minion.pos,143.25),expiresAt)
			end
		end
	end	
end

function HPred:RecordTeleport(target, aimPos, endTime)
	_cachedTeleports[target.networkID] = {}
	_cachedTeleports[target.networkID]["target"] = target
	_cachedTeleports[target.networkID]["aimPos"] = aimPos
	_cachedTeleports[target.networkID]["expireTime"] = endTime + Game.Timer()
end


function HPred:CalculateIncomingDamage()
	_incomingDamage = {}
	local currentTime = Game.Timer()
	for _, missile in pairs(_cachedMissiles) do	
		local dist = self:GetDistance(missile.data.pos, missile.target.pos)			
		if missile.name == "" then
			_cachedMissiles[_] = nil
		else
			if not _incomingDamage[missile.target.networkID] then
				_incomingDamage[missile.target.networkID] = missile.damage
			else
				_incomingDamage[missile.target.networkID] = _incomingDamage[missile.target.networkID] + missile.damage
			end
		end
	end	
end

function HPred:GetIncomingDamage(target)
	local damage = 0
	if _incomingDamage[target.networkID] then
		damage = _incomingDamage[target.networkID]
	end
	return damage
end


local _maxCacheRange = 3000

--Right now only used to cache enemy windwalls
function HPred:CacheParticles()	
	if _windwall and _windwall.name == "" then
		_windwall = nil
	end
	
	for i = 1, Game.ParticleCount() do
		local particle = Game.Particle(i)		
		if self:IsInRange(particle.pos, myHero.pos, _maxCacheRange) then			
			if _find(particle.name, "W_windwall%d") and not _windwall then
				--We don't care about ally windwalls for now
				local owner =  self:GetObjectByHandle(particle.handle)
				if owner and owner.isEnemy then
					_windwall = particle
					_windwallStartPos = Vector(particle.pos.x, particle.pos.y, particle.pos.z)				
					
					local index = _len(particle.name) - 5
					local spellLevel = _sub(particle.name, index, index) -1 
					_windwallWidth = 150 + spellLevel * 25					
				end
			end
		end
	end
end

function HPred:CacheMissiles()
	local currentTime = Game.Timer()
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i)
		--Check if there is a target for it
		if not _cachedMissiles[missile.networkID] and missile.missileData and missile.missileData.target and missile.missileData.owner then
			local missileName = missile.missileData.name
			local owner =  self:GetObjectByHandle(missile.missileData.owner)	
			local target =  self:GetObjectByHandle(missile.missileData.target)		
			if owner and target and _find(target.type, "Hero") then			
				--The missile is an auto attack of some sort that is targeting a player	
				if (_find(missileName, "BasicAttack") or _find(missileName, "CritAttack")) then
					--Cache it all and update the count
					_cachedMissiles[missile.networkID] = {}
					_cachedMissiles[missile.networkID].target = target
					_cachedMissiles[missile.networkID].data = missile
					_cachedMissiles[missile.networkID].timeout = currentTime + 1.5
					
					local damage = owner.totalDamage
					if _find(missileName, "CritAttack") then
						--Leave it rough we're not that concerned
						damage = damage * 1.5
					end
					_cachedMissiles[missile.networkID].damage = self:CalculatePhysicalDamage(target, damage)
				end
			end
		end
	end
end

function HPred:CalculatePhysicalDamage(target, damage)			
	local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
	local damageReduction = 100 / ( 100 + targetArmor)
	if targetArmor < 0 then
		damageReduction = 2 - (100 / (100 - targetArmor))
	end		
	damage = damage * damageReduction	
	return damage
end

function HPred:CalculateMagicDamage(target, damage)			
	local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
	local damageReduction = 100 / ( 100 + targetMR)
	if targetMR < 0 then
		damageReduction = 2 - (100 / (100 - targetMR))
	end		
	damage = damage * damageReduction
	
	return damage
end


function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)

	local target
	local aimPosition
	for _, teleport in pairs(_cachedTeleports) do
		if teleport.expireTime > Game.Timer() and self:IsInRange(source,teleport.aimPos, range) then			
			local spellInterceptTime = self:GetSpellInterceptTime(source, teleport.aimPos, delay, speed)
			local teleportRemaining = teleport.expireTime - Game.Timer()
			if spellInterceptTime > teleportRemaining and spellInterceptTime - teleportRemaining <= timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, teleport.aimPos, delay, speed, radius)) then								
				target = teleport.target
				aimPosition = teleport.aimPos
				return target, aimPosition
			end
		end
	end		
end

function HPred:GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function HPred:Angle(A, B)
	local deltaPos = A - B
	local angle = _atan(deltaPos.x, deltaPos.z) *  180 / _pi	
	if angle < 0 then angle = angle + 360 end
	return angle
end

function HPred:UpdateMovementHistory(unit)
	if not _movementHistory[unit.charName] then
		_movementHistory[unit.charName] = {}
		_movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos
		_movementHistory[unit.charName]["StartPos"] = unit.pathing.endPos
		_movementHistory[unit.charName]["PreviousAngle"] = 0
		_movementHistory[unit.charName]["ChangedAt"] = Game.Timer()
	end
	
	if _movementHistory[unit.charName]["EndPos"].x ~=unit.pathing.endPos.x or _movementHistory[unit.charName]["EndPos"].y ~=unit.pathing.endPos.y or _movementHistory[unit.charName]["EndPos"].z ~=unit.pathing.endPos.z then				
		_movementHistory[unit.charName]["PreviousAngle"] = self:Angle(Vector(_movementHistory[unit.charName]["StartPos"].x, _movementHistory[unit.charName]["StartPos"].y, _movementHistory[unit.charName]["StartPos"].z), Vector(_movementHistory[unit.charName]["EndPos"].x, _movementHistory[unit.charName]["EndPos"].y, _movementHistory[unit.charName]["EndPos"].z))
		_movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos
		_movementHistory[unit.charName]["StartPos"] = unit.pos
		_movementHistory[unit.charName]["ChangedAt"] = Game.Timer()
	end
	
end

--Returns where the unit will be when the delay has passed given current pathing information. This assumes the target makes NO CHANGES during the delay.
function HPred:PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			--This node of the path will be completed before the delay has finished. Move on to the next node if one remains
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function HPred:IsChannelling(target, interceptTime)
	if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then
		return true
	end
end

function HPred:HasBuff(target, buffName, minimumDuration)
	local duration = minimumDuration
	if not minimumDuration then
		duration = 0
	end
	local durationRemaining
	for i = 1, target.buffCount do 
		local buff = target:GetBuff(i)
		if buff.duration > duration and buff.name == buffName then
			durationRemaining = buff.duration
			return true, durationRemaining
		end
	end
end

--Moves an origin towards the enemy team nexus by magnitude
function HPred:GetTeleportOffset(origin, magnitude)
	local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude
	return teleportOffset
end

function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed
	return interceptTime
end

--Checks if a target can be targeted by abilities or auto attacks currently.
--CanTarget(target)
	--target : gameObject we are trying to hit
function HPred:CanTarget(target)
	return target.isEnemy and target.alive and target.visible and target.isTargetable
end

--Derp: dont want to fuck with the isEnemy checks elsewhere. This will just let us know if the target can actually be hit by something even if its an ally
function HPred:CanTargetALL(target)
	return target.alive and target.visible and target.isTargetable
end

--Returns a position and radius in which the target could potentially move before the delay ends. ReactionTime defines how quick we expect the target to be able to change their current path
function HPred:UnitMovementBounds(unit, delay, reactionTime)
	local startPosition = self:PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = self:GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end

--Returns how long (in seconds) the target will be unable to move from their current location
function HPred:GetImmobileTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
			duration = buff.duration
		end
	end
	return duration		
end

--Returns how long (in seconds) the target will be slowed for
function HPred:GetSlowedTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration > duration and buff.type == 10 then
			duration = buff.duration			
			return duration
		end
	end
	return duration		
end

--Returns all existing path nodes
function HPred:GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

--Finds any game object with the correct handle to match (hero, minion, wards on either team)
function HPred:GetObjectByHandle(handle)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.handle == handle then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.handle == handle then
			target = minion
			return target
		end
	end
	
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i);
		if ward.handle == handle then
			target = ward
			return target
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if particle.handle == handle then
			target = particle
			return target
		end
	end
end

function HPred:GetHeroByPosition(position)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetObjectByPosition(position)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.MinionCount() do
		local enemy = Game.Minion(i)
		if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.WardCount() do
		local enemy = Game.Ward(i);
		if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local enemy = Game.Particle(i)
		if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetEnemyHeroByHandle(handle)	
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.handle == handle then
			target = enemy
			return target
		end
	end
end

--Finds the closest particle to the origin that is contained in the names array
function HPred:GetNearestParticleByNames(origin, names)
	local target
	local distance = 999999
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		local d = self:GetDistance(origin, particle.pos)
		if d < distance then
			distance = d
			target = particle
		end
	end
	return target, distance
end

--Returns the total distance of our current path so we can calculate how long it will take to complete
function HPred:GetPathLength(nodes)
	local result = 0
	for i = 1, #nodes -1 do
		result = result + self:GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end


--I know this isn't efficient but it works accurately... Leaving it for now.
function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)
		
	if not frequency then
		frequency = radius
	end
	local directionVector = (endPos - origin):Normalized()
	local checkCount = self:GetDistance(origin, endPos) / frequency
	for i = 1, checkCount do
		local checkPosition = origin + directionVector * i * frequency
		local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed
		if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
			return true
		end
	end
	return false
end


function HPred:IsMinionIntersection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 500
	end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if self:CanTarget(minion) and self:IsInRange(minion.pos, location, maxDistance) then
			local predictedPosition = self:PredictUnitPosition(minion, delay)
			if self:IsInRange(location, predictedPosition, radius + minion.boundingRadius) then
				return true
			end
		end
	end
	return false
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

--Determines if there is a windwall between the source and target pos. 
function HPred:IsWindwallBlocking(source, target)
	if _windwall then
		local windwallFacing = (_windwallStartPos-_windwall.pos):Normalized()
		return self:DoLineSegmentsIntersect(source, target, _windwall.pos + windwallFacing:Perpendicular() * _windwallWidth, _windwall.pos + windwallFacing:Perpendicular2() * _windwallWidth)
	end	
	return false
end
--Returns if two line segments cross eachother. AB is segment 1, CD is segment 2.
function HPred:DoLineSegmentsIntersect(A, B, C, D)

	local o1 = self:GetOrientation(A, B, C)
	local o2 = self:GetOrientation(A, B, D)
	local o3 = self:GetOrientation(C, D, A)
	local o4 = self:GetOrientation(C, D, B)
	
	if o1 ~= o2 and o3 ~= o4 then
		return true
	end
	
	if o1 == 0 and self:IsOnSegment(A, C, B) then return true end
	if o2 == 0 and self:IsOnSegment(A, D, B) then return true end
	if o3 == 0 and self:IsOnSegment(C, A, D) then return true end
	if o4 == 0 and self:IsOnSegment(C, B, D) then return true end
	
	return false
end

--Determines the orientation of ordered triplet
--0 = Colinear
--1 = Clockwise
--2 = CounterClockwise
function HPred:GetOrientation(A,B,C)
	local val = (B.z - A.z) * (C.x - B.x) -
		(B.x - A.x) * (C.z - B.z)
	if val == 0 then
		return 0
	elseif val > 0 then
		return 1
	else
		return 2
	end
	
end

function HPred:IsOnSegment(A, B, C)
	return B.x <= _max(A.x, C.x) and 
		B.x >= _min(A.x, C.x) and
		B.z <= _max(A.z, C.z) and
		B.z >= _min(A.z, C.z)
end

--Gets the slope between two vectors. Ignores Y because it is non-needed height data. Its all 2d math.
function HPred:GetSlope(A, B)
	return (B.z - A.z) / (B.x - A.x)
end

function HPred:GetEnemyByName(name)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.isEnemy and enemy.charName == name then
			target = enemy
			return target
		end
	end
end

function HPred:IsPointInArc(source, origin, target, angle, range)
	local deltaAngle = _abs(HPred:Angle(origin, target) - HPred:Angle(source, origin))
	if deltaAngle < angle and self:IsInRange(origin,target,range) then
		return true
	end
end

function HPred:GetEnemyHeroes()
	local _EnemyHeroes = {}
  	for i = 1, Game.HeroCount() do
    	local enemy = Game.Hero(i)
    	if enemy and enemy.isEnemy then
	  		table.insert(_EnemyHeroes, enemy)
  		end
  	end
  	return _EnemyHeroes
end

function HPred:GetDistanceSqr(p1, p2)	
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function HPred:IsInRange(p1, p2, range)
	return range * range >= (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function HPred:GetDistance(p1, p2)
	return _sqrt(self:GetDistanceSqr(p1, p2))
end

