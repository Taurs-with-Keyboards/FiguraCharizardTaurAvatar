-- Required scripts
local parts  = require("lib.GroupIndex")(models)
local ground = require("lib.GroundCheck")

-- Config setup
config:name("CharizardTaur")
local fallSound = config:load("FallSoundToggle")
if fallSound == nil then fallSound = true end

-- Variables setup
local wasInAir = false

-- Get the average of a vector
local function average(vec)
	
	local sum = 0
	for _, v in ipairs{vec:unpack()} do
		sum = sum + v
	end
	return sum / #vec
	
end

function events.TICK()
	
	-- Play sound if conditions are met
	if fallSound and wasInAir and ground() and not player:getVehicle() and not player:isInWater() then
		if average(parts.Pokeball:getScale()) > 0.5 then
			sounds:playSound("cobblemon:poke_ball.hit", player:getPos(), 0.25)
		end
	end
	wasInAir = not ground()
	
end

-- Sound toggle
local function setToggle(boolean)

	fallSound = boolean
	config:save("FallSoundToggle", fallSound)
	if host:isHost() and player:isLoaded() and fallSound then
		sounds:playSound("cobblemon:poke_ball.hit", player:getPos(), 0.25)
	end
	
end

-- Sync variables
local function syncFallSound(a)
	
	fallSound = a
	
end

-- Pings setup
pings.setFallSoundToggle = setToggle
pings.syncFallSound      = syncFallSound

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncFallSound(fallSound)
		end
		
	end
end

-- Activate actions
setToggle(fallSound)

-- Table setup
local t = {}

-- Action wheel pages
t.soundPage = action_wheel:newAction("FallSound")
	:title("§6§lToggle Falling Sound\n\n§3Toggles pokeball sound effects when landing on the ground.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:snowball")
	:toggleItem("minecraft:fire_charge")
	:onToggle(pings.setFallSoundToggle)
	:toggled(fallSound)

-- Return action wheel pages
return t