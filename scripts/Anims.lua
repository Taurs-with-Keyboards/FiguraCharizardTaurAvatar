-- Required scripts
require("lib.GSAnimBlend")
require("lib.Molang")
local parts   = require("lib.PartsAPI")
local sync    = require("lib.LetThatSyncFig")
local lerp    = require("lib.LerpAPI")
local ground  = require("lib.GroundCheck")
local pose    = require("scripts.Posing")
local effects = require("scripts.SyncedVariables")

-- Animations setup
local anims = animations.CharizardTaur

-- Synced variables setup
local armsMove = sync.new("AnimsArms", false):config()

-- Arms setup
local leftArmLerp  = lerp.new(armsMove.curr and 1 or 0, 0.5)
local rightArmLerp = lerp.new(armsMove.curr and 1 or 0, 0.5)

-- Variable
local shiverStr = 0

-- Gets the origin rotation of a part, clamped
local function getOriginRot(part, delta)
	return (vanilla_model[part]:getOriginRot(delta) + 180) % 360 - 180
end

-- Parrot pivots
local parrots = {
	
	parts.group.LeftParrotPivot,
	parts.group.RightParrotPivot
	
}

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

-- Set staticYaw to Yaw on init
local _yaw = 0
function events.ENTITY_INIT()
	
	_yaw = player:getBodyYaw()
	
end

-- Wings bounce
local lWing = lerp.new(vec(0, 0, 0), 0.4, 0.35, 2)
local rWing = lerp.new(vec(0, 0, 0), 0.4, 0.35, 2)
local _pose = "STANDING"
local _onGround = true

function events.TICK()
	
	-- Variables
	local vel = player:getVelocity()
	local yaw = player:getBodyYaw()
	local dir = vec(math.sin(math.rad(-yaw)), 0, math.cos(math.rad(-yaw)))
	local onGround = ground()
	
	-- Directional velocity
	local fbVel = vel:dot((dir.x_z):normalized())
	local lrVel = vel:crossed(dir.x_z:normalized()).y
	local udVel = vel.y
	
	-- Speed control
	local walkSpeed   = math.clamp((pose.climb and udVel or fbVel) * 6.5, -2, 2)
	local flightSpeed = math.min(vel:length(), 2)
	
	-- Animation speeds
	anims.walk:speed(walkSpeed)
	anims.airFlying:speed(flightSpeed)
	
	-- Animation states
	local groundIdle = pose.crawl or not (effects.cF or pose.elytra or pose.swim or pose.sleep)
	local walk       = (pose.climb and vel:length() ~= 0 or vel.xz:length() ~= 0) and not (effects.cF or pose.elytra or pose.sleep or player:getVehicle())
	local airIdle    = effects.cF
	local airFlying  = (pose.elytra or pose.swim) and not pose.crawl
	local sleep      = pose.sleep
	local shiver     = parts.group.Fire and parts.group.Fire:getScale():lengthSquared() / 3 == 0
	
	-- Increase shiver strength
	shiverStr = math.clamp(shiverStr + (shiver and 1 or -1), 0, 200)
	
	-- Animation blend
	anims.shiver:blend(shiverStr / 200)
	
	-- Animations
	anims.groundIdle:playing(groundIdle)
	anims.walk:playing(walk)
	anims.airIdle:playing(airIdle)
	anims.airFlying:playing(airFlying)
	anims.sleep:playing(sleep)
	anims.shiver:playing(shiverStr ~= 0)
	
	-- Arm variables
	local handedness = player:isLeftHanded()
	local mainL = not handedness and "OFF_HAND" or "MAIN_HAND"
	local mainR = handedness and "OFF_HAND" or "MAIN_HAND"
	local swingL = player:getSwingArm() == mainL
	local swingR = player:getSwingArm() == mainR
	local using = player:isUsingItem()
	local active = player:getActiveHand()
	local itemL = player:getHeldItem(not handedness)
	local itemR = player:getHeldItem(handedness)
	local usingL = using and active == mainL and itemL:getUseAction()
	local usingR = using and active == mainR and itemR:getUseAction()
	local bow = (usingL or usingR or ""):find("BOW") or (itemL:getTag().Charged or itemR:getTag().Charged) == 1
	
	-- Arms movement override
	local armShouldMove = pose.swim or pose.crawl
	
	-- Arms movement targets
	leftArmLerp.target  = (armsMove.curr or armShouldMove or swingL or usingL or bow) and 0 or -1
	rightArmLerp.target = (armsMove.curr or armShouldMove or swingR or usingR or bow) and 0 or -1
	
	-- Set targets
	if pose.elytra or pose.swim or pose.crawl or effects.cF then
		lWing.target.yz = vec(0, 0)
		rWing.target.yz = vec(0, 0)
	elseif onGround and not _onGround then
		lWing.target.z = -lWing.target.z
		rWing.target.z = -rWing.target.z 
	else
		lWing.target.yz = vec(math.clamp(fbVel, -0.4, 0.4) * 100, math.clamp(udVel, -0.4, 0.4) * 50)
		rWing.target.yz = vec(math.clamp(-fbVel, -0.4, 0.4) * 100, math.clamp(-udVel, -0.4, 0.4) * 50)
	end
	
	-- Body velocity
	local yawOffset = math.clamp((_yaw - yaw) / 3, -7.5, 7.5)
	lWing.vel.y = lWing.vel.y - yawOffset
	rWing.vel.y = rWing.vel.y - yawOffset
	
	-- Crouch boost
	if pose.crouch and _pose == "STANDING" then
		lWing.vel.z = lWing.vel.z - 10
		rWing.vel.z = rWing.vel.z + 10
	elseif pose.stand and _pose == "CROUCHING" then
		lWing.vel.z = lWing.vel.z + 10
		rWing.vel.z = rWing.vel.z - 10
	end
	
	-- Store data
	_yaw = yaw
	_onGround = onGround
	_pose = player:getPose()
	
