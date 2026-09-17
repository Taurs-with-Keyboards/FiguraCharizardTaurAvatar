-- Required scripts
local parts = require("lib.PartsAPI")
local sync  = require("lib.LetThatSyncFig")
local lerp  = require("lib.LerpAPI")

-- Fire group
local fireGroup = parts.group.Fire

-- Kill script early if fire cannot be found
if not fireGroup then return {} end

-- Synced variables setup
local effects     = sync.new("FireEffects", true):config()
local experience  = sync.new("FireExp", true):config()
local maxTimer    = sync.new("FireTimer", 200):config()
local damage      = sync.new("FireDamage", true):config()
local damageColor = sync.new("FireDamageColor", "#00FFFF"):config()

-- Variables
local extinguish = false
local timer = maxTimer.curr
local tex = textures["textures.misc.flame"] or textures["CharizardTaur.flame"]
local grayMat = matrices.mat4(
	vec(0.25, 0.25, 0.25, 0),
	vec(0.25, 0.25, 0.25, 0),
	vec(0.25, 0.25, 0.25, 0),
	vec(0, 0, 0, 1)
)

-- Lerps
local scale = lerp.new(1, 0.05, 0.15)
local color = lerp.new()

-- Set fire parent type
fireGroup.Fire
	:parentType("CAMERA")
	:secondaryTexture("CUSTOM", tex)

-- Find angle with variation
---@return Vector3
local function smokeAngle()
	return vec(
		math.random() * 0.025 - 0.0125,
		math.random() * 0.05 + 0.025,
		math.random() * 0.025 - 0.0125
	)
end

-- Blocks that count as fire
---@type table<Minecraft.blockID, boolean>
local fireBlocks = {
	["minecraft:fire"]       = true,
	["minecraft:soul_fire"]  = true,
	["minecraft:torch"]      = true,
	["minecraft:soul_torch"] = true
}

-- Checks for a specific fluid in a blocks tags
---@param block BlockState #
-- The block thats tags are being checked.
---@param fluid string #
-- The fluid type that will be looked for.
local function fluidCheck(block, fluid)
	
	-- Get fluid tags
	local fluids = block:getFluidTags()
	
	-- Loop through tags. If tag contains specified fluid, return true
	for i = 1, #fluids do
		if fluids[i]:find(fluid) then
			return true
		end
	end
	
	-- If fluid not found, return false
	return false
	
end

-- Functions that determine if the fire should be extinguished.
---@type table<integer, fun(block: BlockState): boolean>
local extinguishChecks = {
	function(block)
		local pos = block:getPos()
		return world.isOpenSky(pos) and world.getBiome(pos):getPrecipitation() == "RAIN" and world.getRainGradient() > 0.2
	end,
	-- Checks if the targeted block has a water tag.
	function(block)
		return fluidCheck(block, "water")
	end
}

-- Check if a splash potion is broken near the fire
function events.ON_PLAY_SOUND(id, pos, _, _, _, _, path)
	
	-- Kill event if player is in pokeball
	if parts.group.Player:getAnimScale():lengthSquared() / 3 < 0.5 then return end
	
	if player:isLoaded() then
		local firePos  = fireGroup:partToWorldMatrix():apply()
		local atPos    = pos < firePos + 2 and pos > firePos - 2
		local splashID = id == "minecraft:entity.splash_potion.break" or id == "minecraft:entity.lingering_potion.break"
		extinguish = atPos and splashID and path
	end
	
end

-- Functions that determine if the fire should be ignited.
---@type table<integer, fun(block: BlockState): boolean>
local igniteChecks = {
	-- Checks if the targeted block is considered fire.
	function(block)
		return fireBlocks[block.id]
	end,
	-- Checks if the targeted block has a lit property.
	function(block)
		return block.properties.lit == "true"
	end,
	-- Checks if the targeted block has a lava tag.
	function(block)
		return fluidCheck(block, "lava")
	end
}

