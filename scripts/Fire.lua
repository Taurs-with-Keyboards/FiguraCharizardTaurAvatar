-- Required scripts
local parts = require("lib.PartsAPI")
local sync  = require("lib.LetThatSyncFig")
local lerp  = require("lib.LerpAPI")

-- Fire group
local fireGroup = parts.group.Fire

-- Kill script early if fire cannot be found
if not fireGroup then return {} end

-- Synced variables setup
local effects     = sync.add(config:load("FireEffects"), true)
local experience  = sync.add(config:load("FireExperience"), true)
local reignite    = sync.add(config:load("FireReignite"), true)
local maxTimer    = sync.add(config:load("FireTimer"), 200)
local damage      = sync.add(config:load("FireDamage"), true)
local damageColor = sync.add(config:load("FireDamageColor"), vectors.hexToRGB("00FFFF"))

-- Variables
local timer = sync[maxTimer]
local selectedRGB = 0
local tex = textures["textures.misc.flame"] or textures["CharizardTaur.flame"]
local grayMat = matrices.mat4(
	vec(0.25, 0.25, 0.25, 0),
	vec(0.25, 0.25, 0.25, 0),
	vec(0.25, 0.25, 0.25, 0),
	vec(0, 0, 0, 1)
)

-- Lerps
local scale = lerp:new(1, 0.05, 0.15)
local color = lerp:new()

-- Set fire parent type
fireGroup.Fire
	:parentType("CAMERA")
	:secondaryTexture("CUSTOM", tex)

-- Fire triggers
local triggers = {
	on = {
		fire = false,
		lava = false,
		lit  = false
	},
	off = {
		water  = false,
		rain   = false,
		splash = false
	}
}

-- Blocks that count as fire
local fireBlocks = {
	["minecraft:fire"]       = true,
	["minecraft:soul_fire"]  = true,
	["minecraft:torch"]      = true,
	["minecraft:soul_torch"] = true
}

-- Check if a splash potion is broken near the fire
function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, category, path)
	
	-- Kill event if player is in pokeball
	if parts.group.Player:getAnimScale():lengthSquared() / 3 < 0.5 then return end
	
	if player:isLoaded() then
		local firePos  = fireGroup:partToWorldMatrix():apply()
		local atPos    = pos < firePos + 2 and pos > firePos - 2
		local splashID = id == "minecraft:entity.splash_potion.break" or id == "minecraft:entity.lingering_potion.break"
		triggers.off.splash = atPos and splashID and path
	end
	
end

-- Attempts to play an effect based on a given chance
local function doChance(chance)
	
	return math.random() < chance * scale.currPos
	
end

-- Find angle with variation
local function smokeAngle()
	
	return vec(
		math.random() * 0.025 - 0.0125,
		math.random() * 0.05 + 0.025,
		math.random() * 0.025 - 0.0125
	)
	
end

