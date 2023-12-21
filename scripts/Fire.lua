-- Model setup
local model    = models.CharizardTaur
local fireRoot = model.Player.LowerBody.Tail.Tail.Tail

-- Variable setup
local squapi  = require("lib.SquAPI")
local origins = require("lib.OriginsAPI")
local timer   = 200
local fire    = true
local fireCurrent, fireNextTick, fireTarget, fireCurrentPos = 1, 1, 1, 1

function events.TICK()
	-- Increase Timer
	timer = timer + 1
	if player:isWet() then timer = 0 end
	if player:isOnFire() then timer = 200 end
	
	fire = timer >= 200
	
	if origins.hasPower(player, "origins:charizard_light") then
		model:light(fire and 15 or nil)
	else
		model:light(nil)
	end
	
	-- Fire lerp
	fireCurrent  = fireNextTick
	fireNextTick = math.lerp(fireNextTick, fireTarget, 0.25)
end

function events.RENDER(delta, context)
	-- Fire target and lerp
	fireTarget     = fire and 1 or 0
	fireCurrentPos = math.lerp(fireCurrent, fireNextTick, delta)
	
	-- Apply fire
	fireRoot:secondaryColor(fireCurrentPos)
	fireRoot.Fire:visible(fire)
end