-- Model setup
local model     = models.CharizardTaur
local upperRoot = model.Player.UpperBody
local lowerRoot = model.Player.LowerBody

-- Config setup
config:name("CharizardTaur")
local lowerArms = config:load("AvatarLowerArms") or false

-- Variables setup
local pose = require("scripts.Posing")
local uRCurrent, uRNextTick, uRTarget, uRCurrentPos = 0, 0, 0, 0
local uLCurrent, uLNextTick, uLTarget, uLCurrentPos = 0, 0, 0, 0
local lRCurrent, lRNextTick, lRTarget, lRCurrentPos = 0, 0, 0, 0
local lLCurrent, lLNextTick, lLTarget, lLCurrentPos = 0, 0, 0, 0

local mRCurrent, mRNextTick, mRTarget, mRCurrentPos = vec(1, 1, 1), vec(1, 1, 1), vec(1, 1, 1), vec(1, 1, 1)
local mLCurrent, mLNextTick, mLTarget, mLCurrentPos = vec(1, 1, 1), vec(1, 1, 1), vec(1, 1, 1), vec(1, 1, 1)
local aRCurrent, aRNextTick, aRTarget, aRCurrentPos = vec(0, 0, 0), vec(0, 0, 0), vec(0, 0, 0), vec(0, 0, 0)
local aLCurrent, aLNextTick, aLTarget, aLCurrentPos = vec(0, 0, 0), vec(0, 0, 0), vec(0, 0, 0), vec(0, 0, 0)

-- Arms setup
local upperRightArm = upperRoot.RightArm
local upperLeftArm  = upperRoot.LeftArm
local fakeLeftArm   = model.LeftArm
local fakeRightArm  = model.RightArm
local lowerRightArm = lowerRoot.Upper.ArmRight
local lowerLeftArm  = lowerRoot.Upper.ArmLeft

local lastFrozen = 0
local isFreezing = false
function events.TICK()
	uRCurrent, uLCurrent, lRCurrent, lLCurrent = uRNextTick, uLNextTick, lRNextTick, lLNextTick
	uRNextTick = math.lerp(uRNextTick, uRTarget, 0.75)
	uLNextTick = math.lerp(uLNextTick, uLTarget, 0.75)
	lRNextTick = math.lerp(lRNextTick, lRTarget, 0.75)
	lLNextTick = math.lerp(lLNextTick, lLTarget, 0.75)
	
	mRCurrent, mLCurrent, aRCurrent, aLCurrent = mRNextTick, mLNextTick, aRNextTick, aLNextTick
	mRNextTick = math.lerp(mRNextTick, mRTarget, 0.75)
	mLNextTick = math.lerp(mLNextTick, mLTarget, 0.75)
	aRNextTick = math.lerp(aRNextTick, aRTarget, 0.75)
	aLNextTick = math.lerp(aLNextTick, aLTarget, 0.75)
	
	isFreezing = player:getFrozenTicks() ~= 0 and player:getFrozenTicks() >= lastFrozen
	lastFrozen = player:getFrozenTicks()
end