function events.TICK()
	
	-- Kill event if player is in pokeball
	if parts.group.Player:getAnimScale():lengthSquared() / 3 < 0.5 then return end
	
	-- Variables
	local firePos = fireGroup:partToWorldMatrix():apply()
	local block   = world.getBlockState(firePos)
	local extinguish = false
	
	-- Increment timer
	timer = sync[reignite] and math.min(timer + 1, sync[maxTimer]) or timer
	
	-- Check for water fluid tag
	for _, v in ipairs(block:getFluidTags()) do
		if v:find("water") then
			triggers.off.water = true
			break
		end
	end
	
	-- Check for rain
	triggers.off.rain = world.getRainGradient() > 0.2 and world.isOpenSky(firePos) and world.getBiome(firePos):getPrecipitation() == "RAIN"
	
	-- Check off triggers
	for k, v in pairs(triggers.off) do
		if v then
			extinguish = true
			triggers.off[k] = false
			break
		end
	end
	
	-- Extinguishes flame and plays sound when conditions met
	if extinguish then
		
		-- Reset timer
		timer = 0
		
		-- Prevent event from continuing if already extinguished
		if scale.target == 0 then return end
		
		-- Sounds and particles
		if sync[effects] then
			
			-- Play sound
			sounds:playSound("entity.generic.extinguish_fire", firePos, 0.75)
			
			-- Spawn particles
			for i = 1, math.ceil(math.map(scale.currPos, 0, 2, 0, 30)) do
				
				-- Particle attributes
				particles["campfire_cosy_smoke"]
					:pos(firePos)
					:velocity(smokeAngle())
					:physics(true)
					:spawn()
				
			end
			
		end
		
		-- Reset scale
		scale:reset(0)
		
	end
	
	-- Check for lava fluid tag
	for _, v in ipairs(block:getFluidTags()) do
		if v:find("lava") then
			triggers.on.lava = true
			break
		end
	end
	
	-- Check for fire blocks
	if fireBlocks[block.id] then
		triggers.on.fire = true
	end
	
	-- Check block lit tag
	triggers.on.lit = block.properties.lit == "true"
	
	-- Check on triggers
	for k, v in pairs(triggers.on) do
		if v then
			timer = sync[maxTimer]
			triggers.on[k] = false
			break
		end
	end
	
	-- Kill script if timer hasnt reached max
	if timer ~= sync[maxTimer] then return end
	
	-- Spawn particles and play sounds if conditions are met
	if sync[effects] then
		
		-- Chance
		local weight = math.map(scale.currPos, 0, 2, 4000, 0)
		local chance = math.random(1, math.max(weight, 1))
		
		-- Campfire sound (0.25%) 
		if doChance(0.0025) then
			sounds:playSound("block.campfire.crackle", firePos, 0.75)
		end
		
		-- Lava bubble (0.5%)
		if doChance(0.005) then
			particles["lava"]
				:pos(firePos)
				:spawn()
		end
		
		-- Smoke chance (5%)
		if doChance(0.05) then
			particles["campfire_cosy_smoke"]
				:pos(firePos)
				:velocity(smokeAngle())
				:spawn()
		end
		
	end
	
	-- Init apply
	scale.target = 1
	color.target = 0
	
	-- Apply experience modifier
	if sync[experience] then
		
		local exp = math.map(math.clamp(player:getExperienceLevel(), 0, 30), 0, 30, 0.25, 2)
		scale.target = scale.target * exp
		
	end
	
	-- Apply damage color
	if sync[damage] then
		
		color.target = math.map(math.clamp(player:getHealth() / player:getMaxHealth(), 0.25, 1), 0.25, 1, 1, 0)
		
	end
	
	-- Bounce flame back if below 0
	if scale.currTick < 0 then
		scale:bounce(0)
	end
	
end

function events.RENDER(delta, context)
	
	-- Kill event if player is in pokeball
	if parts.group.Player:getAnimScale():lengthSquared() / 3 < 0.5 then return end
	
	-- Change fire color
	local mat = math.lerp(matrices.mat4(), grayMat, color.currPos)
	local col = math.lerp(vec(1, 1, 1), sync[damageColor], color.currPos)
	local dim = tex:getDimensions()
	tex:restore():applyMatrix(0, 0, dim.x, dim.y, mat:scale(col), true):update()
	
	-- Adjust fire attributes
	fireGroup
		:scale(scale.currPos)
		:secondaryRenderType(context == "RENDER" and "EMISSIVE" or "EYES")
	
end

-- Effects toggle
function pings.setFireEffects(boolean)
	
	sync[effects] = boolean
	config:save("FireEffects", sync[effects])
	if host:isHost() and player:isLoaded() and sync[effects] then
		sounds:playSound("item.firecharge.use", player:getPos(), 0.75)
	end
	
end

-- Experience toggle
function pings.setFireExperience(boolean)
	
	sync[experience] = boolean
	config:save("FireExperience", sync[experience])
	if host:isHost() and player:isLoaded() and sync[experience] then
		sounds:playSound("entity.experience_orb.pickup", player:getPos(), 0.75, math.random()*0.7+0.55)
	end
	
end

-- Reignite toggle
function pings.setFireReignite(boolean)
	
	sync[reignite] = boolean
	config:save("FireReignite", sync[reignite])
	if host:isHost() and player:isLoaded() then
		sounds:playSound(sync[reignite] and "item.flintandsteel.use" or "entity.generic.extinguish_fire", player:getPos(), 0.75)
	end
	
end

-- Set timer
local function setTimer(x)
	
	sync[maxTimer] = math.clamp(sync[maxTimer] + (x * 20), 0, 72000)
	config:save("FireTimer", sync[maxTimer])
	
end

