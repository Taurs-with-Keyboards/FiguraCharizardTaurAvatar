-- Models setup
local pokeball = models.Pokeball
local model    = models.CharizardTaur

-- Animation setup
local anims = animations.Pokeball

-- Table setup
local t = {}

-- Config setup
config:name("CharizardTaur")
local toggle = config:load("PokeballToggle") or false

-- Variables
local isInBall  = toggle
local wasInBall = toggle
local staticRot = 0
t.scale         = 0
local vehicle   = require("scripts.Vehicles")

-- Lerping variables
local startScale = toggle and 0 or 1
local scaleCurrent, scaleNextTick, scaleTarget, scaleCurrentPos = startScale, startScale, startScale, startScale
local posCurrent,   posNextTick,   posTarget,   posCurrentPos   = 0, 0, 0, 0
function events.TICK()
	-- Pokeball check
	isInBall = ((toggle and not vehicle.isVehicle) or (vehicle.vehicle and not(vehicle.boat or vehicle.chest_boat) or (vehicle.isPassenger or vehicle.player))) or false
	
	-- Compare states
	if isInBall ~= wasInBall then
		-- Pokeball sounds
		if isInBall     then sounds:stopSound() sounds:playSound("cobblemon:poke_ball.recall",   player:getPos(), 0.15) end
		if not isInBall then sounds:stopSound() sounds:playSound("cobblemon:poke_ball.send_out", player:getPos(), 0.15) end
		
		if isInBall then 
			staticRot = -player:getRot().y
		end
		
		-- Animations
		anims.open:playing(not isInBall)
		anims.close:playing(isInBall)
	end
	
	-- Pos lerp
	posCurrent  = posNextTick
	posNextTick = math.lerp(posNextTick, posTarget, 0.25)
	
	-- Scaling lerp
	scaleCurrent  = scaleNextTick
	scaleNextTick = math.lerp(scaleNextTick, scaleTarget, 0.2)
	
	-- Store previous states
	wasInBall = isInBall
end

-- Rendering stuff
function events.RENDER(delta, context)
	if context == "FIRST_PERSON" or context == "RENDER" or (not client.isHudEnabled() and context ~= "MINECRAFT_GUI") then
		-- Vehicle pos table
		local statePos = {
			{ state = vehicle.player,        pos = 10  },
			{ state = (vehicle.boat or vehicle.chest_boat) and
				vehicle.isPassenger,         pos = 14  },
			{ state = vehicle.boat,          pos = 8   },
			{ state = vehicle.chest_boat,    pos = 0   },
			{ state = vehicle.minecart,      pos = 9   },
			{ state = vehicle.horse,         pos = 10  },
			{ state = vehicle.donkey,        pos = 10  },
			{ state = vehicle.mule,          pos = 10  },
			{ state = vehicle.zombieHorse,   pos = 8   },
			{ state = vehicle.skeletonHorse, pos = 11  },
			{ state = vehicle.pig,           pos = 10  },
			{ state = vehicle.strider,       pos = 10  },
			{ state = vehicle.camel,         pos = 9   },
		}
		
		-- Base position check
		for _, case in ipairs(statePos) do
			if case.state then
				posTarget = case.pos
				break
			elseif vehicle.vehicle then
				-- Unsupported cases
				posTarget = 10 -- Assumption
			else
				posTarget = 0
			end
		end
		
		-- Pos lerp
		posCurrentPos = math.lerp(posCurrent, posNextTick, delta)
		
		-- Scaling target and lerp
		scaleTarget     = isInBall and 0 or 1
		scaleCurrentPos = math.lerp(scaleCurrent, scaleNextTick, delta)
		
		-- Apply scale, color, & pos
		-- Lapras
		model:scale(scaleCurrentPos)
			:color(1, scaleCurrentPos, scaleCurrentPos)
			:pos(vec(0, posCurrentPos, 0))
		
		-- Pokeball
		pokeball:visible(context ~= "FIRST_PERSON")
			:scale(math.map(scaleCurrentPos, 0, 1, 1, 0) * (vehicle.player and 0.5 or 1))
			:pos(vec(0, posCurrentPos, 0))
			:rot(vehicle.player and 0 or vec(0, staticRot + player:getBodyYaw(delta), 0))
		
		-- Shadow
		renderer:shadowRadius(math.map(scaleCurrentPos, 0, 1, 0.2, 1.25))
		
		t.scale = scaleCurrentPos
	end
