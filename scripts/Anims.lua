-- Required scripts
require("lib.GSAnimBlend")
local model      = require("scripts.ModelParts")
local waterTicks = require("scripts.WaterTicks")
local pose       = require("scripts.Posing")
local ground     = require("lib.GroundCheck")

-- Animations setup
local anims = animations.CharizardTaur

function events.TICK()
	
	-- Player variables
	local vel = player:getVelocity()
	
	-- Animation variables
	local walking    = vel.xz:length() ~= 0
	local inWater    = waterTicks.water < 20
	local underwater = waterTicks.under < 20
	local onGround   = ground()
	
	-- Animation states
	local groundIdle =             (onGround or inWater) and not pose.swim and not pose.sleep
	local groundWalk = walking and (onGround or inWater) and not pose.swim and not pose.sleep
	local airIdle    = not (pose.elytra or inWater) and not onGround
	local airFlying  =     (pose.elytra or pose.swim) and not onGround
	local sleep      =      pose.sleep
	
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
	
	anims.groundWalk:speed(math.clamp((fbVel < -0.1 and math.min(fbVel, math.abs(lrVel)) or math.max(fbVel, math.abs(lrVel))) * 6.5, -2, 2))
	anims.airFlying:speed(math.min(vel:length(), 2))
	
	if context == "FIGURA_GUI" or context == "MINECRAFT_GUI" or context == "PAPERDOLL" then
		models:scale(0.6)
	end
	
end

function events.POST_RENDER(delta, context)
	
	models:scale(1)
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.groundIdle, ticks = 7  },
	{ anim = anims.groundWalk, ticks = 7  },
	{ anim = anims.airIdle,    ticks = 7  },
	{ anim = anims.airFlying,  ticks = 7  }
}
	
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(blend.ticks):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	model.upper.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end