-- Required scripts
local parts = require("lib.PartsAPI")
local sync  = require("lib.LetThatSyncFig")

-- Parts setup
local charizard = parts.new(models.CharizardTaur)

-- Synced variables setup
local skin = sync.new("AvatarVanillaSkin", true):config()
local slim = sync.new("AvatarSlim", false):config()

-- Skull setup
charizard:deepCopy(charizard.outliner.Head)
	:moveTo(charizard.root)
	:parentType("SKULL")
	:pos(-charizard.outliner.Head:getPivot())

-- Portrait setup
charizard:deepCopy(charizard.outliner.Head)
	:moveTo(charizard.root)
	:parentType("PORTRAIT")
	:pos(-charizard.outliner.Head:getPivot())

-- Remove helmet from skulls
for i = 1, #charizard.parts do
	local part = charizard.parts[i]
	if part:getName():find("ArmorHelmet_Copy") then
		part:remove()
	end
end

-- Arm parts
local defaultParts = charizard:createGroup(function(part) return part:getName():find("ArmDefault") end)
local slimParts    = charizard:createGroup(function(part) return part:getName():find("ArmSlim")    end)

-- Vanilla skin parts
local skinParts = charizard:createGroup(function(part) return part:getName():find("_[sS]kin") end)

-- Layer parts
local layerTypes = {"HAT", "JACKET", "LEFT_SLEEVE", "RIGHT_SLEEVE", "LEFT_PANTS_LEG", "RIGHT_PANTS_LEG", "CAPE", "LOWER_LAYER"}
local layerParts = {}
for i = 1, #layerTypes do
	local type = layerTypes[i]
	layerParts[type] = charizard:createGroup(function(part) return part:getName():find(type) end)
end

-- Apply translucent cull
charizard:createGroup(function(part) return part:getName():find("_[fF]lat") end):primaryRenderType("TRANSLUCENT_CULL")

-- Wing parts
local wingParts = charizard:createGroup(function(part) return part:getName():find("[wW]ing") and part:getType() ~= "GROUP" end)

-- Determine vanilla player type on init
local vanillaAvatarType
function events.ENTITY_INIT()
	
	vanillaAvatarType = player:getModelType()
	
end

function events.RENDER(_, context)
	
	-- Model shape
	local slimShape = (skin.curr and vanillaAvatarType == "SLIM") or (slim.curr and not skin.curr)
	defaultParts:visible(not slimShape)
	slimParts:visible(slimShape)
	
	-- First person arms toggle
	local firstPerson = context == "FIRST_PERSON"
	charizard.outliner.LeftArm:visible(not firstPerson)
	charizard.outliner.RightArm:visible(not firstPerson)
	charizard.outliner.LeftArmFP:visible(firstPerson)
	charizard.outliner.RightArmFP:visible(firstPerson)
	
	-- Skin textures
	local skinType = skin.curr and "SKIN" or "PRIMARY"
	skinParts:primaryTexture(skinType)
	
	-- Cape textures
	charizard.outliner.Cape:primaryTexture(skin.curr and "CAPE" or "PRIMARY")
	
	-- Elytra glint
	local item  = player:getItem(5)
	local glint = item.id == "minecraft:elytra" and item:hasGlint() and "GLINT" or "NONE"
	wingParts:secondaryRenderType(glint)
	
	-- Layer toggling
	for layerType, vanillaParts in pairs(layerParts) do
		local enabled
		if layerType == "LOWER_LAYER" then
			enabled = player:isSkinLayerVisible("RIGHT_PANTS_LEG") or player:isSkinLayerVisible("LEFT_PANTS_LEG")
		else
			enabled = player:isSkinLayerVisible(layerType)
		end
		vanillaParts:visible(enabled)
	end
	
	-- Shadow size
	renderer:shadowRadius(math.map(charizard.outliner.Player:getAnimScale():lengthSquared() / 3, 0, 1, 0.25, 1))
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required script
local s, pageNav, acts, colors = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isn't found

-- Pages
local parentPage = action_wheel:getPage("Main")
local playerPage = action_wheel:newPage("Player")

-- Actions
acts.playerPage = parentPage:newAction()
	:item("armor_stand")
	:onLeftClick(function() pageNav.descend(playerPage) end)

acts.playerVanillaToggle = playerPage:newAction()
	:item("player_head{SkullOwner:"..avatar:getEntityName().."}")
	:onToggle(function(bool)
		skin:update(bool)
	end)
	:toggled(skin.curr)

acts.playerModelToggle = playerPage:newAction()
	:item("player_head")
	:toggleItem("player_head{SkullOwner:MHF_Alex}")
	:onToggle(function(bool)
		slim:update(bool)
	end)
	:toggled(slim.curr)

-- Update actions
function events.RENDER()
	
	if action_wheel:isEnabled() then
		acts.playerPage
			:title(toJson(
				{text = "Player Settings", bold = true, color = colors.primary}
			))
			:hoverColor(colors.hover)
		
		acts.playerVanillaToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Vanilla Texture\n\n", bold = true, color = colors.primary},
					{text = "Toggles the usage of your vanilla skin.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
		acts.playerModelToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Model Shape\n\n", bold = true, color = colors.primary},
					{text = "Adjust the model shape to use Default or Slim Proportions.\nWill be overridden by the vanilla skin toggle.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
	end
	
end