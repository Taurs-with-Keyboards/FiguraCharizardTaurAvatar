-- Model setup
local model     = models.CharizardTaur
local upperRoot = model.Player.UpperBody
local lowerRoot = model.Player.LowerBody

-- Glowing outline
renderer:outlineColor(vectors.hexToRGB("D8741E"))

-- Config setup
config:name("CharizardTaur")
local vanillaSkin = config:load("AvatarVanillaSkin")
if vanillaSkin == nil then vanillaSkin = true end
local slim = config:load("AvatarSlim") or false

-- Vanilla parts table
local skinParts = {
	upperRoot.Head.Head,
	upperRoot.Head.HatLayer,
	
	upperRoot.Body.Body,
	upperRoot.Body.BodyLayer,
	
	model.RightArmFP.rightArmDefaultFP,
	model.RightArmFP.rightArmSlimFP,
	upperRoot.RightArm.rightArmDefault,
	upperRoot.RightArm.rightArmSlim,
	
	model.LeftArmFP.leftArmDefaultFP,
	model.LeftArmFP.leftArmSlimFP,
	upperRoot.LeftArm.leftArmDefault,
	upperRoot.LeftArm.leftArmSlim,
	
	model.Portrait.Head,
	model.Portrait.HatLayer,
	
	model.Skull.Head,
	model.Skull.HatLayer,
}

-- Variable setup
local vanillaAvatarType = nil
function events.ENTITY_INIT()
	vanillaAvatarType = player:getModelType()
end

-- Misc tick required events
function events.TICK()
	-- Model shape
	local slimShape = (vanillaSkin and vanillaAvatarType == "SLIM") or (slim and not vanillaSkin)
	
	model.LeftArmFP.leftArmDefaultFP:visible(not slimShape)
	model.RightArmFP.rightArmDefaultFP:visible(not slimShape)
	upperRoot.LeftArm.leftArmDefault:visible(not slimShape)
	upperRoot.RightArm.rightArmDefault:visible(not slimShape)
	
	model.LeftArmFP.leftArmSlimFP:visible(slimShape)
	model.RightArmFP.rightArmSlimFP:visible(slimShape)
	upperRoot.LeftArm.leftArmSlim:visible(slimShape)
	upperRoot.RightArm.rightArmSlim:visible(slimShape)
	
	-- Skin textures
	for _, part in ipairs(skinParts) do
		part:primaryTexture(vanillaSkin and "SKIN" or nil)
	end
	
	-- Cape/Elytra texture
	--upperRoot.Body.Cape:primaryTexture(vanillaSkin and "CAPE" or nil)
	--upperRoot.Body.Elytra:primaryTexture(vanillaSkin and player:hasCape() and (player:isSkinLayerVisible("CAPE") and "CAPE" or "ELYTRA") or nil)
	--	:secondaryRenderType(player:getItem(5):hasGlint() and "GLINT" or "NONE")
	
	-- Disables lower body if player is in spectator mode
	lowerRoot:parentType(player:getGamemode() == "SPECTATOR" and "BODY" or "NONE")
	
end

-- Show/hide skin layers depending on Skin Customization settings
local layerParts = {
	HAT = {
		upperRoot.Head.HatLayer,
	},
	JACKET = {
		upperRoot.Body.BodyLayer,
	},
	RIGHT_SLEEVE = {
		model.RightArmFP.rightArmDefaultFP.ArmLayer,
		model.RightArmFP.rightArmSlimFP.ArmLayer,
		upperRoot.RightArm.rightArmDefault.ArmLayer,
		upperRoot.RightArm.rightArmSlim.ArmLayer,
		lowerRoot.Midsection.LowerRightArm.ArmLayer,
		lowerRoot.Midsection.LowerRightArm.RightForearm.ArmLayer,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerF.FingerLayer,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerM.FingerLayer,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerB.FingerLayer,
	},
	LEFT_SLEEVE = {
		model.LeftArmFP.leftArmDefaultFP.ArmLayer,
		model.LeftArmFP.leftArmSlimFP.ArmLayer,
		upperRoot.LeftArm.leftArmDefault.ArmLayer,
		upperRoot.LeftArm.leftArmSlim.ArmLayer,
		lowerRoot.Midsection.LowerLeftArm.ArmLayer,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.ArmLayer,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerF.FingerFLayer,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerM.FingerLayer,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerB.FingerLayer,
	},
	RIGHT_PANTS_LEG = {
		lowerRoot.rightLeg.LegLayer,
		lowerRoot.rightLeg.RightFoot.FootLayer,
	},
	LEFT_PANTS_LEG = {
		lowerRoot.leftLeg.LegLayer,
		lowerRoot.leftLeg.LeftFoot.FootLayer,
	},
	CAPE = {
		--upperRoot.Body.Cape,
	},
	LOWER_BODY = {
		lowerRoot.Midsection.MergeLayer,
		lowerRoot.Midsection.TorsoLayer,
		lowerRoot.LowerLayer,
		lowerRoot.Tail1.TailLayer,
		lowerRoot.Tail1.Tail2.TailLayer,
		lowerRoot.Tail1.Tail2.Tail3.TailLayer,
	},
}
function events.TICK()
	for playerPart, parts in pairs(layerParts) do
		local enabled = enabled
		if playerPart == "LOWER_BODY" then
			enabled = player:isSkinLayerVisible("RIGHT_PANTS_LEG") or player:isSkinLayerVisible("LEFT_PANTS_LEG")
		else
			enabled = player:isSkinLayerVisible(playerPart)
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
	slim = b
end

-- Pings setup
pings.setAvatarVanillaSkin = setVanillaSkin
pings.setAvatarModelType   = setModelType
pings.syncPlayer           = syncPlayer

-- Sync on tick
if host:isHost() then
	function events.TICK()
		if world.getTime() % 200 == 0 then
			pings.syncPlayer(vanillaSkin, slim)
		end
	end
end

-- Activate actions
setVanillaSkin(vanillaSkin)
setModelType(slim)

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

-- Return table
return t