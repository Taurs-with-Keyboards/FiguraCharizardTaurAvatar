-- Required scripts
local parts   = require("lib.GroupIndex")(models)
local origins = require("lib.OriginsAPI")

function events.TICK()
	
	local power = origins.hasPower(player, "origins:charizard_fire_type")
	renderer:setRenderFire(not power)
	
end