end

-- Keybind animations/blockers
local function forwardWobble()
	anims.wobbleForward:play()
end

local function backWobble()
	anims.wobbleBack:play()
end

local function rightWobble()
	anims.wobbleRight:play()
end

local function leftWobble()
	anims.wobbleLeft:play()
end

-- Keybind ping setup
pings.playForwardWobble = forwardWobble
pings.playBackWobble    = backWobble
pings.playRightWobble   = rightWobble
pings.playLeftWobble    = leftWobble

if host:isHost() then
	local cantMove  = (toggle or vehicle.isPassenger or vehicle.player)
	local kbForward = keybinds:newKeybind("Pokeball Forward Blocker"):onPress(function() if cantMove and not anims.wobbleForward:isPlaying() then pings.playForwardWobble() end return cantMove end)
	local kbBack    = keybinds:newKeybind("Pokeball Back Blocker"   ):onPress(function() if cantMove and not anims.wobbleBack:isPlaying() then pings.playBackWobble() end return cantMove end)
	local kbRight   = keybinds:newKeybind("Pokeball Right Blocker"  ):onPress(function() if cantMove and not anims.wobbleRight:isPlaying() then pings.playRightWobble() end return cantMove end)
	local kbLeft    = keybinds:newKeybind("Pokeball Left Blocker"   ):onPress(function() if cantMove and not anims.wobbleLeft:isPlaying() then pings.playLeftWobble() end return cantMove end)
	local kbJump    = keybinds:newKeybind("Pokeball Jump Blocker"   ):onPress(function() return cantMove and player:isInWater() end)
	local kbCrouch  = keybinds:newKeybind("Pokeball Crouch Blocker" ):onPress(function() return toggle end)
	local kbAttack  = keybinds:newKeybind("Pokeball Attack Blocker" ):onPress(function() return cantMove end)
	local kbUse     = keybinds:newKeybind("Pokeball Use Blocker"    ):onPress(function() return cantMove end)

	-- Keybind maintainer (Prevents changes)
	function events.TICK()
		cantMove = (toggle or vehicle.isPassenger or vehicle.player)
		kbForward:key(keybinds:getVanillaKey("key.forward"))
		kbBack:key(keybinds:getVanillaKey("key.back"))
		kbRight:key(keybinds:getVanillaKey("key.right"))
		kbLeft:key(keybinds:getVanillaKey("key.left"))
		kbJump:key(keybinds:getVanillaKey("key.jump"))
		kbCrouch:key(keybinds:getVanillaKey("key.sneak"))
		kbAttack:key(keybinds:getVanillaKey("key.attack"))
		kbUse:key(keybinds:getVanillaKey("key.use"))
	end
end

-- Pokeball toggler
local function setPokeball(boolean)
	toggle = boolean
	config:save("PokeballToggle", toggle)
end

-- Sync variable
local function syncPokeball(a)
	toggle = a
end

-- Ping setup
pings.setPokeball  = setPokeball
pings.syncPokeball = syncPokeball

-- Sync on tick
if host:isHost() then
	function events.TICK()
		if world.getTime() % 200 == 0 then
			pings.syncPokeball(toggle)
		end
	end
end

-- Activate action
setPokeball(toggle)

-- Return action wheel page
t.togglePage = action_wheel:newAction("Pokeball")
	:title("§6§lToggle Pokeball\n\n§3Auto activates/deactivates on vehicles.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:texture(textures["textures.misc.pokeballIcon"])
	:onToggle(pings.setPokeball)
	:toggled(toggle)

-- Return action wheel page (and toggle)
return t