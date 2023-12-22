-- Model setup
local model    = models.CharizardTaur
local fireRoot = model.Player.LowerBody.Tail1.Tail2.Tail3

-- Variable setup
local origins = require("lib.OriginsAPI")
local timer   = 200

local scaleCurrent, scaleNextTick, scaleTarget, scaleCurrentPos = 1, 1, 1, 1
local glowCurrent,  glowNextTick,  glowTarget,  glowCurrentPos  = 1, 1, 1, 1

function events.TICK()
	
	-- Increase Timer
	timer = timer + 1
	if player:isWet() then timer = 0 end
	if player:isOnFire() then timer = 200 end
	
	-- Sets model light to match fire tail
	if origins.hasPower(player, "origins:charizard_light") then
		model:light(fire and 15 or nil)
	else
		model:light(nil)
	end
	
	if timer <= 200 then
		scaleCurrent, scaleNextTick, scaleTarget, scaleCurrentPos = 0, 0, 0, 0
	end
	
	-- Lerps
	scaleCurrent, glowCurrent = scaleNextTick, glowNextTick
	scaleNextTick = math.lerp(scaleNextTick, scaleTarget, 0.05)
	glowNextTick  = math.lerp(glowNextTick,  glowTarget,  0.25)
end

function events.RENDER(delta, context)
	
	log(player:getExperienceLevel())
	local exp = math.map(math.clamp(player:getExperienceLevel(), 0, 30), 0, 30, 0.5, 1.5)
	
	scaleTarget = timer <= 200 and 0 or exp
	scaleCurrentPos = math.lerp(scaleCurrent, scaleNextTick, delta)
	
	glowTarget  = 1
	glowCurrentPos  = math.lerp(glowCurrent,  glowNextTick,  delta)
	
	fireRoot.Fire
		:scale(scaleCurrentPos)
end