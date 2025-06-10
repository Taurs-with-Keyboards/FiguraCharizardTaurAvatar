-- Required scripts
local pokemonParts   = require("lib.GroupIndex")(models.models.CharizardTaur)
local charizardArmor = require("lib.KattArmor")()
local itemCheck      = require("lib.ItemCheck")
local color          = require("scripts.ColorProperties")

-- Setting the leggings to layer 1
charizardArmor.Armor.Leggings:setLayer(1)

-- Armor parts
charizardArmor.Armor.Helmet
	:addParts(pokemonParts.headArmorHelmet.Helmet)
	:addTrimParts(pokemonParts.headArmorHelmet.Trim)
charizardArmor.Armor.Chestplate
	:addParts(
		pokemonParts.bodyArmorChestplate.Chestplate,
		pokemonParts.bodyArmorChestplate.Belt,
		pokemonParts.leftArmArmorChestplate.Chestplate,
		pokemonParts.rightArmArmorChestplate.Chestplate,
		pokemonParts.MergeArmorChestplate.Chestplate,
		pokemonParts.TorsoArmorChestplate.Chestplate,
		pokemonParts.HipsArmorChestplate.Chestplate,
		pokemonParts.LowerLeftArmArmorChestplate.Chestplate,
		pokemonParts.LeftForearmArmorChestplate.Chestplate,
		pokemonParts.LeftFingerFArmorChestplate.Chestplate,
		pokemonParts.LeftFingerMArmorChestplate.Chestplate,
		pokemonParts.LeftFingerBArmorChestplate.Chestplate,
		pokemonParts.LowerRightArmArmorChestplate.Chestplate,
		pokemonParts.RightForearmArmorChestplate.Chestplate,
		pokemonParts.RightFingerFArmorChestplate.Chestplate,
		pokemonParts.RightFingerMArmorChestplate.Chestplate,
		pokemonParts.RightFingerBArmorChestplate.Chestplate,
		pokemonParts.leftArmArmorChestplateFP.Chestplate,
		pokemonParts.rightArmArmorChestplateFP.Chestplate
	)
	:addTrimParts(
		pokemonParts.bodyArmorChestplate.Trim,
		pokemonParts.bodyArmorChestplate.BeltTrim,
		pokemonParts.leftArmArmorChestplate.Trim,
		pokemonParts.rightArmArmorChestplate.Trim,
		pokemonParts.MergeArmorChestplate.Trim,
		pokemonParts.TorsoArmorChestplate.Trim,
		pokemonParts.HipsArmorChestplate.Trim,
		pokemonParts.LowerLeftArmArmorChestplate.Trim,
		pokemonParts.LeftForearmArmorChestplate.Trim,
		pokemonParts.LeftFingerFArmorChestplate.Trim,
		pokemonParts.LeftFingerMArmorChestplate.Trim,
		pokemonParts.LeftFingerBArmorChestplate.Trim,
		pokemonParts.LowerRightArmArmorChestplate.Trim,
		pokemonParts.RightForearmArmorChestplate.Trim,
		pokemonParts.RightFingerFArmorChestplate.Trim,
		pokemonParts.RightFingerMArmorChestplate.Trim,
		pokemonParts.RightFingerBArmorChestplate.Trim,
		pokemonParts.leftArmArmorChestplateFP.Trim,
		pokemonParts.rightArmArmorChestplateFP.Trim
	)
charizardArmor.Armor.Leggings
	:addParts(
		pokemonParts.TorsoArmorLeggings.Leggings,
		pokemonParts.HipsArmorLeggings.Leggings,
		pokemonParts.Tail1ArmorLeggings.Leggings,
		pokemonParts.Tail2ArmorLeggings.Leggings,
		pokemonParts.Tail3ArmorLeggings.Leggings,
		pokemonParts.leftLegArmorLeggings.Leggings,
		pokemonParts.rightLegArmorLeggings.Leggings
	)
	:addTrimParts(
		pokemonParts.TorsoArmorLeggings.Trim,
		pokemonParts.HipsArmorLeggings.Trim,
		pokemonParts.Tail1ArmorLeggings.Trim,
		pokemonParts.Tail2ArmorLeggings.Trim,
		pokemonParts.Tail3ArmorLeggings.Trim,
		pokemonParts.leftLegArmorLeggings.Trim,
		pokemonParts.rightLegArmorLeggings.Trim
	)
