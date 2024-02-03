-- Required scripts
require("lib.GSAnimBlend")
local parts      = require("scripts.ModelParts")
local waterTicks = require("scripts.WaterTicks")
local pose       = require("scripts.Posing")
local ground     = require("lib.GroundCheck")

-- Animations setup
local anims = animations.CharizardTaur

-- Animation variables
local breatheTime = {
	prev = 0,
	time = 0,
	next = 0
}

function events.TICK()
	
	-- Player variables
	local vel = player:getVelocity()
	
	-- Animation variables
	local walking    = vel.xz:length() ~= 0
	local inWater    = waterTicks.water < 20
	local underwater = waterTicks.under < 20
	local onGround   = ground()
	
	-- Store animation variables
	breatheTime.prev = breatheTime.next
	
	-- Animation control
	breatheTime.next = breatheTime.next + math.clamp((vel:length() * 15 + 1) * 0.05, 0, 0.4)
	
	-- Animation states
	local groundIdle = (inWater or onGround) and not pose.swim and not pose.sleep
	local groundWalk = walking and onGround and not pose.elytra and not pose.sleep
	local airIdle    = not (pose.elytra or inWater) and not onGround
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