-- Required scripts
local pokemonParts  = require("lib.GroupIndex")(models.models.CharizardTaur)
local pokeballParts = require("lib.GroupIndex")(models.models.Pokeball)
local average       = require("lib.Average")
local itemCheck     = require("lib.ItemCheck")
local color         = require("scripts.ColorProperties")

-- Config setup
config:name("CharizardTaur")
local damage   = config:load("FireDamage")
local reignite = config:load("FireReignite")
local maxTimer = config:load("FireMaxTimer") or 200
local effects  = config:load("FireEffects")
if damage   == nil then damage   = true end
if reignite == nil then reignite = true end
if effects  == nil then effects  = true end

-- Variable setup
local timer = maxTimer

-- Fire tail triggers
local trigger = {
	water  = false,
	rain   = false,
	splash = false,
	fire   = false,
	lava   = false,
	lit    = false
}

local fireBlocks = {
	"minecraft:fire",
	"minecraft:soul_fire",
	"minecraft:torch",
	"minecraft:soul_torch"
}

-- Texture variables setup
local normalText = textures["textures.normalFlame"]
local midwayText = textures:copy("textures.midwayFlame", textures["textures.normalFlame"])
local damageText = textures["textures.damageFlame"]
local dim = normalText:getDimensions()-1

-- Set Fire Parent Type
pokemonParts.Fire.Fire:parentType("CAMERA")

-- Find midway hue between two pixels based on lerp
local function comparePixel(x, y, d)
	
	-- Find pixels at given cords
	local normalText = normalText:getPixel(x, y)
	local damageText = damageText:getPixel(x, y)
	
	-- If the pixels are the exact same, stop function
	if normalText == damageText then return end
	
	-- Find desired midpoint
	local midway = math.lerp(normalText, damageText, d)
	
	-- Apply to midpoint texture
	midwayText:setPixel(x, y, midway)
	
end

-- Lerp scale table
local scale = {
	current    = 1,
	nextTick   = 1,
	target     = 1,
	currentPos = 1
}

-- Lerp hue table
local hue = {
	prev = 0,
	curr = 0,
	next = 0
}

-- Check if a splash potion is broken near the player
function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, category, path)
	
	if player:isLoaded() then
		local firePos  = pokemonParts.Fire:partToWorldMatrix():apply()
		local atPos    = pos < firePos + 2 and pos > firePos - 2
		local splashID = id == "minecraft:entity.splash_potion.break" or id == "minecraft:entity.lingering_potion.break"
		trigger.splash = atPos and splashID and path
	end
	
end

function events.TICK()
	
	if average(pokeballParts.Pokeball:getScale():unpack()) < 0.25 then
		-- Variables
		local firePos = pokemonParts.Fire:partToWorldMatrix():apply()
		local block   = world.getBlockState(firePos)
		local exp     = math.map(math.clamp(player:getExperienceLevel(), 0, 30), 0, 30, 0.5, 1.5)
		local health  = math.clamp(math.map((player:getHealth() / player:getMaxHealth()) * 1, 0.25, 1, 1, 0), 0, 1)
		
		-- Check fluid tags
		for _, tag in ipairs(block:getFluidTags()) do
			trigger.water = tag == "minecraft:water" or tag == "c:water"
			trigger.lava  = tag == "minecraft:lava"  or tag == "c:lava"
		end
		-- If no fluid tags, reset
		if next(block:getFluidTags()) == nil then
			trigger.water = false
			trigger.lava  = false
		end
		
		-- Check rain
		trigger.rain = world.getRainGradient() > 0.2 and world.isOpenSky(firePos) and world.getBiome(firePos):getPrecipitation() == "RAIN"
		
		-- Check fire
		if block.id ~= "minecraft:air" then
			for _, type in ipairs(fireBlocks) do
				if block.id == type then
					trigger.fire = true
					break
				end
			end
		else
			trigger.fire = false
		end
		
		-- Check campfire lit tags
		if next(block.properties) ~= nil then
			trigger.lit = block.properties["lit"] == "true"
		else
			trigger.lit = false
		end
		
		-- Timer manipulation
		if trigger.water or trigger.rain or trigger.splash then
			timer = 0
			trigger.splash = false
		elseif trigger.lava or trigger.fire or trigger.lit or timer >= maxTimer then
			timer = maxTimer
		elseif reignite and timer < maxTimer then
			timer = timer + 1
		end
		
		-- Extinguish fire
		if timer == 0 and scale.currentPos ~= 0 then
			
			-- Effects
			if effects then
				
				-- Play sound
				sounds:playSound("entity.generic.extinguish_fire", firePos, 0.75)
			
				-- Spawn particles
				for i = 1, math.floor(math.map(scale.currentPos, 0, 1.5, 0, 20)) do
					particles["campfire_cosy_smoke"]
						:pos(firePos + vec(math.random(-8, 8)/16, math.random(-8, 8)/16, math.random(-8, 8)/16))
						:velocity(0, 0.1, 0)
						:spawn()
				end
				
			end
			
			-- Set scale
			for enrty, value in pairs(scale) do
				scale[enrty] = 0
			end
			
		end
		
		-- Effects
		if effects and scale.currentPos > 0.25 then
			
			-- Chance
			local weight = math.map(scale.currentPos, 0, 2, 4000, 0)
			local chance = math.random(1, math.max(weight, 1))
			
			if chance <= 5 then -- Campfire sound
				sounds:playSound("block.campfire.crackle", firePos, 0.75)
			elseif chance <= 20 then -- Lava bubble chance
				particles["lava"]
					:pos(firePos)
					:spawn()
			elseif chance <= 125 then -- Smoke chance
				particles["campfire_cosy_smoke"]
					:pos(firePos + vec(math.random(-2, 2)/16, math.random(0, 8)/16, math.random(-2, 2)/16))
					:velocity(0, 0.1, 0)
					:spawn()
			end
			
		end
		
		-- Store previous value
		hue.prev = hue.curr
		
		-- Targets
		scale.target = math.max((timer / maxTimer) * 2 - 1, 0) * exp
		hue.next     = damage and math.round(health * 1000) / 1000 or 0
		
		-- Tick lerps
		scale.current  = scale.nextTick
		scale.nextTick = math.lerp(scale.nextTick, scale.target, 0.05)
		hue.curr       = math.round(math.lerp(hue.prev, hue.next, avatar:getPermissionLevel() == "MAX" and 0.05 or 1) * 1000) / 1000
		
		-- Force hue values to match if close
		-- Reduces instruction count
		if hue.prev == hue.curr and hue.curr ~= hue.next then
			for k, v in pairs(hue) do
				hue[k] = hue.next
			end
		end
		
		-- Texture
		if avatar:getPermissionLevel() == "MAX" then
			if hue.prev ~= hue.curr then
				
				-- Compare and change pixels
				for x = 0, dim.x do
					for y = 0, dim.y do
						comparePixel(x, y, hue.curr)
					end
				end
				
				-- Update texture
				midwayText:update()
				
			end
		end
	end
	
