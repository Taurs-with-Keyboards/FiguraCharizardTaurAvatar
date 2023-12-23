-- Model setup
local model     = models.CharizardTaur
local upperRoot = model.Player.UpperBody
local lowerRoot = model.Player.LowerBody
local anims     = animations.CharizardTaur

-- API setup
local arm  = require("lib.MOARArmsAPI")
local pose = require("scripts.Posing")

-- Arms setup
local fakeLeftArm   = model.LeftArmFP
local fakeRightArm  = model.RightArmFP
local upperLeftArm  = arm:newArm(1, "LEFT",  upperRoot.Body.LeftArm.UpperLeftArmItem,   upperRoot.Body.LeftArm,  "OFFHAND")
local upperRightArm = arm:newArm(1, "RIGHT", upperRoot.Body.RightArm.UpperRightArmItem, upperRoot.Body.RightArm, "MAINHAND")
local lowerLeftArm  = arm:newArm(2, "LEFT",  lowerRoot.Midsection.LowerLeftArm.LeftForearm.LeftHand.LeftFingerM.LowerLeftArmItem, lowerRoot.Midsection.LowerLeftArm, 1,
	{WALK = 0, OVERRIDE = 0},
	{HOLD = anims.holdLeft})
local lowerRightArm = arm:newArm(2, "RIGHT", lowerRoot.Midsection.LowerRightArm.RightForearm.RightHand.RightFingerM.LowerRightArmItem, lowerRoot.Midsection.LowerRightArm, 2,
	{WALK = 0, OVERRIDE = 0},
	{HOLD = anims.holdRight})

anims.holdLeft:priority(1)
anims.holdRight:priority(1)

-- Config setup
config:name("CharizardTaur")
local armMove  = config:load("AvatarArmMove") or false
local holdItem = config:load("AvatarArmItems") or false

function events.TICK()
	
	local shouldMove = (armMove or pose.swim or pose.crawl) and 1 or 0
	
	upperLeftArm.AnimOptions.WALK      = shouldMove
	upperLeftArm.AnimOptions.OVERRIDE  = shouldMove
	upperRightArm.AnimOptions.WALK     = shouldMove
	upperRightArm.AnimOptions.OVERRIDE = shouldMove
	
	-- upperLeftArm:changeItem(     player:isLeftHanded() and "MAINHAND" or "OFFHAND")
	-- upperRightArm:changeItem(not player:isLeftHanded() and "MAINHAND" or "OFFHAND")
	lowerLeftArm:changeItem(holdItem and 1 or -1)
	lowerRightArm:changeItem(holdItem and 2 or -1)
	
end

function events.RENDER(delta, context)
	
	local firstPerson = context == "FIRST_PERSON"
	
	fakeRightArm:visible(firstPerson)
	fakeLeftArm:visible(firstPerson)
	
	local body = vanilla_model.BODY:getOriginRot()._yz
	
	lowerRoot.Midsection:offsetRot(body)
	lowerRoot.Midsection.RightWing1:offsetRot(-body)
	lowerRoot.Midsection.LeftWing1:offsetRot(-body)
end

-- Arm Movement toggler
local function setArmMove(boolean)
	armMove = boolean
	config:save("AvatarArmMove", armMove)
end

-- Arm Hold Items toggler
local function setArmItems(boolean)
	holdItem = boolean
	config:save("AvatarArmItems", holdItem)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
end

-- Sync variable
local function syncArms(a, b)
	armMove  = a
	holdItem = b
end

-- Ping setup
pings.setAvatarArmMove  = setArmMove
pings.setAvatarArmItems = setArmItems
pings.syncArms          = syncArms

-- Sync on tick
if host:isHost() then
	function events.TICK()
		if world.getTime() % 200 == 0 then
			pings.syncArms(armMove, holdItem)
		end
	end
end

-- Activate action
setArmMove(armMove)
setArmItems(holdItem)

-- Table setup
local t = {}

-- Action wheel pages
t.movePage = action_wheel:newAction("ArmMovement")
	:title("§6§lArm Movement Toggle\n\n§3Toggles the movement swing movement of the arms.\nActions are not effected.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:red_dye")
	:toggleItem("minecraft:rabbit_foot")
	:onToggle(pings.setAvatarArmMove)
	:toggled(armMove)

t.holdPage = action_wheel:newAction("ArmHoldItems")
	:title("§6§lTentacle Hold Items Toggle\n\n§3Toggles the usage of your lower arms for holding and using items.\nUses slots 1 & 2 respectively.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:stick")
	:toggleItem("minecraft:diamond_sword")
	:onToggle(pings.setAvatarArmItems)
	:toggled(holdItem)

-- Return table
return t