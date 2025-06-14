-- Required scripts
require("lib.GSAnimBlend")
require("lib.Molang")
local parts   = require("lib.PartsAPI")
local ground  = require("lib.GroundCheck")
local pose    = require("scripts.Posing")
local effects = require("scripts.SyncedVariables")

-- Animations setup
local anims = animations.CharizardTaur

-- Variable
local shiverStr = 0

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

function events.TICK()
	
	-- Variables
	local vel      = player:getVelocity()
	local dir      = player:getLookDir()
	local onGround = ground()
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	local udVel = player:getVelocity().y
	
	-- Speed control
	local walkSpeed   = math.clamp((pose.climb and udVel or fbVel < -0.05 and math.min(fbVel, math.abs(lrVel)) or math.max(fbVel, math.abs(lrVel))) * 6.5, -2, 2)
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
	
	-- Parrot rot offset
	for _, parrot in pairs(parrots) do
		parrot:rot(-calculateParentRot(parrot:getParent()) - vanilla_model.BODY:getOriginRot())
	end
	
	-- Crouch offset
	local bodyRot = vanilla_model.BODY:getOriginRot(delta)
	local crouchPos = vec(0, -math.sin(math.rad(bodyRot.x)) * 2, -math.sin(math.rad(bodyRot.x)) * 12)
	parts.group.UpperBody:offsetPivot(crouchPos):pos(crouchPos.xy_ * 2)
	parts.group.LowerBody:pos(crouchPos)
	
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

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	parts.group.Spyglass:offsetRot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end