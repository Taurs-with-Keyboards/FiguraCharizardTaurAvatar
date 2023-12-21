-- Model setup
local model     = models.CharizardTaur
local upperRoot = model.Player.UpperBody
local lowerRoot = model.Player.LowerBody

-- Katt armor setup
local kattArmor = require("lib.KattArmor")()

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Helmet
	:addParts(upperRoot.Head.headArmor.Helmet)
	:addTrimParts(upperRoot.Head.headArmor.HelmetTrim)
kattArmor.Armor.Chestplate
	:addParts(
		upperRoot.Body.bodyArmor.Chestplate,
		upperRoot.Body.bodyArmor.Belt,
		upperRoot.RightArm.rightArmArmor.Chestplate,
		upperRoot.LeftArm.leftArmArmor.Chestplate,
		model.RightArmFP.rightArmArmorFP.Chestplate,
		model.LeftArmFP.leftArmArmorFP.Chestplate,
		lowerRoot.Midsection.MidsectionArmor.MergeChestplate,
		lowerRoot.Midsection.MidsectionArmor.TorsoChestplate,
		lowerRoot.Midsection.LowerRightArm.LowerRightArmArmor.Chestplate,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightForearmArmor.Chestplate,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerF.RightFingerFArmor.Chestplate,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerM.RightFingerMArmor.Chestplate,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerB.RightFingerBArmor.Chestplate,
		lowerRoot.Midsection.LowerLeftArm.LowerLeftArmArmor.Chestplate,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftForearmArmor.Chestplate,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerF.LeftFingerFArmor.Chestplate,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerM.LeftFingerMArmor.Chestplate,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerB.LeftFingerBArmor.Chestplate,
		lowerRoot.LowerBodyArmor.Chestplate
	)
	:addTrimParts(
		upperRoot.Body.bodyArmor.ChestplateTrim,
		upperRoot.Body.bodyArmor.BeltTrim,
		upperRoot.RightArm.rightArmArmor.ChestplateTrim,
		upperRoot.LeftArm.leftArmArmor.ChestplateTrim,
		model.RightArmFP.rightArmArmorFP.ChestplateTrim,
		model.LeftArmFP.leftArmArmorFP.ChestplateTrim,
		lowerRoot.Midsection.MidsectionArmor.MergeChestplateTrim,
		lowerRoot.Midsection.MidsectionArmor.TorsoChestplateTrim,
		lowerRoot.Midsection.LowerRightArm.LowerRightArmArmor.ChestplateTrim,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightForearmArmor.ChestplateTrim,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerF.RightFingerFArmor.ChestplateTrim,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerM.RightFingerMArmor.ChestplateTrim,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerB.RightFingerBArmor.ChestplateTrim,
		lowerRoot.Midsection.LowerLeftArm.LowerLeftArmArmor.ChestplateTrim,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftForearmArmor.ChestplateTrim,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerF.LeftFingerFArmor.ChestplateTrim,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerM.LeftFingerMArmor.ChestplateTrim,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerB.LeftFingerBArmor.ChestplateTrim,
		lowerRoot.LowerBodyArmor.ChestplateTrim
	)
kattArmor.Armor.Leggings
	:addParts(
		lowerRoot.Midsection.MidsectionArmor.Leggings,
		lowerRoot.LowerBodyArmor.Leggings,
		lowerRoot.Tail1.Tail1Armor.Leggings,
		lowerRoot.Tail1.Tail2.Tail2Armor.Leggings,
		lowerRoot.Tail1.Tail2.Tail3.Tail3Armor.Leggings,
		lowerRoot.rightLeg.rightLegArmor.Leggings,
		lowerRoot.leftLeg.leftLegArmor.Leggings
	)
	:addTrimParts(
		lowerRoot.Midsection.MidsectionArmor.LeggingsTrim,
		lowerRoot.LowerBodyArmor.LeggingsTrim,
		lowerRoot.Tail1.Tail1Armor.LeggingsTrim,
		lowerRoot.Tail1.Tail2.Tail2Armor.LeggingsTrim,
		lowerRoot.Tail1.Tail2.Tail3.Tail3Armor.LeggingsTrim,
		lowerRoot.rightLeg.rightLegArmor.LeggingsTrim,
		lowerRoot.leftLeg.leftLegArmor.LeggingsTrim
	)
kattArmor.Armor.Boots
	:addParts(
		lowerRoot.rightLeg.RightFoot.RightFootArmor.Boot,
		lowerRoot.leftLeg.LeftFoot.LeftFootArmor.Boot
	)
	:addTrimParts(
		lowerRoot.rightLeg.RightFoot.RightFootArmor.BootTrim,
		lowerRoot.leftLeg.LeftFoot.LeftFootArmor.BootTrim
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"])
	:addParts(kattArmor.Armor.Helmet,
		upperRoot.Head.headArmor.HelmetLeather
	)
	:addParts(kattArmor.Armor.Chestplate,
		upperRoot.Body.bodyArmor.ChestplateLeather,
		upperRoot.Body.bodyArmor.BeltLeather,
		upperRoot.RightArm.rightArmArmor.ChestplateLeather,
		upperRoot.LeftArm.leftArmArmor.ChestplateLeather,
		model.RightArmFP.rightArmArmorFP.ChestplateLeather,
		model.LeftArmFP.leftArmArmorFP.ChestplateLeather,
		lowerRoot.Midsection.MidsectionArmor.MergeChestplateLeather,
		lowerRoot.Midsection.MidsectionArmor.TorsoChestplateLeather,
		lowerRoot.Midsection.LowerRightArm.LowerRightArmArmor.ChestplateLeather,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightForearmArmor.ChestplateLeather,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerF.RightFingerFArmor.ChestplateLeather,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerM.RightFingerMArmor.ChestplateLeather,
		lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerB.RightFingerBArmor.ChestplateLeather,
		lowerRoot.Midsection.LowerLeftArm.LowerLeftArmArmor.ChestplateLeather,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftForearmArmor.ChestplateLeather,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerF.LeftFingerFArmor.ChestplateLeather,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerM.LeftFingerMArmor.ChestplateLeather,
		lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerB.LeftFingerBArmor.ChestplateLeather,
		lowerRoot.LowerBodyArmor.ChestplateLeather
	)
	:addParts(kattArmor.Armor.Leggings,
		lowerRoot.Midsection.MidsectionArmor.LeggingsLeather,
		lowerRoot.LowerBodyArmor.LeggingsLeather,
		lowerRoot.Tail1.Tail1Armor.LeggingsLeather,
		lowerRoot.Tail1.Tail2.Tail2Armor.LeggingsLeather,
		lowerRoot.Tail1.Tail2.Tail3.Tail3Armor.LeggingsLeather,
		lowerRoot.rightLeg.rightLegArmor.LeggingsLeather,
		lowerRoot.leftLeg.leftLegArmor.LeggingsLeather
	)
	:addParts(kattArmor.Armor.Boots,
		lowerRoot.rightLeg.RightFoot.RightFootArmor.BootLeather,
		lowerRoot.leftLeg.LeftFoot.LeftFootArmor.BootLeather
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