-- Set color
local function setColor(x)
	
	x = x/255
	sync[damageColor][selectedRGB+1] = math.clamp(sync[damageColor][selectedRGB+1] + x, 0, 1)
	
	config:save("FireDamageColor", sync[damageColor]) 
	
end

-- Swaps selected rgb value
local function selectRGB()
	
	selectedRGB = (selectedRGB + 1) % 3
	
end

-- Damage toggle
function pings.setFireDamage(boolean)
	
	sync[damage] = boolean
	config:save("FireDamage", sync[damage])
	if host:isHost() and player:isLoaded() then
		sounds:playSound(sync[damage] and "entity.player.attack.sweep" or "item.shield.block", player:getPos(), 0.75)
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required script
local s, wheel, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Shiny") -- Tries to find script, not required

-- Pages
local parentPage = action_wheel:getPage("Charizard") or action_wheel:getPage("Main")
local firePage   = action_wheel:newPage("Fire")

-- Actions table setup
local a = {}

-- Actions
a.pageAct = parentPage:newAction()
	:item("campfire")
	:onLeftClick(function() wheel:descend(firePage) end)

a.effectsAct = firePage:newAction()
	:item("white_wool")
	:toggleItem("note_block")
	:onToggle(pings.setFireEffects)
	:toggled(sync[effects])

a.experienceAct = firePage:newAction()
	:item("glass_bottle")
	:toggleItem("experience_bottle")
	:onToggle(pings.setFireExperience)
	:toggled(sync[experience])

a.reigniteAct = firePage:newAction()
	:item("flint")
	:toggleItem("flint_and_steel")
	:onToggle(pings.setFireReignite)
	:onRightClick(function() sync[maxTimer] = 200 config:save("FireTimer", sync[maxTimer]) end)
	:onScroll(setTimer)
	:toggled(sync[reignite])

a.colorAct = firePage:newAction()
	:item("shield")
	:toggleItem("iron_sword")
	:onToggle(pings.setFireDamage)
	:onRightClick(selectRGB)
	:onScroll(function(x) setColor(x) end)
	:toggled(sync[damage])

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		a.pageAct
			:title(toJson(
				{text = "Tail Fire Settings", bold = true, color = c.primary}
			))
		
		a.effectsAct
			:title(toJson(
				{
					"",
					{text = "Toggle Fire Effects\n\n", bold = true, color = c.primary},
					{text = "Toggles the fire's ability to create particles and sounds.", color = c.secondary}
				}
			))
		
		a.experienceAct
			:title(toJson(
				{
					"",
					{text = "Toggle Fire Experience Guage\n\n", bold = true, color = c.primary},
					{text = "Allow the tail fire to change size based on experience level.", color = c.secondary}
				}
			))
		
		a.reigniteAct
			:title(toJson(
				{
					"",
					{text = "Set Fire Reignition & Timer\n\n", bold = true, color = c.primary},
					{text = "Control the ability for your tail fire to auto-reignite, as well as how long until it does so.\n\n", color = c.secondary},
					{text = "Current timer: ", bold = true, color = c.secondary},
					{text = (sync[reignite] and (sync[maxTimer] / 20).." Seconds" or "Cannot auto-reignite").."\n\n", color = not sync[reignite] and "red"},
					{text = "Scroll to adjust the timer.\nRight click resets timer to 10 seconds.", color = c.secondary}
				}
			))
		
		a.colorAct
			:title(toJson(
				{
					"",
					{text = "Toggle Fire Damage Indicator/Set Fire Color\n\n", bold = true, color = c.primary},
					{text = "Allow the tail fire to indicate overall health.\nAdditionally, sets the color of the fire while damaged.\nLeft click to toggle damage coloring.\nScroll to adjust an RGB Value.\nRight click to change color channel.\n\n", color = c.secondary},
					{text = "Selected RGB: ", bold = true, color = c.secondary},
					{text = (selectedRGB == 0 and "[%d] "  or "%d " ):format(sync[damageColor][1] * 255), color = "red"},
					{text = (selectedRGB == 1 and "[%d] "  or "%d " ):format(sync[damageColor][2] * 255), color = "green"},
					{text = (selectedRGB == 2 and "[%d]\n" or "%d\n"):format(sync[damageColor][3] * 255), color = "blue"},
					{text = "Selected Hex: ", bold = true, color = c.secondary},
					{text = vectors.rgbToHex(sync[damageColor]), color = "#"..vectors.rgbToHex(sync[damageColor])},

				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end