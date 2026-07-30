-- Required scripts
local parts = require("lib.PartsAPI")
local sync  = require("lib.LetThatSyncFig")

-- Synced variables setup
local shiny = sync.new("ShinyToggle", vec(client.uuidToIntArray(avatar:getUUID())).x % 4096 == 0):config()

-- All shiny parts
local shinyParts = parts:createTable(function(part) return part:getName():find("_[sS]hiny") end)

-- Variables
local wasShiny = not shiny.curr
local initAvatarColor = vectors.hexToRGB(avatar:getColor() or "default")
local initGlowColor = renderer:getOutlineColor() or vec(1, 1, 1)

-- Textures
local normalTex = textures["textures.charizard"]       or textures["CharizardTaur.charizard"]
local shinyTex  = textures["textures.charizard_shiny"] or textures["CharizardTaur.charizard_shiny"]

function events.RENDER(delta, context)
	
	-- Shiny textures
	if shiny.curr ~= wasShiny then
		for _, part in ipairs(shinyParts) do
			part:primaryTexture("CUSTOM", shiny.curr and shinyTex or normalTex)
		end
	end
	
	-- Store data
	wasShiny = shiny.curr
	
	-- Avatar color
	avatar:color(shiny.curr and vectors.hexToRGB("46454F") or initAvatarColor)
	
	-- Glowing outline
	renderer:outlineColor(shiny.curr and vectors.hexToRGB("46454F") or initGlowColor)
	
end

-- Apply sound function
shiny:applyFunc(function()
	if player:isLoaded() and shiny.curr then
		sounds:playSound("block.amethyst_block.chime", player:getPos())
	end
end)

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, pageNav, acts, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Pokeball") -- Tries to find script, not required

-- Dont preform if color properties is empty
if next(c) ~= nil then
	
	-- Store init colors
	local initColors = {}
	for k, v in pairs(c) do
		initColors[k] = v
	end
	
	-- Create shiny colors
	local shinyColors = {
		hover     = vectors.hexToRGB("46454F"),
		active    = vectors.hexToRGB("791E36"),
		primary   = "#791E36",
		secondary = "#46454F"
	}
	
	-- Update action wheel colors
	function events.RENDER(delta, context)
		
		for k in pairs(c) do
			c[k] = shiny.curr and shinyColors[k] or initColors[k]
		end
		
	end
	
end

-- Check for if page already exists
local pageExists = action_wheel:getPage("Charizard")

-- Pages
local parentPage    = action_wheel:getPage("Main")
local charizardPage = pageExists or action_wheel:newPage("Charizard")

-- Actions
if not pageExists then
	acts.charizardPage = parentPage:newAction()
		:item("cobblemon:fire_stone", "campfire")
		:onLeftClick(function() pageNav.descend(charizardPage) end)
end

acts.shinyToggle = charizardPage:newAction()
	:item("gunpowder")
	:toggleItem("glowstone_dust")
	:onToggle(function(bool)
		shiny:update(bool)
	end)
	:toggled(shiny.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if acts.charizardPage then
			acts.charizardPage
				:title(toJson(
					{text = "Charizard Settings", bold = true, color = c.primary}
				))
				:hoverColor(c.hover)
		end
		
		acts.shinyToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Shiny Textures\n\n", bold = true, color = c.primary},
					{text = "Toggles the usage of shiny textures for your pokemon parts.", color = c.secondary}
				}
			))
			:hoverColor(c.hover)
			:toggleColor(c.active)
		
	end
	
end