-- Required scripts
local pokemonParts = require("lib.GroupIndex")(models.models.CharizardTaur)
local itemCheck    = require("lib.ItemCheck")

-- Config setup
config:name("CharizardTaur")
local shiny = config:load("ColorShiny") or false

-- All shiny parts
local shinyParts = {
	
	pokemonParts.HornsLeft.Horn,
	pokemonParts.HornsRight.Horn,
	pokemonParts.HornsSkullLeft.Horn,
	pokemonParts.HornsSkullRight.Horn,
	
	pokemonParts.Merge.Merge,
	pokemonParts.Torso.Torso,
	
	pokemonParts.LowerLeftArm.Arm,
	pokemonParts.LeftForearm.Arm,
	pokemonParts.LeftFingerF.Finger,
	pokemonParts.LeftFingerM.Finger,
	pokemonParts.LeftFingerB.Finger,
	
	pokemonParts.LowerRightArm.Arm,
	pokemonParts.RightForearm.Arm,
	pokemonParts.RightFingerF.Finger,
	pokemonParts.RightFingerM.Finger,
	pokemonParts.RightFingerB.Finger,
	
	pokemonParts.LeftWing1,
	pokemonParts.RightWing1,
	
	pokemonParts.Hips.Hips,
	pokemonParts.leftLeg.Leg,
	pokemonParts.LeftFoot.Foot,
	pokemonParts.rightLeg.Leg,
	pokemonParts.RightFoot.Foot,
	
	pokemonParts.Tail1.Tail,
	pokemonParts.Tail2.Tail,
	pokemonParts.Tail3.Tail
	
}

-- Table setup
local t = {}

function events.TICK()
	
	-- Set colors
	t.hover     = vectors.hexToRGB(shiny and "46454F" or "D8741E")
	t.active    = vectors.hexToRGB(shiny and "791E36" or "1E7A73")
	t.primary   = (shiny and "§8" or "§6").."§l"
	t.secondary = shiny and "§4" or "§3"
	
	-- Shiny textures
	local textureType = shiny and textures["textures.charizard_shiny"] or textures["textures.charizard"]
	for _, part in ipairs(shinyParts) do
		part:primaryTexture("Custom", textureType)
	end
	
	-- Glowing outline
	renderer:outlineColor(vectors.hexToRGB(shiny and "46454F" or "D8741E"))
	
	-- Avatar color
	avatar:color(vectors.hexToRGB(shiny and "46454F" or "D8741E"))
	
end

-- Shiny toggle
local function setShiny(boolean)
	
	shiny = boolean
	config:save("ColorShiny", shiny)
	if player:isLoaded() and shiny then
		sounds:playSound("block.amethyst_block.chime", player:getPos())
	end
	
end

-- Sync variables
local function syncColor(a)
	
	shiny = a
	
end

-- Pings setup
pings.setColorShiny = setShiny
pings.syncColor     = syncColor

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncColor(shiny)
		end
		
	end
end

-- Activate actions
setShiny(shiny)

t.shinyPage = action_wheel:newAction("ModelShiny")
	:item(itemCheck("gunpowder"))
	:toggleItem(itemCheck("glowstone_dust"))
	:onToggle(pings.setColorShiny)
	:toggled(shiny)

-- Update action page info
function events.TICK()
	
	t.shinyPage
		:title(t.primary.."Toggle Shiny Textures\n\n"..t.secondary.."Set the lower body to use shiny textures over the default textures.")
		:hoverColor(t.hover)
		:toggleColor(t.active)
	
end

return t