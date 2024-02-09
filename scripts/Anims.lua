-- Required scripts
require("lib.GSAnimBlend")
local parts      = require("lib.GroupIndex")(models)
local waterTicks = require("scripts.WaterTicks")
local pose       = require("scripts.Posing")
local ground     = require("lib.GroundCheck")

-- Animations setup
local anims = animations.CharizardTaur

-- Variables setup
local airTimer = 0

-- Parrot pivots
local parrots = {
	
	parts.LeftParrotPivot,
	parts.RightParrotPivot
	
}

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

-- Animation variables
local breatheTime = {
	prev = 0,
	time = 0,
	next = 0
}

function events.TICK()
	
	-- Player variables
	local vel      = player:getVelocity()
	local onGround = ground()
	
	-- Ground timer
	airTimer = not (onGround or player:isInWater()) and airTimer + 1 or 0
	
	-- Animation variables
	local walking    = vel.xz:length() ~= 0
	local inAir      = airTimer > 15
	
	-- Store animation variables
	breatheTime.prev = breatheTime.next
	
	-- Animation control
	breatheTime.next = breatheTime.next + math.clamp((vel:length() * 15 + 1) * 0.05, 0, 0.4)
	
	-- Animation states
	local groundIdle = (not inAir or player:getVehicle()) and not pose.swim and not pose.sleep 
	local groundWalk = walking and not inAir and not pose.elytra and not pose.sleep
	local airIdle    = inAir and not player:getVehicle() and not pose.elytra
	local airFlying  = (pose.elytra or pose.swim) and not onGround
	local sleep      = pose.sleep
	
	-- Animations
	anims.groundIdle:playing(groundIdle)
	anims.groundWalk:playing(groundWalk)
	anims.airIdle:playing(airIdle)
	anims.airFlying:playing(airFlying)
	anims.sleep:playing(sleep)
	
end

function events.RENDER(delta, context)
	
	-- Player variables
	local vel = player:getVelocity()
	local dir = player:getLookDir()
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	local udVel = player:getVelocity().y
	
	-- Animation speeds
	anims.groundWalk:speed(math.clamp((fbVel < -0.1 and math.min(fbVel, math.abs(lrVel)) or math.max(fbVel, math.abs(lrVel))) * 6.5, -2, 2))
	anims.airFlying:speed(math.clamp(vel:length(), 0, 2))
	
	-- Render lerps
	breatheTime.time = math.lerp(breatheTime.prev, breatheTime.next, delta)
	
	-- Apply
	local scale = math.sin(breatheTime.time) * 0.0125 + 1.0125
	local offsetScale = math.map(scale, 1, 1.025, 1, 0.975)
	parts.Torso:scale(scale)
	parts.LowerLeftArm:scale(offsetScale)
	parts.LowerRightArm:scale(offsetScale)
	parts.LeftWing1:scale(offsetScale)
	parts.RightWing1:scale(offsetScale)
	
	-- Parrot rot offset
	for _, parrot in pairs(parrots) do
		parrot:rot(-calculateParentRot(parrot:getParent()))
	end
	
	-- Scales models to fit GUIs better
	if context == "FIGURA_GUI" or context == "MINECRAFT_GUI" or context == "PAPERDOLL" then
		parts.Player:scale(0.6)
		parts.Ball:scale(0.6)
	end
	
end

function events.POST_RENDER(delta, context)
	
	-- After scaling models to fit GUIs, immediately scale back
	parts.Player:scale(1)
	parts.Ball:scale(1)
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.groundIdle, ticks = 7 },
	{ anim = anims.groundWalk, ticks = 7 },
	{ anim = anims.airIdle,    ticks = 7 },
	{ anim = anims.airFlying,  ticks = 7 }
}
	
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(blend.ticks):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	parts.UpperBody.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end