function events.RENDER(delta, context)
	-- Idle setup
	local idleTimer = world.getTime(delta)
	local idleRot   = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	
	-- Arm variables
	local handedness  = player:isLeftHanded()
	local activeness  = player:getActiveHand()
	local leftActive  = not handedness and "OFF_HAND" or "MAIN_HAND"
	local rightActive = handedness and "OFF_HAND" or "MAIN_HAND"
	local leftSwing   = player:getSwingArm() == leftActive
	local rightSwing  = player:getSwingArm() == rightActive
	local leftItem    = player:getHeldItem(not handedness)
	local rightItem   = player:getHeldItem(handedness)
	local using       = player:isUsingItem()
	local usingL      = activeness == leftActive and leftItem:getUseAction() or "NONE"
	local usingR      = activeness == rightActive and rightItem:getUseAction() or "NONE"
	local crossL      = leftItem.tag and leftItem.tag["Charged"] == 1
	local crossR      = rightItem.tag and rightItem.tag["Charged"] == 1
	
	local topMove    = false or pose.swim or pose.climb
	local bottomMove = false or false
	local bothMove   = false or isFreezing
	
	uRTarget = (bothMove or not lowerArms and (topMove or rightSwing or ((crossL or crossR) or (using and usingR ~= "NONE")))) and 0 or 1
	uLTarget = (bothMove or not lowerArms and (topMove or leftSwing  or ((crossL or crossR) or (using and usingL ~= "NONE")))) and 0 or 1
	lRTarget = (bothMove or lowerArms and  (bottomMove or rightSwing or ((crossL or crossR) or (using and usingR ~= "NONE")))) and 1 or 0
	lLTarget = (bothMove or lowerArms and  (bottomMove or leftSwing  or ((crossL or crossR) or (using and usingL ~= "NONE")))) and 1 or 0
	
	uRCurrentPos = math.lerp(uRCurrent, uRNextTick, delta)
	uLCurrentPos = math.lerp(uLCurrent, uLNextTick, delta)
	lRCurrentPos = math.lerp(lRCurrent, lRNextTick, delta)
	lLCurrentPos = math.lerp(lLCurrent, lLNextTick, delta)
	
	local firstPerson = context == "FIRST_PERSON"
	
	upperRightArm:rot((-vanilla_model.RIGHT_ARM:getOriginRot() + idleRot) * uRCurrentPos)
		:visible(not firstPerson)
	
	fakeRightArm:visible(firstPerson)
	
	upperLeftArm:rot((-vanilla_model.LEFT_ARM:getOriginRot() + -idleRot) * uLCurrentPos)
		:visible(not firstPerson)
		
	fakeLeftArm:visible(firstPerson)
	
	upperRightArm.RightItemPivot:visible(not lowerArms)
	upperLeftArm.LeftItemPivot:visible(not lowerArms)
	
	local spyglassR = using and usingR == "SPYGLASS"
	local spyglassL = using and usingL == "SPYGLASS"
	local spearR    = using and usingR == "SPEAR"
	local spearL    = using and usingL == "SPEAR"
	
	local rightOrigin = vanilla_model.RIGHT_ARM:getOriginRot()
	local leftOrigin  = vanilla_model.LEFT_ARM:getOriginRot()
	
	local rightRot = spyglassR and vec(rightOrigin.z, rightOrigin.x, rightOrigin.y) or vec(-rightOrigin.y, rightOrigin.x, rightOrigin.z)
	local leftRot  = spyglassL and vec(leftOrigin.z,  leftOrigin.x,  leftOrigin.y)  or vec( leftOrigin.y, -leftOrigin.x,  leftOrigin.z)
	
	mRTarget = spyglassR and vec(1, 0.75, 0.5) or vec(1, 1, 1)
	mLTarget = spyglassL and vec(1, 0.75, 0.5) or vec(1, 1, 1)
	
	mRCurrentPos = math.lerp(mRCurrent, mRNextTick, delta)
	mLCurrentPos = math.lerp(mLCurrent, mLNextTick, delta)
	
	aRTarget = spearR and vec(20, -30, -50) or spyglassR and vec(0, 70, -40) or isFreezing and vec(-60, 0, 40) or vec(0, 0, 0)
	aLTarget = spearL and vec(20, 30, 50) or spyglassL and vec(0, -70, 40) or isFreezing and vec(-60, 0, -40) or vec(0, 0, 0)
	
	aRCurrentPos = math.lerp(aRCurrent, aRNextTick, delta)
	aLCurrentPos = math.lerp(aLCurrent, aLNextTick, delta)
	
	local rightApply = rightRot * mRCurrentPos + aRTarget
	local leftApply  = leftRot  * mLCurrentPos + aLTarget
	
	lowerRightArm:offsetRot(rightApply * lRCurrentPos)
	lowerLeftArm:offsetRot(leftApply * lLCurrentPos)
	
	lowerRightArm.Forearm.Hand.FingerM.RightItemPivot:visible(lowerArms)
	lowerLeftArm.Forearm.Hand.FingerM.LeftItemPivot:visible(lowerArms)
	
	local body = vanilla_model.BODY:getOriginRot()._yz
	
	lowerRoot.Upper:offsetRot(body)
	lowerRoot.Upper.WingRight:offsetRot(-body)
	lowerRoot.Upper.WingLeft:offsetRot(-body)
end

-- Arm Movement toggler
local function setLowerArms(boolean)
	lowerArms = boolean
	config:save("AvatarLowerArms", lowerArms)
end

-- Sync variable
local function syncArms(a)
	lowerArms = a
end

-- Ping setup
pings.setAvatarLowerArms = setLowerArms
pings.syncArms           = syncArms

-- Sync on tick
if host:isHost() then
	function events.TICK()
		if world.getTime() % 200 == 0 then
			pings.syncArms(lowerArms)
		end
	end
end

-- Activate action
setLowerArms(lowerArms)

-- Return action wheel page
return action_wheel:newAction("LowerArms")
	:title("§6§lLower Arms Toggle\n\n§3Toggles the usage of the lower arms over the upper arms.\nSome actions are not effected.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:red_dye")
	:toggleItem("minecraft:rabbit_foot")
	:onToggle(pings.setAvatarLowerArms)
	:toggled(lowerArms)