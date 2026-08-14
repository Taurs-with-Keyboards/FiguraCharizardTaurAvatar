-- Required script
local parts = require("lib.PartsAPI")

-- Parts setup
local charizard = parts.new(models.CharizardTaur)

-- Variable setup
local nameGroup = charizard.outliner.Nameplate
local namePivot = charizard.outliner.NameplatePivot
if not nameGroup then return end

-- Head midRender event
function events.ENTITY_INIT()
	function nameGroup.midRender(delta)
		
		-- Variables
		local pos = player:getPos(delta)
		local groupPos = nameGroup:partToWorldMatrix():apply()
		local offset = (groupPos - pos) - (vanilla_model.HEAD:getOriginPos() / 32) + vec(0, (1 - charizard.outliner.Player:getAnimScale():lengthSquared() / 3) * 0.75, 0)
		
		-- Apply
		nameplate.ENTITY:pivot(offset)
		
		-- Kill function early if the namePivot isnt found
		if not namePivot then return end
		
		-- Get pose
		local pose = player:getPose()
		
		-- If any pose that rotates, rotate the pivot to match, and slightly raise pivot
		namePivot:offsetRot((pose ~= "STANDING" and pose ~= "CROUCHING") and player:getRot(delta).x__ or nil --[[@as Vector3]])
		nameplate.ENTITY:pivot(nameplate.ENTITY:getPivot() + ((pose ~= "STANDING" and pose ~= "CROUCHING") and vec(0, 0.1, 0) or 0))
		
	end
end