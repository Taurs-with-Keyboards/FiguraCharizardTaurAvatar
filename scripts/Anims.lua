-- Required scripts
require("lib.GSAnimBlend")
local pokemonParts = require("lib.GroupIndex")(models.models.CharizardTaur)
local ground       = require("lib.GroundCheck")
local average      = require("lib.Average")
local pose         = require("scripts.Posing")

-- Animations setup
local anims = animations["models.CharizardTaur"]

-- Variables setup
local airTimer    = 0
local shiverTimer = 0

-- Parrot pivots
local parrots = {
	
	pokemonParts.LeftParrotPivot,
	pokemonParts.RightParrotPivot
	
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
	
	-- Player variables
	local vel      = player:getVelocity()
	local onGround = ground()
	
	-- Ground timer
	airTimer = not (onGround or player:isInWater()) and airTimer + 1 or 0
	
	-- Animation variables
	local walking = pose.climb and vel:length() ~= 0 or vel.xz:length() ~= 0
	local inAir   = airTimer > 15
	
	-- Animation states
	local groundIdle = ((not inAir or pose.climb) or player:getVehicle()) and not pose.swim and not pose.sleep 
	local groundWalk = walking and (not inAir or pose.climb) and not pose.elytra and not pose.sleep
	local airIdle    = inAir and not player:getVehicle() and not pose.elytra and not pose.climb
	local airFlying  = (pose.elytra or pose.swim) and not onGround
	local sleep      = pose.sleep
	local breathe    = true
	local shiver     = average(pokemonParts.Fire:getScale():unpack()) == 0
	
	if shiver and shiverTimer < 200 then
		shiverTimer = shiverTimer + 1
	elseif not shiver and shiverTimer > 0 then
		shiverTimer = shiverTimer - 1
	end
	
	-- Animations
	anims.groundIdle:playing(groundIdle)
	anims.groundWalk:playing(groundWalk)
	anims.airIdle:playing(airIdle)
	anims.airFlying:playing(airFlying)
	anims.sleep:playing(sleep)
	anims.breathe:playing(breathe)
	anims.shiver:playing(shiverTimer > 0)
	
end

-- Sleep rotations
local dirRot = {
	north = 0,
	east  = 270,
	south = 180,
	west  = 90
}

function events.RENDER(delta, context)
	
	-- Player variables
	local vel = player:getVelocity()
	local dir = player:getLookDir()
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	local udVel = player:getVelocity().y
	
	-- Animation speeds
	anims.groundWalk:speed(pose.climb and udVel * 6.5 or math.clamp((fbVel < -0.05 and math.min(fbVel, math.abs(lrVel)) or math.max(fbVel, math.abs(lrVel))) * 6.5, -2, 2))
	anims.airFlying:speed(math.clamp(vel:length(), 0, 2))
	anims.breathe:speed(math.min(vel:length() * 15 + 1, 8))
	
	-- Animation blend
	anims.shiver:blend(math.map(shiverTimer, 0, 200, 0, 1))
	
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
		parrot:rot(-calculateParentRot(parrot:getParent()))
	end
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.groundIdle, ticks = {7,7} },
	{ anim = anims.groundWalk, ticks = {7,7} },
	{ anim = anims.airIdle,    ticks = {7,7} },
	{ anim = anims.airFlying,  ticks = {7,7} }
}
	
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(table.unpack(blend.ticks)):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	pokemonParts.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end