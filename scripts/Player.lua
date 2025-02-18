-- Required scripts
local pokemonParts  = require("lib.GroupIndex")(models.models.CharizardTaur)
local pokeballParts = require("lib.GroupIndex")(models.models.Pokeball)
local itemCheck     = require("lib.ItemCheck")
local color         = require("scripts.ColorProperties")

-- Config setup
config:name("CharizardTaur")
local vanillaSkin = config:load("AvatarVanillaSkin")
local slim        = config:load("AvatarSlim") or false
if vanillaSkin == nil then vanillaSkin = true end

-- Set skull and portrait groups to visible (incase disabled in blockbench)
pokemonParts.Skull   :visible(true)
pokemonParts.Portrait:visible(true)

-- All vanilla skin parts
local skin = {
	
	pokemonParts.Head.Head,
	pokemonParts.Head.Layer,
	
	pokemonParts.Body.Body,
	pokemonParts.Body.Layer,
	
	pokemonParts.leftArmDefault,
	pokemonParts.leftArmSlim,
	pokemonParts.leftArmDefaultFP,
	pokemonParts.leftArmSlimFP,
	
	pokemonParts.rightArmDefault,
	pokemonParts.rightArmSlim,
	pokemonParts.rightArmDefaultFP,
	pokemonParts.rightArmSlimFP,
	
	pokemonParts.Portrait.Head,
	pokemonParts.Portrait.Layer,
	
	pokemonParts.Skull.Head,
	pokemonParts.Skull.Layer
	
}

-- All layer parts
local layer = {
	
	HAT = {
		pokemonParts.Head.Layer
	},
	JACKET = {
		pokemonParts.Body.Layer
	},
	LEFT_SLEEVE = {
		pokemonParts.leftArmDefault.Layer,
		pokemonParts.leftArmSlim.Layer,
		pokemonParts.LowerLeftArm.Layer,
		pokemonParts.LeftForearm.Layer,
		pokemonParts.LeftFingerF.Layer,
		pokemonParts.LeftFingerM.Layer,
		pokemonParts.LeftFingerB.Layer,
		pokemonParts.leftArmDefaultFP.Layer,
		pokemonParts.leftArmSlimFP.Layer
	},
	RIGHT_SLEEVE = {
		pokemonParts.rightArmDefault.Layer,
		pokemonParts.rightArmSlim.Layer,
		pokemonParts.LowerRightArm.Layer,
		pokemonParts.RightForearm.Layer,
		pokemonParts.RightFingerF.Layer,
		pokemonParts.RightFingerM.Layer,
		pokemonParts.RightFingerB.Layer,
		pokemonParts.rightArmDefaultFP.Layer,
		pokemonParts.rightArmSlimFP.Layer
	},
	LEFT_PANTS_LEG = {
		pokemonParts.leftLeg.Layer,
		pokemonParts.LeftFoot.Layer
	},
	RIGHT_PANTS_LEG = {
		pokemonParts.rightLeg.Layer,
		pokemonParts.RightFoot.Layer
	},
	CAPE = {
		pokemonParts.Cape
	},
	LOWER_BODY = {
		pokemonParts.Merge.Layer,
		pokemonParts.Torso.Layer,
		pokemonParts.Hips.Layer,
		pokemonParts.Tail1.Layer,
		pokemonParts.Tail2.Layer,
		pokemonParts.Tail3.Layer
	}
}

--[[
	
	Because flat parts in the model are 2 faces directly on top
	of eachother, and have 0 inflate, the two faces will z-fight.
	This prevents z-fighting, as well as z-fighting at a distance,
	as well as translucent stacking.
	
	Please add plane/flat parts with 2 faces to the table below.
	0.01 works, but this works much better :)
	
--]]

-- All plane parts
local planes = {
	
	-- Left wing
	pokemonParts.LeftWing1.Membrane,
	pokemonParts.LeftWing2.Membrane,
	pokemonParts.LeftWing3.Membrane,
	
	-- Right wing
	pokemonParts.RightWing1.Membrane,
	pokemonParts.RightWing2.Membrane,
	pokemonParts.RightWing3.Membrane,
	
	-- Left arm claws
	pokemonParts.LeftFingerFClaw.Claw,
	pokemonParts.LeftFingerMClaw.Claw,
	pokemonParts.LeftFingerBClaw.Claw,
	
	-- Right arm claws
	pokemonParts.RightFingerFClaw.Claw,
	pokemonParts.RightFingerMClaw.Claw,
	pokemonParts.RightFingerBClaw.Claw,
	
	-- Left leg claws
	pokemonParts.LeftFootClawL.Claw,
	pokemonParts.LeftFootClawM.Claw,
	pokemonParts.LeftFootClawR.Claw,
	
	-- Right leg claws
	pokemonParts.RightFootClawL.Claw,
	pokemonParts.RightFootClawM.Claw,
	pokemonParts.RightFootClawR.Claw,
	
}

