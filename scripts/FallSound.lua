-- Required scripts
local pokeballParts = require("lib.GroupIndex")(models.models.Pokeball)
local ground        = require("lib.GroundCheck")
local average       = require("lib.Average")
local itemCheck     = require("lib.ItemCheck")
local effects       = require("scripts.SyncedVariables")
local color         = require("scripts.ColorProperties")

-- Config setup
config:name("CharizardTaur")
local fallSound = config:load("FallSoundToggle")
if fallSound == nil then fallSound = true end

-- Variables setup
local wasInAir = false

function events.TICK()
	
	-- Play sound if conditions are met
	if fallSound and wasInAir and ground() and not player:getVehicle() and not player:isInWater() and not effects.cF then
		if average(pokeballParts.Pokeball:getScale():unpack()) >= 0.5 then
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
		sounds:playSound("cobblemon:poke_ball.hit", player:getPos(), 0.35)
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
t.soundPage = action_wheel:newAction()
	:item(itemCheck("snowball"))
	:toggleItem(itemCheck("cobblemon:luxury_ball", "ender_pearl"))
	:onToggle(pings.setFallSoundToggle)
	:toggled(fallSound)

function events.TICK()
	
	t.soundPage
		:title(toJson(
			{
				"",
				{text = "Toggle Falling Sound\n\n", bold = true, color = color.primary},
				{text = "Toggles pokeball sound effects when landing on the ground.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
end

-- Return action wheel pages
return t