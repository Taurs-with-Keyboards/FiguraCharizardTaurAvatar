-- Model setup
local model     = models.CharizardTaur
local upperRoot = model.Player.UpperBody

-- Animation setup
local anims = animations.CharizardTaur

local t = {}
t.time = 0

local pose  = require("scripts.Posing")
local ticks = require("scripts.WaterTicks")
local g     = require("scripts.GroundCheck")

local time  = 0
local _time = 0

function events.TICK()
	_time = time
	
	local fbVel     = math.clamp(player:getVelocity():dot((player:getLookDir().x_z):normalize()),         -0.25, 0.25)
	local lrVel     = math.clamp(math.abs(player:getVelocity():cross(player:getLookDir().x_z:normalize()).y), 0, 0.25)
	local animSpeed = (fbVel >= -0.05 and math.max(fbVel, lrVel) or math.min(fbVel, lrVel)) * 0.0025
	
	time  = time + (animSpeed + (fbVel > -0.05 and 0.0005 or -0.0005))
end

function events.RENDER(delta, context)
	local vel        = player:getVelocity()
	local walking    = vel.zx:length() ~= 0
	local inWater    = ticks.water     < 20
	local underwater = ticks.under     < 20
	
	local groundIdle =             (g.ground or inWater) and not pose.swim
	local groundWalk = walking and (g.ground or inWater) and not pose.swim
	local airIdle    = not (pose.elytra or inWater) and not g.ground
	local airFlying  =     (pose.elytra or pose.swim) and not g.ground
	local sleep      =      pose.sleep
	
	anims.groundIdle:setPlaying(groundIdle)
	anims.groundWalk:setPlaying(groundWalk)
	anims.airIdle:setPlaying(airIdle)
	anims.airFlying:setPlaying(airFlying)
	anims.sleep:setPlaying(sleep)
	
	t.time = math.lerp(_time, time, delta)
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	if context == "RENDER" or context == "FIRST_PERSON" or (not client.isHudEnabled() and context ~= "MINECRAFT_GUI") then
		local rot = vanilla_model.HEAD:getOriginRot()
		rot.x = math.clamp(rot.x, -90, 30)
		upperRoot.Spyglass:rot(rot)
			:pos(pose.crouch and vec(0, -4, 0) or nil)
	end
end

-- GS Blending Setup
do
	require("lib.GSAnimBlend")
	
	anims.groundIdle:blendTime(7)
	anims.groundWalk:blendTime(7)
	anims.airIdle:blendTime(7)
	anims.airFlying:blendTime(7)
	
	anims.groundIdle:onBlend("easeOutQuad")
	anims.groundWalk:onBlend("easeOutQuad")
	anims.airIdle:onBlend("easeOutQuad")
	anims.airFlying:onBlend("easeOutQuad")
end

return t