charizardArmor.Armor.Boots
	:addParts(
		pokemonParts.LeftFootArmorBoot.Boot,
		pokemonParts.RightFootArmorBoot.Boot
	)
	:addTrimParts(
		pokemonParts.LeftFootArmorBoot.Trim,
		pokemonParts.RightFootArmorBoot.Trim
	)

-- Leather armor
charizardArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"] or textures["models.CharizardTaur.leatherArmor"])
	:addParts(charizardArmor.Armor.Helmet,
		pokemonParts.headArmorHelmet.Leather
	)
	:addParts(charizardArmor.Armor.Chestplate,
		pokemonParts.bodyArmorChestplate.Leather,
		pokemonParts.bodyArmorChestplate.BeltLeather,
		pokemonParts.leftArmArmorChestplate.Leather,
		pokemonParts.rightArmArmorChestplate.Leather,
		pokemonParts.MergeArmorChestplate.Leather,
		pokemonParts.TorsoArmorChestplate.Leather,
		pokemonParts.HipsArmorChestplate.Leather,
		pokemonParts.LowerLeftArmArmorChestplate.Leather,
		pokemonParts.LeftForearmArmorChestplate.Leather,
		pokemonParts.LeftFingerFArmorChestplate.Leather,
		pokemonParts.LeftFingerMArmorChestplate.Leather,
		pokemonParts.LeftFingerBArmorChestplate.Leather,
		pokemonParts.LowerRightArmArmorChestplate.Leather,
		pokemonParts.RightForearmArmorChestplate.Leather,
		pokemonParts.RightFingerFArmorChestplate.Leather,
		pokemonParts.RightFingerMArmorChestplate.Leather,
		pokemonParts.RightFingerBArmorChestplate.Leather,
		pokemonParts.leftArmArmorChestplateFP.Leather,
		pokemonParts.rightArmArmorChestplateFP.Leather
	)
	:addParts(charizardArmor.Armor.Leggings,
		pokemonParts.TorsoArmorLeggings.Leather,
		pokemonParts.HipsArmorLeggings.Leather,
		pokemonParts.Tail1ArmorLeggings.Leather,
		pokemonParts.Tail2ArmorLeggings.Leather,
		pokemonParts.Tail3ArmorLeggings.Leather,
		pokemonParts.leftLegArmorLeggings.Leather,
		pokemonParts.rightLegArmorLeggings.Leather
	)
	:addParts(charizardArmor.Armor.Boots,
		pokemonParts.LeftFootArmorBoot.Leather,
		pokemonParts.RightFootArmorBoot.Leather
	)

-- Chainmail armor
charizardArmor.Materials.chainmail
	:setTexture(textures["textures.armor.chainmailArmor"] or textures["models.CharizardTaur.chainmailArmor"])

-- Iron armor
charizardArmor.Materials.iron
	:setTexture(textures["textures.armor.ironArmor"] or textures["models.CharizardTaur.ironArmor"])

-- Golden armor
charizardArmor.Materials.golden
	:setTexture(textures["textures.armor.goldenArmor"] or textures["models.CharizardTaur.goldenArmor"])

-- Diamond armor
charizardArmor.Materials.diamond
	:setTexture(textures["textures.armor.diamondArmor"] or textures["models.CharizardTaur.diamondArmor"])

-- Netherite armor
charizardArmor.Materials.netherite
	:setTexture(textures["textures.armor.netheriteArmor"] or textures["models.CharizardTaur.netheriteArmor"])

