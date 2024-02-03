-- Required scripts
local parts     = require("scripts.ModelParts")
local kattArmor = require("lib.KattArmor")()

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Helmet
	:addParts(parts.headArmorHelmet.Helmet)
	:addTrimParts(parts.headArmorHelmet.Trim)
kattArmor.Armor.Chestplate
	:addParts(
		parts.bodyArmorChestplate.Chestplate,
		parts.bodyArmorChestplate.Belt,
		parts.leftArmArmorChestplate.Chestplate,
		parts.rightArmArmorChestplate.Chestplate,
		parts.MergeArmorChestplate.Chestplate,
		parts.TorsoArmorChestplate.Chestplate,
		parts.HipsArmorChestplate.Chestplate,
		parts.LowerLeftArmArmorChestplate.Chestplate,
		parts.LeftForearmArmorChestplate.Chestplate,
		parts.LeftFingerFArmorChestplate.Chestplate,
		parts.LeftFingerMArmorChestplate.Chestplate,
		parts.LeftFingerBArmorChestplate.Chestplate,
		parts.LowerRightArmArmorChestplate.Chestplate,
		parts.RightForearmArmorChestplate.Chestplate,
		parts.RightFingerFArmorChestplate.Chestplate,
		parts.RightFingerMArmorChestplate.Chestplate,
		parts.RightFingerBArmorChestplate.Chestplate,
		parts.leftArmArmorChestplateFP.Chestplate,
		parts.rightArmArmorChestplateFP.Chestplate
	)
	:addTrimParts(
		parts.bodyArmorChestplate.Trim,
		parts.bodyArmorChestplate.BeltTrim,
		parts.leftArmArmorChestplate.Trim,
		parts.rightArmArmorChestplate.Trim,
		parts.MergeArmorChestplate.Trim,
		parts.TorsoArmorChestplate.Trim,
		parts.HipsArmorChestplate.Trim,
		parts.LowerLeftArmArmorChestplate.Trim,
		parts.LeftForearmArmorChestplate.Trim,
		parts.LeftFingerFArmorChestplate.Trim,
		parts.LeftFingerMArmorChestplate.Trim,
		parts.LeftFingerBArmorChestplate.Trim,
		parts.LowerRightArmArmorChestplate.Trim,
		parts.RightForearmArmorChestplate.Trim,
		parts.RightFingerFArmorChestplate.Trim,
		parts.RightFingerMArmorChestplate.Trim,
		parts.RightFingerBArmorChestplate.Trim,
		parts.leftArmArmorChestplateFP.Trim,
		parts.rightArmArmorChestplateFP.Trim
	)
kattArmor.Armor.Leggings
	:addParts(
		parts.TorsoArmorLeggings.Leggings,
		parts.HipsArmorLeggings.Leggings,
		parts.Tail1ArmorLeggings.Leggings,
		parts.Tail2ArmorLeggings.Leggings,
		parts.Tail3ArmorLeggings.Leggings,
		parts.leftLegArmorLeggings.Leggings,
		parts.rightLegArmorLeggings.Leggings
	)
	:addTrimParts(
		parts.TorsoArmorLeggings.Trim,
		parts.HipsArmorLeggings.Trim,
		parts.Tail1ArmorLeggings.Trim,
		parts.Tail2ArmorLeggings.Trim,
		parts.Tail3ArmorLeggings.Trim,
		parts.leftLegArmorLeggings.Trim,
		parts.rightLegArmorLeggings.Trim
	)
kattArmor.Armor.Boots
	:addParts(
		parts.LeftFootArmorBoot.Boot,
		parts.RightFootArmorBoot.Boot
	)
	:addTrimParts(
		parts.LeftFootArmorBoot.Trim,
		parts.RightFootArmorBoot.Trim
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"])
	:addParts(kattArmor.Armor.Helmet,
		parts.headArmorHelmet.Leather
	)
	:addParts(kattArmor.Armor.Chestplate,
		parts.bodyArmorChestplate.Leather,
		parts.bodyArmorChestplate.BeltLeather,
		parts.leftArmArmorChestplate.Leather,
		parts.rightArmArmorChestplate.Leather,
		parts.MergeArmorChestplate.Leather,
		parts.TorsoArmorChestplate.Leather,
		parts.HipsArmorChestplate.Leather,
		parts.LowerLeftArmArmorChestplate.Leather,
		parts.LeftForearmArmorChestplate.Leather,
		parts.LeftFingerFArmorChestplate.Leather,
		parts.LeftFingerMArmorChestplate.Leather,
		parts.LeftFingerBArmorChestplate.Leather,
		parts.LowerRightArmArmorChestplate.Leather,
		parts.RightForearmArmorChestplate.Leather,
		parts.RightFingerFArmorChestplate.Leather,
		parts.RightFingerMArmorChestplate.Leather,
		parts.RightFingerBArmorChestplate.Leather,
		parts.leftArmArmorChestplateFP.Leather,
		parts.rightArmArmorChestplateFP.Leather
	)
	:addParts(kattArmor.Armor.Leggings,
		parts.TorsoArmorLeggings.Leather,
		parts.HipsArmorLeggings.Leather,
		parts.Tail1ArmorLeggings.Leather,
		parts.Tail2ArmorLeggings.Leather,
		parts.Tail3ArmorLeggings.Leather,
		parts.leftLegArmorLeggings.Leather,
		parts.rightLegArmorLeggings.Leather
	)
	:addParts(kattArmor.Armor.Boots,
		parts.LeftFootArmorBoot.Leather,
		parts.RightFootArmorBoot.Leather
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
	
	for _, part in ipairs(parts.helmetToggle) do
		part:visible(helmet)
	end
	
	for _, part in ipairs(parts.chestplateToggle) do
		part:visible(chestplate)
	end
	
	for _, part in ipairs(parts.leggingsToggle) do
		part:visible(leggings)
	end
	
	for _, part in ipairs(parts.bootsToggle) do
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