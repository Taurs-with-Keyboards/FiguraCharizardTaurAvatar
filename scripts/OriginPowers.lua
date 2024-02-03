-- Required scripts
require("lib.GSAnimBlend")
local parts   = require("scripts.ModelParts")
local origins = require("lib.OriginsAPI")

-- Animations setup
local anims = animations.CharizardTaur

local t = {
	createLight = false,
	shootFire   = false,
	flapWings   = false
}

function events.TICK()
	
end

function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, category, path)
	if player:isLoaded() then
		local atPos  = pos < player:getPos() + 5 and pos > player:getPos() - 5
		local flapID = id == "minecraft:entity.ender_dragon.flap"
		t.flapWings  = atPos and flapID and path and true or false
	end
end

return t