-- Apply
for _, part in ipairs(planes) do
	part:primaryRenderType("TRANSLUCENT_CULL")
end

-- Outer wing parts
local wings = {
	
	pokemonParts.LeftWing1,
	pokemonParts.LeftWing2,
	pokemonParts.LeftWing3,
	pokemonParts.RightWing1,
	pokemonParts.RightWing2,
	pokemonParts.RightWing3
	
}

-- Determine vanilla player type on init
local vanillaAvatarType
function events.ENTITY_INIT()
	
	vanillaAvatarType = player:getModelType()
	
end

-- Misc tick required events
function events.TICK()
	
	-- Model shape
	local slimShape = (vanillaSkin and vanillaAvatarType == "SLIM") or (slim and not vanillaSkin)
	
	pokemonParts.leftArmDefault:visible(not slimShape)
	pokemonParts.rightArmDefault:visible(not slimShape)
	pokemonParts.leftArmDefaultFP:visible(not slimShape)
	pokemonParts.rightArmDefaultFP:visible(not slimShape)
	
	pokemonParts.leftArmSlim:visible(slimShape)
	pokemonParts.rightArmSlim:visible(slimShape)
	pokemonParts.leftArmSlimFP:visible(slimShape)
	pokemonParts.rightArmSlimFP:visible(slimShape)
	
	-- Skin textures
	local skinType = vanillaSkin and "SKIN" or "PRIMARY"
	for _, part in ipairs(skin) do
		part:primaryTexture(skinType)
	end
	
	-- Cape Texture
	pokemonParts.Cape:primaryTexture(vanillaSkin and "CAPE" or "PRIMARY")
	
	-- Elytra glint
	local item  = player:getItem(5)
	local glint = item.id == "minecraft:elytra" and item:hasGlint() and "GLINT" or "NONE"
	for _, part in ipairs(wings) do
		part.Wing:secondaryRenderType(glint)
	end
	
	-- Layer toggling
	for layerType, parts in pairs(layer) do
		local enabled = enabled
		if layerType == "LOWER_BODY" then
			enabled = player:isSkinLayerVisible("RIGHT_PANTS_LEG") or player:isSkinLayerVisible("LEFT_PANTS_LEG")
		else
			enabled = player:isSkinLayerVisible(layerType)
		end
		for _, part in ipairs(parts) do
			part:visible(enabled)
		end
	end
	
end

-- Vanilla skin toggle
local function setVanillaSkin(boolean)
	
	vanillaSkin = boolean
	config:save("AvatarVanillaSkin", vanillaSkin)
	
end

-- Model type toggle
local function setModelType(boolean)
	
	slim = boolean
	config:save("AvatarSlim", slim)
	
end

-- Sync variables
local function syncPlayer(a, b)
	
	vanillaSkin = a
	slim        = b
	
end

-- Pings setup
pings.setAvatarVanillaSkin = setVanillaSkin
pings.setAvatarModelType   = setModelType
pings.syncPlayer           = syncPlayer

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncPlayer(vanillaSkin, slim, shiny)
		end
		
	end
end

-- Activate actions
setVanillaSkin(vanillaSkin)
setModelType(slim)

-- Setup table
local t = {}

-- Action wheel pages
t.vanillaSkinPage = action_wheel:newAction()
	:item(itemCheck("player_head{'SkullOwner':'"..avatar:getEntityName().."'}"))
	:onToggle(pings.setAvatarVanillaSkin)
	:toggled(vanillaSkin)

t.modelPage = action_wheel:newAction()
	:item(itemCheck("player_head"))
	:toggleItem(itemCheck("player_head{'SkullOwner':'MHF_Alex'}"))
	:onToggle(pings.setAvatarModelType)
	:toggled(slim)

-- Update action page info
function events.TICK()
	
	t.vanillaSkinPage
		:title(toJson
			{"",
			{text = "Toggle Vanilla Texture\n\n", bold = true, color = color.primary},
			{text = "Toggles the usage of your vanilla skin for the upper body.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
	t.modelPage
		:title(toJson
			{"",
			{text = "Toggle Model Shape\n\n", bold = true, color = color.primary},
			{text = "Adjust the model shape to use Default or Slim Proportions.\nWill be overridden by the vanilla skin toggle.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
end

-- Return action wheel pages
return t