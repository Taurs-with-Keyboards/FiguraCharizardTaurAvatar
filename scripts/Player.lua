-- Required scripts
local parts = require("lib.GroupIndex")(models)

-- Glowing outline
renderer:outlineColor(vectors.hexToRGB("D8741E"))

-- Config setup
config:name("CharizardTaur")
local vanillaSkin = config:load("AvatarVanillaSkin")
local slim        = config:load("AvatarSlim") or false
local shiny       = config:load("AvatarShiny") or false
if vanillaSkin == nil then vanillaSkin = true end

-- Set skull and portrait groups to visible (incase disabled in blockbench)
parts.Skull   :visible(true)
parts.Portrait:visible(true)

-- All vanilla skin parts
local skin = {
	
	parts.Head.Head,
	parts.Head.Layer,
	
	parts.Body.Body,
	parts.Body.Layer,
	
	parts.leftArmDefault,
	parts.leftArmSlim,
	parts.leftArmDefaultFP,
	parts.leftArmSlimFP,
	
	parts.rightArmDefault,
	parts.rightArmSlim,
	parts.rightArmDefaultFP,
	parts.rightArmSlimFP,
	
	parts.Portrait.Head,
	parts.Portrait.Layer,
	
	parts.Skull.Head,
	parts.Skull.Layer
	
}

-- All layer parts
local layer = {
	
	HAT = {
		parts.Head.Layer
	},
	JACKET = {
		parts.Body.Layer
	},
	LEFT_SLEEVE = {
		parts.leftArmDefault.Layer,
		parts.leftArmSlim.Layer,
		parts.LowerLeftArm.Layer,
		parts.LeftForearm.Layer,
		parts.LeftFingerF.Layer,
		parts.LeftFingerM.Layer,
		parts.LeftFingerB.Layer,
		parts.leftArmDefaultFP.Layer,
		parts.leftArmSlimFP.Layer
	},
	RIGHT_SLEEVE = {
		parts.rightArmDefault.Layer,
		parts.rightArmSlim.Layer,
		parts.LowerRightArm.Layer,
		parts.RightForearm.Layer,
		parts.RightFingerF.Layer,
		parts.RightFingerM.Layer,
		parts.RightFingerB.Layer,
		parts.rightArmDefaultFP.Layer,
		parts.rightArmSlimFP.Layer
	},
	LEFT_PANTS_LEG = {
		parts.leftLeg.Layer,
		parts.LeftFoot.Layer
	},
	RIGHT_PANTS_LEG = {
		parts.rightLeg.Layer,
		parts.RightFoot.Layer
	},
	CAPE = {
		parts.Cape
	},
	LOWER_BODY = {
		parts.Merge.Layer,
		parts.Torso.Layer,
		parts.Hips.Layer,
		parts.Tail1.Layer,
		parts.Tail2.Layer,
		parts.Tail3.Layer
	}
}

-- All shiny parts
local shinyParts = {
	
	parts.Horns,
	parts.HornsSkull,
	
	parts.Merge.Merge,
	parts.Torso.Torso,
	
	parts.LowerLeftArm.Arm,
	parts.LeftForearm.Arm,
	parts.LeftFingerF.Finger,
	parts.LeftFingerM.Finger,
	parts.LeftFingerB.Finger,
	
	parts.LowerRightArm.Arm,
	parts.RightForearm.Arm,
	parts.RightFingerF.Finger,
	parts.RightFingerM.Finger,
	parts.RightFingerB.Finger,
	
	parts.LeftWing1,
	parts.RightWing1,
	
	parts.Hips.Hips,
	parts.leftLeg.Leg,
	parts.LeftFoot.Foot,
	parts.rightLeg.Leg,
	parts.RightFoot.Foot,
	
	parts.Tail1.Tail,
	parts.Tail2.Tail,
	parts.Tail3.Tail
	
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
	parts.LeftWing1.Membrane,
	parts.LeftWing2.Membrane,
	parts.LeftWing3.Membrane,
	
	-- Right wing
	parts.RightWing1.Membrane,
	parts.RightWing2.Membrane,
	parts.RightWing3.Membrane,
	
	-- Left arm claws
	parts.LeftFingerF.Claw,
	parts.LeftFingerM.Claw,
	parts.LeftFingerB.Claw,
	
	-- Right arm claws
	parts.RightFingerF.Claw,
	parts.RightFingerM.Claw,
	parts.RightFingerB.Claw,
	
	-- Left leg claws
	parts.LeftFoot.ClawL,
	parts.LeftFoot.ClawM,
	parts.LeftFoot.ClawR,
	
	-- Right leg claws
	parts.RightFoot.ClawL,
	parts.RightFoot.ClawM,
	parts.RightFoot.ClawR,
	
	-- Fire
	parts.Fire
	
}

