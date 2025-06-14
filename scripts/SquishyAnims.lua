-- Kills script if squAPI or squAssets cannot be found
local s, squapi = pcall(require, "lib.SquAPI")
if not s then return {} end
local s, squassets = pcall(require, "lib.SquAssets")
if not s then return {} end

-- Required scripts
local parts   = require("lib.PartsAPI")
local lerp    = require("lib.LerpAPI")
local pose    = require("scripts.Posing")
local effects = require("scripts.SyncedVariables")

-- Config setup
config:name("CharizardTaur")
local armsMove = config:load("SquapiArmsMove") or false

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

-- Lerp tables
local leftArmLerp  = lerp:new(0.5, armsMove and 1 or 0)
local rightArmLerp = lerp:new(0.5, armsMove and 1 or 0)

-- Tails table
local tailParts = parts:createChain("Tail")

-- Squishy tail
local tail = squapi.tail:new(
	tailParts,
	20,    -- Intensity X (20)
	10,    -- Intensity Y (10)
	0.75,  -- Speed X (0.75)
	0.25,  -- Speed Y (0.25)
	3,     -- Bend (3)
	0,     -- Velocity Push (0)
	0,     -- Initial Offset (0)
	1,     -- Seg Offset (1)
	0.005, -- Stiffness (0.005)
	0.925, -- Bounce (0.935)
	25,    -- Fly Offset (25)
	-45,   -- Down Limit (-45)
	45     -- Up Limit (45)
)

-- Head table
local headParts = {
	
	parts.group.UpperBody
	
}

-- Squishy smooth torso
local head = squapi.smoothHead:new(
	headParts,
	0.3,  -- Strength (0.3)
	0.4,  -- Tilt (0.4)
	1,    -- Speed (1)
	false -- Keep Original Head Pos (false)
)

-- Squishy vanilla arms
local leftArm = squapi.arm:new(
	parts.group.LeftArm,
	1,     -- Strength (1)
	false, -- Right Arm (false)
	true   -- Keep Position (true)
)

local rightArm = squapi.arm:new(
	parts.group.RightArm,
	1,    -- Strength (1)
	true, -- Right Arm (true)
	true  -- Keep Position (true)
)

-- Arm strength variables
local leftArmStrength  = leftArm.strength
local rightArmStrength = rightArm.strength

-- Squishy animated texture
local fire = squapi.animateTexture(
	parts.group.Fire,
	4,    -- Frames
	0.25, -- Frame percentage
	2     -- Speed
)

-- Wings bounce
local wingsy = squassets.BERP:new(0.01, 0.9)
local wingsz = squassets.BERP:new(0.01, 0.9)
local wingsTargets = vec(0, 0, 0)
local oldPose = "STANDING"

function events.TICK()
	
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
	local bow         = using and (usingL == "BOW" or usingR == "BOW")
	local crossL      = leftItem.tag and leftItem.tag["Charged"] == 1
	local crossR      = rightItem.tag and rightItem.tag["Charged"] == 1
	
	-- Arm movement overrides
	local armShouldMove = pose.swim or pose.crawl
	
	-- Control targets based on variables
	leftArmLerp.target  = (armsMove or armShouldMove or leftSwing  or bow or ((crossL or crossR) or (using and usingL ~= "NONE"))) and 1 or 0
	rightArmLerp.target = (armsMove or armShouldMove or rightSwing or bow or ((crossL or crossR) or (using and usingR ~= "NONE"))) and 1 or 0
	
	-- Vel
	local vel  = math.clamp(squassets.forwardVel(),  -0.5, 0.5)
	local yvel = math.clamp(squassets.verticalVel(), -0.5, 0.5)
	
	-- Crouch boost
	if pose.crouch and oldPose == "STANDING" then
		wingsz.vel = wingsz.vel + 2.5
	elseif pose.stand and oldPose == "CROUCHING" then
		wingsz.vel = wingsz.vel - 2.5
	end
	oldPose = player:getPose()
	
	-- Set targets
	if pose.elytra or pose.swim or pose.crawl or effects.cF then
		wingsTargets.y = 0
		wingsTargets.z = 0
	else
		wingsTargets.y = vel * 100
		wingsTargets.z = -yvel * 50
	end
	
end

function events.RENDER(delta, context)
	
	-- Variables
	local idleTimer   = world.getTime(delta)
	local idleRot     = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	local firstPerson = context == "FIRST_PERSON"
	
	-- Adjust arm strengths
	leftArm.strength  = leftArmStrength  * leftArmLerp.currPos
	rightArm.strength = rightArmStrength * rightArmLerp.currPos
	
	-- Adjust arm characteristics after applied by squapi
	parts.group.LeftArm
		:offsetRot(
			parts.group.LeftArm:getOffsetRot()
			+ ((-idleRot + (vanilla_model.BODY:getOriginRot() * 0.75)) * math.map(leftArmLerp.currPos, 0, 1, 1, 0))
		)
		:pos(parts.group.LeftArm:getPos() * vec(1, 1, -1))
		:visible(not firstPerson)
	
	parts.group.RightArm
		:offsetRot(
			parts.group.RightArm:getOffsetRot()
			+ ((idleRot + (vanilla_model.BODY:getOriginRot() * 0.75)) * math.map(rightArmLerp.currPos, 0, 1, 1, 0))
		)
		:pos(parts.group.RightArm:getPos() * vec(1, 1, -1))
		:visible(not firstPerson)
	
	-- Set visible if in first person
	parts.group.LeftArmFP:visible(firstPerson)
	parts.group.RightArmFP:visible(firstPerson)
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `parts.group.body`
	for _, group in ipairs(parts.group.UpperBody:getChildren()) do
		if group ~= parts.group.Body then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
	-- Calc wing bounce
	wingsy:berp(wingsTargets.y, delta)
	wingsz:berp(wingsTargets.z, delta)
	
	-- Apply wing bounce
	parts.group.LeftWing1:setOffsetRot(0,   wingsy.pos, -wingsz.pos)
	parts.group.RightWing1:setOffsetRot(0, -wingsy.pos,  wingsz.pos)
	
end

-- Arm movement toggle
function pings.setSquapiArmsMove(boolean)
	
	armsMove = boolean
	config:save("SquapiArmsMove", armsMove)
	
end

-- Sync variable
function pings.syncSquapi(a)
	
	armsMove = a
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncSquapi(armsMove)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.armsAct = action_wheel:newAction()
	:item(itemCheck("red_dye"))
	:toggleItem(itemCheck("rabbit_foot"))
	:onToggle(pings.setSquapiArmsMove)
	:toggled(armsMove)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.armsAct
			:title(toJson(
				{
					"",
					{text = "Arm Movement Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the movement swing movement of the arms.\nActions are not effected.", color = c.secondary}
				}
			))
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return action
return t