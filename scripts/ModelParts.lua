-- Setup table
local t = {}

-- Models setup
t.model    = models.CharizardTaur
t.pokeball = models.Pokeball

-- Model parts
t.root  = t.model.Player
t.upper = t.root.UpperBody
t.lower = t.root.LowerBody

-- Head parts
t.head  = t.upper.Head
t.horns = t.head.Horns

-- Body parts
t.body   = t.upper.Body
t.elytra = t.body.Elytra
t.cape   = t.body.Cape

-- Lower Parts
t.merge = t.lower.Merge
t.torso = t.lower.Torso
t.hips  = t.lower.Hips

-- Arm parts
t.leftArm       = t.upper.LeftArm
t.rightArm      = t.upper.RightArm
t.lowerLeftArm  = t.torso.LowerLeftArm
t.lowerRightArm = t.torso.LowerRightArm
t.leftHand      = t.lowerLeftArm.LeftForearm.LeftHand
t.rightHand     = t.lowerRightArm.RightForearm.RightHand
t.leftArmFP     = t.model.LeftArmFP
t.rightArmFP    = t.model.RightArmFP

-- Leg parts
t.leftLeg   = t.hips.leftLeg
t.rightLeg  = t.hips.rightLeg
t.leftFoot  = t.leftLeg.LeftFoot
t.rightFoot = t.rightLeg.RightFoot

-- Wing parts
t.leftWing  = t.torso.LeftWing1
t.rightWing = t.torso.RightWing1

-- Tail parts
t.tail = t.hips.Tail1
t.fire = t.tail.Tail2.Tail3.Fire
t.tailSegments = {
	t.tail,
	t.tail.Tail2,
	t.tail.Tail2.Tail3
}

-- Misc parts
t.skull    = t.model.Skull
t.portrait = t.model.Portrait

t.skull   :visible(true)
t.portrait:visible(true)

-- All vanilla skin parts
t.skin = {
	
	t.head.Head,
	t.head.Layer,
	
	t.body.Body,
	t.body.Layer,
	
	t.leftArm.leftArmDefault,
	t.leftArm.leftArmSlim,
	t.leftArmFP.leftArmDefaultFP,
	t.leftArmFP.leftArmSlimFP,
	
	t.rightArm.rightArmDefault,
	t.rightArm.rightArmSlim,
	t.rightArmFP.rightArmDefaultFP,
	t.rightArmFP.rightArmSlimFP,
	
	t.portrait.Head,
	t.portrait.Layer,
	
	t.skull.Head,
	t.skull.Layer
	
}

-- All layer parts
t.layer = {
	
	HAT = {
		t.head.Layer
	},
	JACKET = {
		t.body.Layer
	},
	RIGHT_SLEEVE = {
		t.leftArm.leftArmDefault.Layer,
		t.leftArm.leftArmSlim.Layer,
		t.lowerLeftArm.Layer,
		t.lowerLeftArm.LeftForearm.Layer,
		t.leftHand.LeftFingerF.Layer,
		t.leftHand.LeftFingerM.Layer,
		t.leftHand.LeftFingerB.Layer,
		t.leftArmFP.leftArmDefaultFP.Layer,
		t.leftArmFP.leftArmSlimFP.Layer
	},
	RIGHT_SLEEVE = {
		t.rightArm.rightArmDefault.Layer,
		t.rightArm.rightArmSlim.Layer,
		t.lowerRightArm.Layer,
		t.lowerRightArm.RightForearm.Layer,
		t.rightHand.RightFingerF.Layer,
		t.rightHand.RightFingerM.Layer,
		t.rightHand.RightFingerB.Layer,
		t.rightArmFP.rightArmDefaultFP.Layer,
		t.rightArmFP.rightArmSlimFP.Layer
	},
	LEFT_PANTS_LEG = {
		t.leftLeg.Layer,
		t.leftFoot.Layer
	},
	RIGHT_PANTS_LEG = {
		t.rightLeg.Layer,
		t.rightFoot.Layer
	},
	CAPE = {
		t.cape
	},
	LOWER_BODY = {
		t.merge.Layer,
		t.torso.Layer,
		t.hips.Layer,
		t.tail.Layer,
		t.tail.Tail2.Layer,
		t.tail.Tail2.Tail3.Layer
	}
}

-- All helmet parts
t.helmetToggle = {
	
	t.head.headArmorHelmet,
	t.head.HelmetItemPivot
	
}

-- All chestplate parts
t.chestplateToggle = {
	
	t.body.bodyArmorChestplate,
	t.leftArm.leftArmArmorChestplate,
	t.rightArm.rightArmArmorChestplate,
	
	t.merge.MergeArmorChestplate,
	t.torso.TorsoArmorChestplate,
	
	t.lowerLeftArm.LowerLeftArmArmorChestplate,
	t.lowerLeftArm.LeftForearm.LeftForearmArmorChestplate,
	t.leftHand.LeftFingerF.LeftFingerFArmorChestplate,
	t.leftHand.LeftFingerM.LeftFingerMArmorChestplate,
	t.leftHand.LeftFingerB.LeftFingerBArmorChestplate,
	
	t.lowerRightArm.LowerRightArmArmorChestplate,
	t.lowerRightArm.RightForearm.RightForearmArmorChestplate,
	t.rightHand.RightFingerF.RightFingerFArmorChestplate,
	t.rightHand.RightFingerM.RightFingerMArmorChestplate,
	t.rightHand.RightFingerB.RightFingerBArmorChestplate,
	
	t.hips.HipsArmorChestplate,
	
	t.leftArmFP.leftArmArmorChestplateFP,
	t.rightArmFP.rightArmArmorChestplateFP
	
}

-- All leggings parts
t.leggingsToggle = {
	
	t.torso.TorsoArmorLeggings,
	t.hips.HipsArmorLeggings,
	
	t.leftLeg.leftLegArmorLeggings,
	t.rightLeg.rightLegArmorLeggings,
	
	t.tail.Tail1ArmorLeggings,
	t.tail.Tail2.Tail2ArmorLeggings,
	t.tail.Tail2.Tail3.Tail3ArmorLeggings
	
}

-- All boots parts
t.bootsToggle = {
	
	t.leftFoot.LeftFootArmorBoot,
	t.rightFoot.RightFootArmorBoot
	
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
t.planeParts = {
	
	-- Left wing
	t.leftWing.Membrane,
	t.leftWing.LeftWing2.Membrane,
	t.leftWing.LeftWing2.LeftWing3.Membrane,
	
	-- Right wing
	t.rightWing.Membrane,
	t.rightWing.RightWing2.Membrane,
	t.rightWing.RightWing2.RightWing3.Membrane,
	
	-- Left arm claws
	t.leftHand.LeftFingerF.Claw,
	t.leftHand.LeftFingerM.Claw,
	t.leftHand.LeftFingerB.Claw,
	
	-- Right arm claws
	t.rightHand.RightFingerF.Claw,
	t.rightHand.RightFingerM.Claw,
	t.rightHand.RightFingerB.Claw,
	
	-- Left leg claws
	t.leftFoot.ClawL,
	t.leftFoot.ClawM,
	t.leftFoot.ClawR,
	
	-- Right leg claws
	t.rightFoot.ClawL,
	t.rightFoot.ClawM,
	t.rightFoot.ClawR,
	
	-- Fire
	t.fire.FireX,
	t.fire.FireZ
	
}

-- Apply
for _, part in ipairs(t.planeParts) do
	part:primaryRenderType("TRANSLUCENT_CULL")
end

-- Return model parts table
return t