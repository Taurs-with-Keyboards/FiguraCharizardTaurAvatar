-- Setup table
local t = {}

-- Index a model's or model part's child groups into a table
local function groupIndex(m)
	
	local children = m:getChildren()
	
	for _, p in ipairs(children) do
		if p:getType() == "GROUP" then
			t[p:getName()] = p
			groupIndex(p)
		end
	end
	
end

-- Call group index
groupIndex(models)

-- All tail segments
t.tailSegments = {
	t.Tail1,
	t.Tail2,
	t.Tail3
}

-- All vanilla skin parts
t.skin = {
	
	t.Head.Head,
	t.Head.Layer,
	
	t.Body.Body,
	t.Body.Layer,
	
	t.LeftArm.leftArmDefault,
	t.LeftArm.leftArmSlim,
	t.LeftArmFP.leftArmDefaultFP,
	t.LeftArmFP.leftArmSlimFP,
	
	t.RightArm.rightArmDefault,
	t.RightArm.rightArmSlim,
	t.RightArmFP.rightArmDefaultFP,
	t.RightArmFP.rightArmSlimFP,
	
	t.Portrait.Head,
	t.Portrait.Layer,
	
	t.Skull.Head,
	t.Skull.Layer
	
}

-- All layer parts
t.layer = {
	
	HAT = {
		t.Head.Layer
	},
	JACKET = {
		t.Body.Layer
	},
	RIGHT_SLEEVE = {
		t.leftArmDefault.Layer,
		t.leftArmSlim.Layer,
		t.LowerLeftArm.Layer,
		t.LeftForearm.Layer,
		t.LeftFingerF.Layer,
		t.LeftFingerM.Layer,
		t.LeftFingerB.Layer,
		t.leftArmDefaultFP.Layer,
		t.leftArmSlimFP.Layer
	},
	RIGHT_SLEEVE = {
		t.rightArmDefault.Layer,
		t.rightArmSlim.Layer,
		t.LowerRightArm.Layer,
		t.RightForearm.Layer,
		t.RightFingerF.Layer,
		t.RightFingerM.Layer,
		t.RightFingerB.Layer,
		t.rightArmDefaultFP.Layer,
		t.rightArmSlimFP.Layer
	},
	LEFT_PANTS_LEG = {
		t.leftLeg.Layer,
		t.LeftFoot.Layer
	},
	RIGHT_PANTS_LEG = {
		t.rightLeg.Layer,
		t.RightFoot.Layer
	},
	CAPE = {
		t.Cape
	},
	LOWER_BODY = {
		t.Merge.Layer,
		t.Torso.Layer,
		t.Hips.Layer,
		t.Tail1.Layer,
		t.Tail2.Layer,
		t.Tail3.Layer
	}
}

-- All helmet parts
t.helmetToggle = {
	
	t.headArmorHelmet,
	t.HelmetItemPivot
	
}

-- All chestplate parts
t.chestplateToggle = {
	
	t.bodyArmorChestplate,
	t.leftArmArmorChestplate,
	t.rightArmArmorChestplate,
	
	t.MergeArmorChestplate,
	t.TorsoArmorChestplate,
	
	t.LowerLeftArmArmorChestplate,
	t.LeftForearmArmorChestplate,
	t.LeftFingerFArmorChestplate,
	t.LeftFingerMArmorChestplate,
	t.LeftFingerBArmorChestplate,
	
	t.LowerRightArmArmorChestplate,
	t.RightForearmArmorChestplate,
	t.RightFingerFArmorChestplate,
	t.RightFingerMArmorChestplate,
	t.RightFingerBArmorChestplate,
	
	t.HipsArmorChestplate,
	
	t.leftArmArmorChestplateFP,
	t.rightArmArmorChestplateFP
	
}

-- All leggings parts
t.leggingsToggle = {
	
	t.TorsoArmorLeggings,
	t.HipsArmorLeggings,
	
	t.leftLegArmorLeggings,
	t.rightLegArmorLeggings,
	
	t.Tail1ArmorLeggings,
	t.Tail2ArmorLeggings,
	t.Tail3ArmorLeggings
	
}

-- All boots parts
t.bootsToggle = {
	
	t.LeftFootArmorBoot,
	t.RightFootArmorBoot
	
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
	t.LeftWing1.Membrane,
	t.LeftWing2.Membrane,
	t.LeftWing3.Membrane,
	
	-- Right wing
	t.RightWing1.Membrane,
	t.RightWing2.Membrane,
	t.RightWing3.Membrane,
	
	-- Left arm claws
	t.LeftFingerF.Claw,
	t.LeftFingerM.Claw,
	t.LeftFingerB.Claw,
	
	-- Right arm claws
	t.RightFingerF.Claw,
	t.RightFingerM.Claw,
	t.RightFingerB.Claw,
	
	-- Left leg claws
	t.LeftFoot.ClawL,
	t.LeftFoot.ClawM,
	t.LeftFoot.ClawR,
	
	-- Right leg claws
	t.RightFoot.ClawL,
	t.RightFoot.ClawM,
	t.RightFoot.ClawR,
	
	-- Fire
	t.Fire.FireX,
	t.Fire.FireZ
	
}

-- Apply
for _, part in ipairs(t.planeParts) do
	part:primaryRenderType("TRANSLUCENT_CULL")
end

-- Set skull and portrait groups to visible (incase disabled in blockbench)
t.Skull   :visible(true)
t.Portrait:visible(true)

-- Return model parts table
return t