-- Turtle helmet
charizardArmor.Materials.turtle
	:setTexture(textures["textures.armor.turtleHelmet"] or textures["models.CharizardTaur.turtleHelmet"])
	:setEmissiveTexture(textures["textures.armor.turtleHelmet_e"] or textures["models.CharizardTaur.turtleHelmet_e"])

-- Trims
-- Bolt
charizardArmor.TrimPatterns.bolt
	:setTexture(textures["textures.armor.trims.boltTrim"] or textures["models.CharizardTaur.boltTrim"])

-- Coast
charizardArmor.TrimPatterns.coast
	:setTexture(textures["textures.armor.trims.coastTrim"] or textures["models.CharizardTaur.coastTrim"])

-- Dune
charizardArmor.TrimPatterns.dune
	:setTexture(textures["textures.armor.trims.duneTrim"] or textures["models.CharizardTaur.duneTrim"])

-- Eye
charizardArmor.TrimPatterns.eye
	:setTexture(textures["textures.armor.trims.eyeTrim"] or textures["models.CharizardTaur.eyeTrim"])

-- Flow
charizardArmor.TrimPatterns.flow
	:setTexture(textures["textures.armor.trims.flowTrim"] or textures["models.CharizardTaur.flowTrim"])

-- Host
charizardArmor.TrimPatterns.host
	:setTexture(textures["textures.armor.trims.hostTrim"] or textures["models.CharizardTaur.hostTrim"])

-- Raiser
charizardArmor.TrimPatterns.raiser
	:setTexture(textures["textures.armor.trims.raiserTrim"] or textures["models.CharizardTaur.raiserTrim"])

-- Rib
charizardArmor.TrimPatterns.rib
	:setTexture(textures["textures.armor.trims.ribTrim"] or textures["models.CharizardTaur.ribTrim"])

-- Sentry
charizardArmor.TrimPatterns.sentry
	:setTexture(textures["textures.armor.trims.sentryTrim"] or textures["models.CharizardTaur.sentryTrim"])

-- Shaper
charizardArmor.TrimPatterns.shaper
	:setTexture(textures["textures.armor.trims.shaperTrim"] or textures["models.CharizardTaur.shaperTrim"])

-- Silence
charizardArmor.TrimPatterns.silence
	:setTexture(textures["textures.armor.trims.silenceTrim"] or textures["models.CharizardTaur.silenceTrim"])

-- Snout
charizardArmor.TrimPatterns.snout
	:setTexture(textures["textures.armor.trims.snoutTrim"] or textures["models.CharizardTaur.snoutTrim"])

-- Spire
charizardArmor.TrimPatterns.spire
	:setTexture(textures["textures.armor.trims.spireTrim"] or textures["models.CharizardTaur.spireTrim"])

-- Tide
charizardArmor.TrimPatterns.tide
	:setTexture(textures["textures.armor.trims.tideTrim"] or textures["models.CharizardTaur.tideTrim"])

-- Vex
charizardArmor.TrimPatterns.vex
	:setTexture(textures["textures.armor.trims.vexTrim"] or textures["models.CharizardTaur.vexTrim"])

-- Ward
charizardArmor.TrimPatterns.ward
	:setTexture(textures["textures.armor.trims.wardTrim"] or textures["models.CharizardTaur.wardTrim"])

-- Wayfinder
charizardArmor.TrimPatterns.wayfinder
	:setTexture(textures["textures.armor.trims.wayfinderTrim"] or textures["models.CharizardTaur.wayfinderTrim"])

-- Wild
charizardArmor.TrimPatterns.wild
	:setTexture(textures["textures.armor.trims.wildTrim"] or textures["models.CharizardTaur.wildTrim"])

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

-- All helmet parts
local helmetGroups = {
	
	pokemonParts.headArmorHelmet,
	pokemonParts.HelmetItemPivot
	
}