-- Apply
for _, part in ipairs(planes) do
	part:primaryRenderType("TRANSLUCENT_CULL")
end

-- Outer wing parts
local wings = {
	
	parts.LeftWing1,
	parts.LeftWing2,
	parts.LeftWing3,
	parts.RightWing1,
	parts.RightWing2,
	parts.RightWing3
	
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
	
	parts.leftArmDefault:visible(not slimShape)
	parts.rightArmDefault:visible(not slimShape)
	parts.leftArmDefaultFP:visible(not slimShape)
	parts.rightArmDefaultFP:visible(not slimShape)
	
	parts.leftArmSlim:visible(slimShape)
	parts.rightArmSlim:visible(slimShape)
	parts.leftArmSlimFP:visible(slimShape)
	parts.rightArmSlimFP:visible(slimShape)
	
	-- Skin textures
	local skinType = vanillaSkin and "SKIN" or "PRIMARY"
	for _, part in ipairs(skin) do
		part:primaryTexture(skinType)
	end
	
	-- Shiny textures
	local textureType = shiny and textures["textures.charizard_shiny"] or textures["textures.charizard"]
	for _, part in ipairs(shinyParts) do
		part:primaryTexture("Custom", textureType)
	end
	
	-- Cape Texture
	parts.Cape:primaryTexture(vanillaSkin and "CAPE" or "PRIMARY")
	
	-- Elytra glint
	local item  = player:getItem(5)
	local glint = item.id == "minecraft:elytra" and item:hasGlint() and "GLINT" or "NONE"
	for _, part in ipairs(wings) do
		part.Wing:secondaryRenderType(glint)
	end
	
	-- Disables lower body if player is in spectator mode
	parts.LowerBody:parentType(player:getGamemode() == "SPECTATOR" and "BODY" or "NONE")
	
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

-- Shiny toggle
local function setShiny(boolean)
	
	shiny = boolean
	config:save("AvatarShiny", shiny)
	
end

-- Sync variables
local function syncPlayer(a, b, c)
	
	vanillaSkin = a
	slim        = b
	shiny       = c
	
end

-- Pings setup
pings.setAvatarVanillaSkin = setVanillaSkin
pings.setAvatarModelType   = setModelType
pings.setAvatarShiny       = setShiny
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
setShiny(shiny)

-- Setup table
local t = {}

-- Action wheel pages
t.vanillaSkinPage = action_wheel:newAction("VanillaSkin")
	:title("§6§lToggle Vanilla Texture\n\n§3Toggles the usage of your vanilla skin for the upper body.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item('minecraft:player_head{"SkullOwner":"'..avatar:getEntityName()..'"}')
	:onToggle(pings.setAvatarVanillaSkin)
	:toggled(vanillaSkin)

t.modelPage = action_wheel:newAction("ModelShape")
	:title("§6§lToggle Model Shape\n\n§3Adjust the model shape to use Default or Slim Proportions.\nWill be overridden by the vanilla skin toggle.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item('minecraft:player_head')
	:toggleItem('minecraft:player_head{"SkullOwner":"MHF_Alex"}')
	:onToggle(pings.setAvatarModelType)
	:toggled(slim)

t.shinyPage = action_wheel:newAction("ModelShiny")
	:title("§6§lToggle Shiny Textures\n\n§3Set the lower body to use shiny textures over the default textures.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item('minecraft:gunpowder')
	:toggleItem("minecraft:glowstone_dust")
	:onToggle(pings.setAvatarShiny)
	:toggled(shiny)

-- Return action wheel pages
return t