function events.TICK()
	
	-- Kill event if player is in pokeball
	if parts.group.Player:getAnimScale():lengthSquared() / 3 < 0.5 then return end
	
	-- Variables
	local firePos = fireGroup:partToWorldMatrix():apply()
	local block   = world.getBlockState(firePos)
	
	-- Increment timer
	if maxTimer.curr >= 0 then
		timer = math.min(timer + 1, maxTimer.curr)
	end
	
	-- Check if fire should be extinguished, and set state if it should
	if not extinguish then
		for i = 1, #extinguishChecks do
			if extinguishChecks[i](block) then
				extinguish = true
				break
			end
		end
	end
	
	-- Extinguishes flame and plays sound when conditions met
	if extinguish then
		
		-- Reset timer
		timer = 0
		
		-- Reset state
		extinguish = false
		
		-- Prevent event from continuing if already extinguished
		if scale.target == 0 then return end
		
		-- Sounds and particles
		if effects.curr then
			
			-- Play sound
			sounds:playSound("entity.generic.extinguish_fire", firePos, 0.75)
			
			-- Spawn particles
			for _ = 1, math.ceil(scale.currPos * 15) do
				
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
		
		-- Kill event early (because fire is put out)
		return
		
	end
	
	-- If timer isn't maxed, check if fire should be reignited, and max out timer if it should.
	if timer ~= maxTimer.curr then
		
		-- Loop through ignition checks
		for i = 1, #igniteChecks do
			if igniteChecks[i](block) then
				timer = maxTimer.curr
				break
			end
		end
		
		-- Kill event early (because fire isn't ignited)
		return
		
	end
	
	-- Spawn particles and play sounds if conditions are met
	if effects.curr and not client:isPaused() then
		
		-- Chance modifier
		local weight = scale.currPos
		
		-- Campfire sound (0.25%)
		if math.random() < 0.0025 * weight then
			sounds:playSound("block.campfire.crackle", firePos, 0.75)
		end
		
		-- Lava bubble (0.5%)
		if math.random() < 0.005 * weight then
			particles["lava"]
				:pos(firePos)
				:spawn()
		end
		
		-- Smoke chance (5%)
		if math.random() < 0.05 * weight then
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
	if experience.curr then
		scale.target = scale.target * math.map(math.clamp(player:getExperienceLevel(), 0, 30), 0, 30, 0.25, 2)
	end
	
	-- Apply damage color
	if damage.curr then
		color.target = math.map(math.clamp(player:getHealth() / player:getMaxHealth(), 0.25, 1), 0.25, 1, 1, 0)
	end
	
	-- Bounce flame back if below 0
	if scale.currTick < 0 then
		scale:bounce(0, 0.85)
	end
	
end

function events.RENDER(_, context)
	
	-- Kill event if player is in pokeball
	if parts.group.Player:getAnimScale():lengthSquared() / 3 < 0.5 then return end
	
	-- Change fire color
	local mat = math.lerp(matrices.mat4(), grayMat, color.currPos)
	local col = math.lerp(vec(1, 1, 1), vectors.hexToRGB(damageColor.curr), color.currPos)
	local dim = tex:getDimensions()
	tex:restore():applyMatrix(0, 0, dim.x, dim.y, mat:scale(col), true):update()
	
	-- Adjust fire attributes
	fireGroup
		:scale(scale.currPos)
		:secondaryRenderType(context == "RENDER" and "EMISSIVE" or "EYES")
	
end

-- Host only instructions
if not host:isHost() then return end

-- Apply sound functions
effects:addFunc(function()
	if player:isLoaded() and effects.curr then
		sounds:playSound("item.firecharge.use", player:getPos(), 0.75)
	end
end)
experience:addFunc(function()
	if player:isLoaded() and experience.curr then
		sounds:playSound("entity.experience_orb.pickup", player:getPos(), 0.75, math.random()*0.7+0.55)
	end
end)
maxTimer:addFunc(function()
	if player:isLoaded() then
		local sound = nil
		if maxTimer.curr >= 0 and maxTimer.prev < 0 then
			sound = "item.flintandsteel.use"
		elseif maxTimer.curr < 0 and maxTimer.prev >= 0 then
			sound = "entity.generic.extinguish_fire"
		end
		if sound then
			sounds:playSound(sound, player:getPos(), 0.75)
		end
	end
end)
damage:addFunc(function()
	if player:isLoaded() then
		sounds:playSound(damage.curr and "entity.player.attack.sweep" or "item.shield.block", player:getPos(), 0.75)
	end
end)

-- Required script
local s, pageNav, acts, colors = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isn't found
pcall(require, "scripts.Shiny") -- Tries to find script, not required

-- Variable
local selectedRGB = 1

-- Pages
local parentPage = action_wheel:getPage("Charizard") or action_wheel:getPage("Main")
local firePage   = action_wheel:newPage("Fire")

-- Set color channel
local function setColorRGB(x)
	selectedRGB = ((selectedRGB + x - 1) % 3) + 1
end

-- Actions
acts.firePage = parentPage:newAction()
	:item("campfire")
	:onLeftClick(function() pageNav.descend(firePage) end)

acts.fireEffectsToggle = firePage:newAction()
	:item("white_wool")
	:toggleItem("note_block")
	:onToggle(function(bool)
		effects:update(bool)
	end)
	:toggled(effects.curr)

acts.fireExpToggle = firePage:newAction()
	:item("glass_bottle")
	:toggleItem("experience_bottle")
	:onToggle(function(bool)
		experience:update(bool)
	end)
	:toggled(experience.curr)

acts.fireReigniteSettings = firePage:newAction()
	:item(maxTimer.curr >= 0 and "flint_and_steel" or "flint")
	:onLeftClick(function() maxTimer:update(200) end)
	:onScroll(function(x)
		maxTimer:update(math.clamp(maxTimer.curr + (x * 20), -20, 72000), 20)
	end)

maxTimer:addFunc(function()
	acts.fireReigniteSettings:item(maxTimer.curr >= 0 and "flint_and_steel" or "flint")
end)

acts.fireColorSettings = firePage:newAction()
	:item("shield")
	:toggleItem("iron_sword")
	:onToggle(function(bool)
		damage:update(bool)
	end)
	:onRightClick(function() setColorRGB(1) end)
	:onScroll(function(x)
		
		-- Modify color
		local damageRGB = vectors.hexToRGB(damageColor.curr)
		damageRGB[selectedRGB] = math.clamp(damageRGB[selectedRGB] + x/255, 0, 1)
		
		-- Update color
		damageColor:update("#"..vectors.rgbToHex(damageRGB):upper(), 20)
		
	end)
	:toggled(damage.curr)

-- Update actions
function events.RENDER()
	
	if action_wheel:isEnabled() then
		acts.firePage
			:title(toJson(
				{text = "Tail Fire Settings", bold = true, color = colors.primary}
			))
			:hoverColor(colors.hover)
		
		acts.fireEffectsToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Fire Effects\n\n", bold = true, color = colors.primary},
					{text = "Toggles the fire's ability to create particles and sounds.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
		acts.fireExpToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Fire Experience Gauge\n\n", bold = true, color = colors.primary},
					{text = "Allow the tail fire to change size based on experience level.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
		acts.fireReigniteSettings
			:title(toJson(
				{
					"",
					{text = "Set Fire Reignition & Timer\n\n", bold = true, color = colors.primary},
					{text = "Control the ability for your tail fire to auto-reignite, as well as how long until it does so.\n\n", color = colors.secondary},
					{text = "Current timer: ", bold = true, color = colors.secondary},
					{text = (maxTimer.curr >= 0 and (maxTimer.curr / 20).." Seconds" or "Cannot auto-reignite").."\n\n", color = maxTimer.curr < 0 and "red"},
					{text = "Scroll to adjust the timer.\nRight click resets timer to 10 seconds.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
		local rgbFireColor = vectors.hexToRGB(damageColor.curr) * 255
		acts.fireColorSettings
			:title(toJson(
				{
					"",
					{text = "Toggle Fire Damage Indicator/Set Fire Color\n\n", bold = true, color = colors.primary},
					{text = "Allow the tail fire to indicate overall health.\nAdditionally, sets the color of the fire while damaged.\nLeft click to toggle damage coloring.\nScroll to adjust an RGB Value.\n\n", color = colors.secondary},
					{text = "Selected RGB: ", bold = true, color = colors.secondary},
					{text = (selectedRGB == 1 and "[%d] "  or "%d " ):format(rgbFireColor.r), color = "red"},
					{text = (selectedRGB == 2 and "[%d] "  or "%d " ):format(rgbFireColor.g), color = "green"},
					{text = (selectedRGB == 3 and "[%d]\n" or "%d\n"):format(rgbFireColor.b), color = "blue"},
					{text = "Selected Hex: ", bold = true, color = colors.secondary},
					{text = damageColor.curr.."\n\n", color = "#"..damageColor.curr},
					{text = "Right click to change color channel.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
	end
	
end