end

function events.RENDER(delta, context)
	
	-- Render lerps
	scale.currentPos = math.lerp(scale.current, scale.nextTick, delta)
	
	-- Apply
	local texture = damage and (avatar:getPermissionLevel() == "MAX" and midwayText or hue.curr == 1 and damageText or normalText) or normalText
	pokemonParts.Fire
		:scale(scale.currentPos)
		:primaryTexture("CUSTOM",   texture)
		:secondaryTexture("CUSTOM", texture)
		:secondaryRenderType(context == "RENDER" and "EMISSIVE" or "EYES")
	
end

-- Fire damage toggle
local function setDamage(boolean)
	
	damage = boolean
	config:save("FireDamage", damage)
	if host:isHost() and player:isLoaded() and damage then
		sounds:playSound("entity.player.hurt", player:getPos(), 0.75)
	end
	
end

-- Reignite toggle
local function setReignite(boolean)
	
	reignite = boolean
	config:save("FireReignite", reignite)
	if host:isHost() and player:isLoaded() then
		sounds:playSound(reignite and "item.flintandsteel.use" or "entity.generic.extinguish_fire", player:getPos(), 0.75)
	end
	
end

-- Set max timer
local function setMaxTimer(x)
	
	if reignite then
		maxTimer = math.clamp(maxTimer + (x * 20), 100, 6000)
		config:save("FireMaxTimer", maxTimer)
	end
	
end

-- Fire effects toggle
local function setEffects(boolean)
	
	effects = boolean
	config:save("FireEffects", effects)
	if host:isHost() and player:isLoaded() and effects then
		sounds:playSound("item.firecharge.use", player:getPos(), 0.75)
	end
	
end

-- Sync variables
local function syncFire(a, b, x, c)
	
	damage   = a
	reignite = b
	maxTimer = x
	effects  = c
	
end

-- Pings setup
pings.setFireDamage   = setDamage
pings.setFireReignite = setReignite
pings.setFireEffects  = setEffects
pings.syncFire        = syncFire

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncFire(damage, reignite, maxTimer, effects)
		end
		
	end
end

-- Activate actions
setDamage(damage)
setReignite(reignite)
setEffects(effects)

-- Setup table
local t = {}

t.damagePage = action_wheel:newAction()
	:item(itemCheck("lantern"))
	:toggleItem(itemCheck("soul_lantern"))
	:onToggle(pings.setFireDamage)
	:toggled(damage)

t.fuelPage = action_wheel:newAction()
	:item(itemCheck("flint"))
	:toggleItem(itemCheck("flint_and_steel"))
	:onScroll(setMaxTimer)
	:onToggle(pings.setFireReignite)
	:onRightClick(function() maxTimer = 200 config:save("FireMaxTimer", maxTimer) end)
	:toggled(reignite)

t.effectsPage = action_wheel:newAction()
	:item(itemCheck("white_wool"))
	:toggleItem(itemCheck("note_block"))
	:onToggle(pings.setFireEffects)
	:toggled(effects)

-- Update action page info
function events.TICK()
	
	t.damagePage
		:title(toJson
			{"",
			{text = "Toggle Fire Damage Indicator\n\n", bold = true, color = color.primary},
			{text = "Allow the tail fire to indicate overall health.\n\n", color = color.secondary},
			{text = "This feature can be intensive, and will require\n\"", color = "red"},
			{text = "Max", color = "dark_purple"},
			{text = "\" permission level to see gradual change.", color = "red"}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
	t.fuelPage
		:title(toJson
			{"",
			{text = "Set Fire Reignition/Timer\n\n", bold = true, color = color.primary},
			{text = "Sets the ability for your tail fire to auto-reignite, and how long until full power.\n\n", color = color.secondary},
			{text = "Current ingition timer: ", bold = true, color = color.secondary},
			{text = (reignite and ((maxTimer / 20).." Seconds") or "Cannot auto-reignite").."\n\n", color = not reignite and "red"},
			{text = "Scrolling up adds time, Scrolling down subtracts time.\nRight click resets timer to 10 seconds.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
	t.effectsPage
		:title(toJson
			{"",
			{text = "Toggle Fire Effects\n\n", bold = true, color = color.primary},
			{text = "Allow the tail fire to create particles and sounds.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
end

-- Return action wheel pages
return t