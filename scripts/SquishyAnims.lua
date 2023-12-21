-- Model setup
local model     = models.CharizardTaur
local upperRoot = model.Player.UpperBody
local lowerRoot = model.Player.LowerBody
local anims     = animations.CharizardTaur

-- Squishy API Animations
local squapi = require("lib.SquAPI")

local tailSegments = {
	lowerRoot.Tail1,
	lowerRoot.Tail1.Tail2,
	lowerRoot.Tail1.Tail2.Tail3,
	lowerRoot.Tail1.Tail2.Tail3.Fire
}

squapi.smoothTorso(upperRoot, 0.3, _, false)

squapi.crouch(anims.crouch)
squapi.tails(tailSegments, 3, 10, 20, 0.75, 0.25, 0, 0, 1, .0005, .05, 25, nil, nil)
squapi.animateTexture(lowerRoot.Tail1.Tail2.Tail3.Fire, 4, 0.25, 2, false)

function events.RENDER(delta, context)
	if player:getPose() ~= "SLEEPING" then
		local fireRot = lowerRoot.Tail1.Tail2.Tail3.Fire:getOffsetRot()
		lowerRoot.Tail1.Tail2.Tail3.Fire:offsetRot(vec(-fireRot.x, fireRot.z, -fireRot.y * 2))
	end
end