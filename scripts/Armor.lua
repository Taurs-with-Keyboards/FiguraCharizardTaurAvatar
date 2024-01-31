-- Required scripts
local model     = require("scripts.ModelParts")
local kattArmor = require("lib.KattArmor")()

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Helmet
	:addParts(model.head.headArmorHelmet.Helmet)
	:addTrimParts(model.head.headArmorHelmet.Trim)
kattArmor.Armor.Chestplate
	:addParts(
		model.body.bodyArmorChestplate.Chestplate,
		model.body.bodyArmorChestplate.Belt,
		model.leftArm.leftArmArmorChestplate.Chestplate,
		model.rightArm.rightArmArmorChestplate.Chestplate,
		model.merge.MergeArmorChestplate.Chestplate,
		model.torso.TorsoArmorChestplate.Chestplate,
		model.hips.HipsArmorChestplate.Chestplate,
		model.lowerLeftArm.LowerLeftArmArmorChestplate.Chestplate,
		model.lowerLeftArm.LeftForearm.LeftForearmArmorChestplate.Chestplate,
		model.leftHand.LeftFingerF.LeftFingerFArmorChestplate.Chestplate,
		model.leftHand.LeftFingerM.LeftFingerMArmorChestplate.Chestplate,
		model.leftHand.LeftFingerB.LeftFingerBArmorChestplate.Chestplate,
		model.lowerRightArm.LowerRightArmArmorChestplate.Chestplate,
		model.lowerRightArm.RightForearm.RightForearmArmorChestplate.Chestplate,
		model.rightHand.RightFingerF.RightFingerFArmorChestplate.Chestplate,
		model.rightHand.RightFingerM.RightFingerMArmorChestplate.Chestplate,
		model.rightHand.RightFingerB.RightFingerBArmorChestplate.Chestplate,
		model.leftArmFP.leftArmArmorChestplateFP.Chestplate,
		model.rightArmFP.rightArmArmorChestplateFP.Chestplate
	)
	:addTrimParts(
		model.body.bodyArmorChestplate.Trim,
		model.body.bodyArmorChestplate.BeltTrim,
		model.leftArm.leftArmArmorChestplate.Trim,
		model.rightArm.rightArmArmorChestplate.Trim,
		model.merge.MergeArmorChestplate.Trim,
		model.torso.TorsoArmorChestplate.Trim,
		model.hips.HipsArmorChestplate.Trim,
		model.lowerLeftArm.LowerLeftArmArmorChestplate.Trim,
		model.lowerLeftArm.LeftForearm.LeftForearmArmorChestplate.Trim,
		model.leftHand.LeftFingerF.LeftFingerFArmorChestplate.Trim,
		model.leftHand.LeftFingerM.LeftFingerMArmorChestplate.Trim,
		model.leftHand.LeftFingerB.LeftFingerBArmorChestplate.Trim,
		model.lowerRightArm.LowerRightArmArmorChestplate.Trim,
		model.lowerRightArm.RightForearm.RightForearmArmorChestplate.Trim,
		model.rightHand.RightFingerF.RightFingerFArmorChestplate.Trim,
		model.rightHand.RightFingerM.RightFingerMArmorChestplate.Trim,
		model.rightHand.RightFingerB.RightFingerBArmorChestplate.Trim,
		model.leftArmFP.leftArmArmorChestplateFP.Trim,
		model.rightArmFP.rightArmArmorChestplateFP.Trim
	)
kattArmor.Armor.Leggings
	:addParts(
		model.torso.TorsoArmorLeggings.Leggings,
		model.hips.HipsArmorLeggings.Leggings,
		model.tail.Tail1ArmorLeggings.Leggings,
		model.tail.Tail2.Tail2ArmorLeggings.Leggings,
		model.tail.Tail2.Tail3.Tail3ArmorLeggings.Leggings,
		model.leftLeg.leftLegArmorLeggings.Leggings,
		model.rightLeg.rightLegArmorLeggings.Leggings
	)
	:addTrimParts(
		model.torso.TorsoArmorLeggings.Trim,
		model.hips.HipsArmorLeggings.Trim,
		model.tail.Tail1ArmorLeggings.Trim,
		model.tail.Tail2.Tail2ArmorLeggings.Trim,
		model.tail.Tail2.Tail3.Tail3ArmorLeggings.Trim,
		model.leftLeg.leftLegArmorLeggings.Trim,
		model.rightLeg.rightLegArmorLeggings.Trim
	)
