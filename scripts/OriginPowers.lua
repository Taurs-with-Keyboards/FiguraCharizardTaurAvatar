-- Required scripts
local origins = require("lib.OriginsAPI")

function events.TICK()
	
	-- Check if the fireproofing power is active
	local power = origins.hasPower(player, "charizard:charizard_fire_type")
	renderer:setRenderFire(not power)
	
end