end

-- Sleep rotations
local dirRot = {
	north = 0,
	east  = 270,
	south = 180,
	west  = 90
}

function events.RENDER(delta, context)
	
	-- Sleep rotations
	if pose.sleep then
		
		-- Disable vanilla rotation
		renderer:rootRotationAllowed(false)
		
		-- Find block
		local block = world.getBlockState(player:getPos())
		local sleepRot = dirRot[block.properties["facing"]]
		
		-- Apply
		models:rot(0, sleepRot, 0)
		
	else
		
		-- Enable vanilla rotation
		renderer:rootRotationAllowed(true)
		
		-- Reset
		models:rot(0)
		
	end
	
	-- Arm idle rotation
	local idleTimer = world.getTime(delta)
	local idleRot   = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	
	-- Apply arm rotations
	parts.group.LeftArm:offsetRot((getOriginRot("LEFT_ARM", delta) + idleRot) * leftArmLerp.currPos)
	parts.group.RightArm:offsetRot((getOriginRot("RIGHT_ARM", delta) - idleRot) * rightArmLerp.currPos)
	
	-- Apply wing bounce
	parts.group.LeftWing1:offsetRot(lWing.currPos)
	parts.group.RightWing1:offsetRot(rWing.currPos)
	
	-- Parrot rot offset
	for _, parrot in pairs(parrots) do
		parrot:rot(-calculateParentRot(parrot:getParent()) - getOriginRot("BODY", delta))
	end
	
	-- Crouch offset
	local bodyRot = getOriginRot("BODY", delta)
	local crouchPos = vec(0, -math.sin(math.rad(bodyRot.x)) * 2, -math.sin(math.rad(bodyRot.x)) * 12)
	parts.group.UpperBody:offsetPivot(crouchPos):pos(crouchPos.xy_ * 2)
	parts.group.LowerBody:pos(crouchPos)
	
	-- Spyglass rotations
	local headRot = getOriginRot("HEAD", delta)
	headRot.x = math.clamp(headRot.x, -90, 30)
	parts.group.Spyglass:offsetRot(headRot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.groundIdle, ticks = {7,7} },
	{ anim = anims.walk,       ticks = {7,7} },
	{ anim = anims.airIdle,    ticks = {7,7} },
	{ anim = anims.airFlying,  ticks = {7,7} }
}

-- Apply GS Blending
for _, blend in ipairs(blendAnims) do
	if blend.anim ~= nil then
		blend.anim:blendTime(table.unpack(blend.ticks)):blendCurve("easeOutQuad")
	end
end

-- Host only instructions
if not host:isHost() then return end

-- Required script
local s, pageNav, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found

-- Check for if page already exists
local pageExists = action_wheel:getPage("Anims")

-- Pages
local parentPage = action_wheel:getPage("Main")
local animsPage  = pageExists or action_wheel:newPage("Anims")

-- Actions table setup
local a = {}

-- Actions
if not pageExists then
	a.pageAct = parentPage:newAction()
		:item("jukebox")
		:onLeftClick(function() pageNav.descend(animsPage) end)
end

a.armsAct = animsPage:newAction()
	:item("red_dye")
	:toggleItem("rabbit_foot")
	:onToggle(function(bool)
		armsMove:update(bool)
	end)
	:toggled(armsMove.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Animation Settings", bold = true, color = c.primary}
				))
		end
		
		a.armsAct
			:title(toJson(
				{
					"",
					{text = "Arm Movement Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the movement swing movement of the arms.\nActions are not effected.", color = c.secondary}
				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end