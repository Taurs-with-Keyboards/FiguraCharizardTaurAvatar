-- Kills script if squAPI or squAssets cannot be found
local s, squapi = pcall(require, "lib.SquAPI")
if not s then return {} end

-- Required script
local parts = require("lib.PartsAPI")

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

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

-- Squishy animated texture
local fire = squapi.animateTexture(
	parts.group.Fire,
	4,    -- Frames
	0.25, -- Frame percentage
	2     -- Speed
)

function events.RENDER(delta, context)
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `parts.group.body`
	for _, group in ipairs(parts.group.UpperBody:getChildren()) do
		if group ~= parts.group.Body then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
end