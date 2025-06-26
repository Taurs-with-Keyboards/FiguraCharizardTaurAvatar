-- Required script
local parts = require("lib.PartsAPI")

-- Config setup
config:name("CharizardTaur")
local shiny = config:load("ShinyToggle") == nil and vec(client.uuidToIntArray(avatar:getUUID())).x % 4096 == 0 or config:load("ShinyToggle")

-- All shiny parts
local shinyParts = parts:createTable(function(part) return part:getName():find("_[sS]hiny") end)

-- Variables
local wasShiny = not shiny
local initAvatarColor = vectors.hexToRGB(avatar:getColor() or "default")
local initGlowColor = renderer:getOutlineColor() or vec(1, 1, 1)

-- Textures
local normalTex = textures["textures.charizard"]       or textures["CharizardTaur.charizard"]
local shinyTex  = textures["textures.charizard_shiny"] or textures["CharizardTaur.charizard_shiny"]

function events.RENDER(delta, context)
	
	-- Shiny textures
	if shiny ~= wasShiny then
		for _, part in ipairs(shinyParts) do
			part:primaryTexture("CUSTOM", shiny and shinyTex or normalTex)
		end
	end
	
	-- Store data
	wasShiny = shiny
	
	-- Avatar color
	avatar:color(shiny and vectors.hexToRGB("46454F") or initAvatarColor)
	
	-- Glowing outline
	renderer:outlineColor(shiny and vectors.hexToRGB("46454F") or initGlowColor)
	
end

-- Shiny toggle
function pings.setShinyToggle(boolean)
	
	shiny = boolean
	config:save("ShinyToggle", shiny)
	if player:isLoaded() and shiny then
		sounds:playSound("block.amethyst_block.chime", player:getPos())
	end
	
end

-- Sync variable
function pings.syncShiny(a)
	
	shiny = a
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncShiny(shiny)
	end
	
end

-- Required scripts
local s, wheel, itemCheck, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Pokeball") -- Tries to find script, not required

if c ~= {} then
	
	-- Store init colors
	local temp = {}
	temp.hover     = c.hover
	temp.active    = c.active
	temp.primary   = c.primary
	temp.secondary = c.secondary
	
	function events.RENDER(delta, context)
		
		-- Update action wheel colors
		c.hover     = shiny and vectors.hexToRGB("46454F") or temp.hover
		c.active    = shiny and vectors.hexToRGB("791E36") or temp.active
		c.primary   = shiny and "#791E36" or temp.primary
		c.secondary = shiny and "#46454F" or temp.secondary
		
	end
	
end

-- Check for if page already exists
local pageExists = action_wheel:getPage("Charizard")

-- Pages
local parentPage    = action_wheel:getPage("Main")
local charizardPage = pageExists or action_wheel:newPage("Charizard")

-- Actions table setup
local a = {}

-- Actions
if not pageExists then
	a.pageAct = parentPage:newAction()
		:item(itemCheck("cobblemon:fire_stone", "campfire"))
		:onLeftClick(function() wheel:descend(charizardPage) end)
end

a.shinyAct = charizardPage:newAction()
	:item(itemCheck("gunpowder"))
	:toggleItem(itemCheck("glowstone_dust"))
	:onToggle(pings.setShinyToggle)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Charizard Settings", bold = true, color = c.primary}
				))
		end
		
		a.shinyAct
			:title(toJson(
				{
					"",
					{text = "Toggle Shiny Textures\n\n", bold = true, color = c.primary},
					{text = "Toggles the usage of shiny textures for your pokemon parts.", color = c.secondary}
				}
			))
			:toggled(shiny)
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end