-- All chestplate parts
local chestplateGroups = {
	
	pokemonParts.bodyArmorChestplate,
	pokemonParts.leftArmArmorChestplate,
	pokemonParts.rightArmArmorChestplate,
	
	pokemonParts.MergeArmorChestplate,
	pokemonParts.TorsoArmorChestplate,
	
	pokemonParts.LowerLeftArmArmorChestplate,
	pokemonParts.LeftForearmArmorChestplate,
	pokemonParts.LeftFingerFArmorChestplate,
	pokemonParts.LeftFingerMArmorChestplate,
	pokemonParts.LeftFingerBArmorChestplate,
	
	pokemonParts.LowerRightArmArmorChestplate,
	pokemonParts.RightForearmArmorChestplate,
	pokemonParts.RightFingerFArmorChestplate,
	pokemonParts.RightFingerMArmorChestplate,
	pokemonParts.RightFingerBArmorChestplate,
	
	pokemonParts.HipsArmorChestplate,
	
	pokemonParts.leftArmArmorChestplateFP,
	pokemonParts.rightArmArmorChestplateFP
	
}

-- All leggings parts
local leggingsGroups = {
	
	pokemonParts.TorsoArmorLeggings,
	pokemonParts.HipsArmorLeggings,
	
	pokemonParts.leftLegArmorLeggings,
	pokemonParts.rightLegArmorLeggings,
	
	pokemonParts.Tail1ArmorLeggings,
	pokemonParts.Tail2ArmorLeggings,
	pokemonParts.Tail3ArmorLeggings
	
}

-- All boots parts
local bootsGroups = {
	
	pokemonParts.LeftFootArmorBoot,
	pokemonParts.RightFootArmorBoot
	
}

function events.TICK()
	
	for _, part in ipairs(helmetGroups) do
		part:visible(helmet)
	end
	
	for _, part in ipairs(chestplateGroups) do
		part:visible(chestplate)
	end
	
	for _, part in ipairs(leggingsGroups) do
		part:visible(leggings)
	end
	
	for _, part in ipairs(bootsGroups) do
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
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor helmet toggle
local function setHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor chestplate toggle
local function setChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor leggings toggle
local function setLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor boots toggle
local function setBoots(boolean)
	
	boots = boolean
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
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
t.allPage = action_wheel:newAction()
	:item(itemCheck("armor_stand"))
	:toggleItem(itemCheck("netherite_chestplate"))
	:onToggle(pings.setArmorAll)

t.helmetPage = action_wheel:newAction()
	:item(itemCheck("iron_helmet"))
	:toggleItem(itemCheck("diamond_helmet"))
	:onToggle(pings.setArmorHelmet)

t.chestplatePage = action_wheel:newAction()
	:item(itemCheck("iron_chestplate"))
	:toggleItem(itemCheck("diamond_chestplate"))
	:onToggle(pings.setArmorChestplate)

t.leggingsPage = action_wheel:newAction()
	:item(itemCheck("iron_leggings"))
	:toggleItem(itemCheck("diamond_leggings"))
	:onToggle(pings.setArmorLeggings)

t.bootsPage = action_wheel:newAction()
	:item(itemCheck("iron_boots"))
	:toggleItem(itemCheck("diamond_boots"))
	:onToggle(pings.setArmorBoots)

-- Update action page info
function events.TICK()
	
	t.allPage
		:title(toJson(
			{
				"",
				{text = "Toggle All Armor\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of all armor parts.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(helmet and chestplate and leggings and boots)
	
	t.helmetPage
		:title(toJson(
			{
				"",
				{text = "Toggle Helmet\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of helmet parts.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(helmet)
	
	t.chestplatePage
		:title(toJson(
			{
				"",
				{text = "Toggle Chestplate\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of chestplate parts.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(chestplate)
	
	t.leggingsPage
		:title(toJson(
			{
				"",
				{text = "Toggle Leggings\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of leggings parts.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(leggings)
	
	t.bootsPage
		:title(toJson(
			{
				"",
				{text = "Toggle Boots\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of boots.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(boots)
	
end

-- Return action wheel pages
return t