kattArmor.Armor.Boots
	:addParts(
		model.leftFoot.LeftFootArmorBoot.Boot,
		model.rightFoot.RightFootArmorBoot.Boot
	)
	:addTrimParts(
		model.leftFoot.LeftFootArmorBoot.Trim,
		model.rightFoot.RightFootArmorBoot.Trim
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"])
	:addParts(kattArmor.Armor.Helmet,
		model.head.headArmorHelmet.Leather
	)
	:addParts(kattArmor.Armor.Chestplate,
		model.body.bodyArmorChestplate.Leather,
		model.body.bodyArmorChestplate.BeltLeather,
		model.leftArm.leftArmArmorChestplate.Leather,
		model.rightArm.rightArmArmorChestplate.Leather,
		model.merge.MergeArmorChestplate.Leather,
		model.torso.TorsoArmorChestplate.Leather,
		model.hips.HipsArmorChestplate.Leather,
		model.lowerLeftArm.LowerLeftArmArmorChestplate.Leather,
		model.lowerLeftArm.LeftForearm.LeftForearmArmorChestplate.Leather,
		model.leftHand.LeftFingerF.LeftFingerFArmorChestplate.Leather,
		model.leftHand.LeftFingerM.LeftFingerMArmorChestplate.Leather,
		model.leftHand.LeftFingerB.LeftFingerBArmorChestplate.Leather,
		model.lowerRightArm.LowerRightArmArmorChestplate.Leather,
		model.lowerRightArm.RightForearm.RightForearmArmorChestplate.Leather,
		model.rightHand.RightFingerF.RightFingerFArmorChestplate.Leather,
		model.rightHand.RightFingerM.RightFingerMArmorChestplate.Leather,
		model.rightHand.RightFingerB.RightFingerBArmorChestplate.Leather,
		model.leftArmFP.leftArmArmorChestplateFP.Leather,
		model.rightArmFP.rightArmArmorChestplateFP.Leather
	)
	:addParts(kattArmor.Armor.Leggings,
		model.torso.TorsoArmorLeggings.Leather,
		model.hips.HipsArmorLeggings.Leather,
		model.tail.Tail1ArmorLeggings.Leather,
		model.tail.Tail2.Tail2ArmorLeggings.Leather,
		model.tail.Tail2.Tail3.Tail3ArmorLeggings.Leather,
		model.leftLeg.leftLegArmorLeggings.Leather,
		model.rightLeg.rightLegArmorLeggings.Leather
	)
	:addParts(kattArmor.Armor.Boots,
		model.leftFoot.LeftFootArmorBoot.Leather,
		model.rightFoot.RightFootArmorBoot.Leather
	)

-- Chainmail armor
kattArmor.Materials.chainmail
	:setTexture(textures["textures.armor.chainmailArmor"])

-- Iron armor
kattArmor.Materials.iron
	:setTexture(textures["textures.armor.ironArmor"])

-- Golden armor
kattArmor.Materials.golden
	:setTexture(textures["textures.armor.goldenArmor"])

-- Diamond armor
kattArmor.Materials.diamond
	:setTexture(textures["textures.armor.diamondArmor"])

-- Netherite armor
kattArmor.Materials.netherite
	:setTexture(textures["textures.armor.netheriteArmor"])

-- Turtle helmet
kattArmor.Materials.turtle
	:setTexture(textures["textures.armor.turtleHelmet"])
	:setEmissiveTexture(textures["textures.armor.turtleHelmet_e"])

-- Trims
-- Coast
kattArmor.TrimPatterns.coast
	:setTexture(textures["textures.armor.trims.coastTrim"])

-- Dune
kattArmor.TrimPatterns.dune
	:setTexture(textures["textures.armor.trims.duneTrim"])

-- Eye
kattArmor.TrimPatterns.eye
	:setTexture(textures["textures.armor.trims.eyeTrim"])

-- Host
kattArmor.TrimPatterns.host
	:setTexture(textures["textures.armor.trims.hostTrim"])

-- Raiser
kattArmor.TrimPatterns.raiser
	:setTexture(textures["textures.armor.trims.raiserTrim"])

-- Rib
kattArmor.TrimPatterns.rib
	:setTexture(textures["textures.armor.trims.ribTrim"])

-- Sentry
kattArmor.TrimPatterns.sentry
	:setTexture(textures["textures.armor.trims.sentryTrim"])

-- Shaper
kattArmor.TrimPatterns.shaper
	:setTexture(textures["textures.armor.trims.shaperTrim"])

-- Silence
kattArmor.TrimPatterns.silence
	:setTexture(textures["textures.armor.trims.silenceTrim"])

-- Snout
kattArmor.TrimPatterns.snout
	:setTexture(textures["textures.armor.trims.snoutTrim"])

-- Spire
kattArmor.TrimPatterns.spire
	:setTexture(textures["textures.armor.trims.spireTrim"])

-- Tide
kattArmor.TrimPatterns.tide
	:setTexture(textures["textures.armor.trims.tideTrim"])

-- Vex
kattArmor.TrimPatterns.vex
	:setTexture(textures["textures.armor.trims.vexTrim"])

-- Ward
kattArmor.TrimPatterns.ward
	:setTexture(textures["textures.armor.trims.wardTrim"])

-- Wayfinder
kattArmor.TrimPatterns.wayfinder
	:setTexture(textures["textures.armor.trims.wayfinderTrim"])

-- Wild
kattArmor.TrimPatterns.wild
	:setTexture(textures["textures.armor.trims.wildTrim"])

-- Config setup
config:name("CharizardTaur")
local helmet     = config:load("ArmorHelmet")
local chestplate = config:load("ArmorChestplate")
local leggings   = config:load("ArmorLeggings")
local boots      = config:load("ArmorBoots")
if helmet     == nil then helmet     = true end
if chestplate == nil then chestplate = true end
if leggings   == nil then leggings   = true end
if boots      == nil then boots      = true end

function events.TICK()
	
	for _, part in ipairs(model.helmetToggle) do
		part:visible(helmet)
	end
	
	for _, part in ipairs(model.chestplateToggle) do
		part:visible(chestplate)
	end
	
	for _, part in ipairs(model.leggingsToggle) do
		part:visible(leggings)
	end
	
	for _, part in ipairs(model.bootsToggle) do
		part:visible(boots)
	end
	
end

-- Armor all toggle
local function setAll(boolean)
	
	helmet     = boolean
	chestplate = boolean
	leggings   = boolean
	boots      = boolean
	config:save("ArmorHelmet", helmet)
	config:save("ArmorChestplate", chestplate)
	config:save("ArmorLeggings", leggings)
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor helmet toggle
local function setHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor chestplate toggle
local function setChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor leggings toggle
local function setLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor boots toggle
local function setBoots(boolean)
	
	boots = boolean
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Sync variables
local function syncArmor(a, b, c, d)
	
	helmet     = a
	chestplate = b
	leggings   = c
	boots      = d
	
end

-- Pings setup
pings.setArmorAll        = setAll
pings.setArmorHelmet     = setHelmet
pings.setArmorChestplate = setChestplate
pings.setArmorLeggings   = setLeggings
pings.setArmorBoots      = setBoots
pings.syncArmor          = syncArmor

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncArmor(helmet, chestplate, leggings, boots)
		end
		
	end
end

-- Activate actions
setHelmet(helmet)
setChestplate(chestplate)
setLeggings(leggings)
setBoots(boots)

-- Setup table
local t = {}

-- Action wheel pages
t.allPage = action_wheel:newAction("AllArmorToggle")
	:title("§6§lToggle All Armor\n\n§3Toggles visibility of all armor parts.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:armor_stand")
	:toggleItem("minecraft:netherite_chestplate")
	:onToggle(pings.setArmorAll)

t.helmetPage = action_wheel:newAction("HelmetArmorToggle")
	:title("§6§lToggle Helmet\n\n§3Toggles visibility of helmet parts.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:iron_helmet")
	:toggleItem("minecraft:diamond_helmet")
	:onToggle(pings.setArmorHelmet)

t.chestplatePage = action_wheel:newAction("ChestplateArmorToggle")
	:title("§6§lToggle Chestplate\n\n§3Toggles visibility of chestplate parts.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:iron_chestplate")
	:toggleItem("minecraft:diamond_chestplate")
	:onToggle(pings.setArmorChestplate)

t.leggingsPage = action_wheel:newAction("LeggingsArmorToggle")
	:title("§6§lToggle Leggings\n\n§3Toggles visibility of leggings parts.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:iron_leggings")
	:toggleItem("minecraft:diamond_leggings")
	:onToggle(pings.setArmorLeggings)

t.bootsPage = action_wheel:newAction("BootsArmorToggle")
	:title("§6§lToggle Boots\n\n§3Toggles visibility of boots.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:iron_boots")
	:toggleItem("minecraft:diamond_boots")
	:onToggle(pings.setArmorBoots)

-- Update action page info
function events.TICK()
	
	t.allPage       :toggled(helmet and chestplate and leggings and boots)
	t.helmetPage    :toggled(helmet)
	t.chestplatePage:toggled(chestplate)
	t.leggingsPage  :toggled(leggings)
	t.bootsPage     :toggled(boots)
	
end

-- Return action wheel pages
return t