-- Required scripts
local parts  = require("scripts.ModelParts")
local squapi = require("lib.SquAPI")
local pose   = require("scripts.Posing")

-- Animation setup
local anims = animations.CharizardTaur

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

-- Squishy smooth torso
squapi.smoothTorso(parts.UpperBody, 0.3)

-- Squishy crounch
squapi.crouch(anims.crouch)

-- Squishy tail
squapi.tails(parts.tailSegments,
	3,      --intensity
	10,     --tailintensityY
	20,     --tailintensityX
	0.75,   --tailYSpeed
	0.25,   --tailXSpeed
	0,      --tailVelBend
	0,      --initialTailOffset
	1,      --segOffsetMultiplier
	0.0005, --tailStiff
	0.05,   --tailBounce
	25,     --tailFlyOffset
	nil,    --downlimit
	nil     --uplimit
)

-- Squishy animated texture
squapi.animateTexture(parts.Fire, 4, 0.25, 2, false)

function events.RENDER(delta, context)
	
	-- Set upper pivot to proper pos when crouching
	parts.UpperBody:offsetPivot(anims.crouch:isPlaying() and vec(0, 0, 5) or 0)
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `parts.body` and when sleeping
	for _, group in ipairs(parts.UpperBody:getChildren()) do
		if group ~= parts.Body and not pose.sleep then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
	-- Creates flowed movement for fire on tail
	-- Note: Acts strangely when sleeping
	local fireRot = parts.Tail3:getOffsetRot()
	parts.Fire:offsetRot(vec(-fireRot.x, fireRot.z, -fireRot.y * 2))
	
end