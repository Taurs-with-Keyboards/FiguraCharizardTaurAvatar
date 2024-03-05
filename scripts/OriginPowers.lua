-- Required scripts
local origins = require("lib.OriginsAPI")

function events.TICK()
	
	local power = origins.hasPower(player, "charizard:charizard_fire_type")
	renderer:setRenderFire(not power)
	
end