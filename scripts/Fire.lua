-- Required scripts
local pokemonParts  = require("lib.GroupIndex")(models.models.CharizardTaur)
local pokeballParts = require("lib.GroupIndex")(models.models.Pokeball)
local average       = require("lib.Average")
local itemCheck     = require("lib.ItemCheck")
local color         = require("scripts.ColorProperties")

-- Config setup
config:name("CharizardTaur")
local damage  = config:load("FireDamage")
local effects = config:load("FireEffects")
if damage  == nil then damage  = true end
if effects == nil then effects = true end

-- Variable setup
local timer  = 200
local _timer = timer

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
local splash = false
function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, category, path)
	
	if player:isLoaded() then
		local firePos    = pokemonParts.Fire:partToWorldMatrix():apply()
		local atPos      = pos < firePos + 2 and pos > firePos - 2
		local splashID   = id == "minecraft:entity.splash_potion.break" or id == "minecraft:entity.lingering_potion.break"
		splash = atPos and splashID and path
	end
	
end

function events.TICK()
	
	if average(pokeballParts.Pokeball:getScale():unpack()) < 0.25 then
		-- Variables
		local firePos  = pokemonParts.Fire:partToWorldMatrix():apply()
		local exp      = math.map(math.clamp(player:getExperienceLevel(), 0, 30), 0, 30, 0.5, 1.5)
		local health   = math.clamp(math.map((player:getHealth() / player:getMaxHealth()) * 1, 0.25, 1, 1, 0), 0, 1)
		
		-- Timer manipulation
		timer = timer + 1
		if player:isWet()
		or splash
		or world.getBlockState(firePos):getFluidTags()[1] == "minecraft:water"
		or (world.getRainGradient() > 0.2 and world.isOpenSky(firePos) and world.getBiome(firePos):getPrecipitation() == "RAIN") then
			timer  = 0
			splash = false
		elseif player:isOnFire() then
			timer = 200
		end
		
		-- Disable fire if below 200
		if timer < 200 then
			for enrty, value in pairs(scale) do
				scale[enrty] = 0
			end
		end
		
		-- Extinguish fire
		if timer == 0 and _timer >= 200 then
			
			-- Set scale
			for enrty, value in pairs(scale) do
				scale[enrty] = 0
			end
			
			-- Effects
			if effects then
				
				-- Play sound
				sounds:playSound("entity.generic.extinguish_fire", firePos, 0.75)
			
				-- Spawn particles
				for i = 1, 30 do
					particles["campfire_cosy_smoke"]
						:pos(firePos + vec(math.random(-8, 8)/16, math.random(-8, 8)/16, math.random(-8, 8)/16))
						:velocity(0, 0.1, 0)
						:spawn()
				end
				
			end
			
		end
		
		-- Store previous values
		hue.prev = hue.curr
		_timer   = timer
		
		-- Targets
		scale.target = timer < 200 and 0 or exp
		hue.next     = damage and math.round(health * 1000) / 1000 or 0
		
		-- Tick lerps
		scale.current  = scale.nextTick
		scale.nextTick = math.lerp(scale.nextTick, scale.target, 0.05)
		hue.curr       = math.round(math.lerp(hue.prev, hue.next, avatar:getPermissionLevel() == "MAX" and 0.05 or 1) * 1000) / 1000
		
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
		
		-- Effects
		if effects and scale.currentPos >= 0.5 then
			
			local chance = math.random(1, math.map(exp, 0.5, 1.5, 1.5, 0.5) * 2000)
			if chance <= 5 then -- Campfire sound
				sounds:playSound("block.campfire.crackle", firePos, 0.75)
			elseif chance <= 15 and hue.curr < 0.5 then -- Lava bubble chance
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
	if host:isHost() and player:isLoaded() then
		sounds:playSound("item.flintandsteel.use", player:getPos(), 0.75)
	end
	
end

-- Fire effects toggle
local function setEffects(boolean)
	
	effects = boolean
	config:save("FireEffects", effects)
	if host:isHost() and player:isLoaded() then
		sounds:playSound(effects and "item.flintandsteel.use" or "entity.generic.extinguish_fire", player:getPos(), 0.75)
	end
	
end

-- Sync variables
local function syncFire(a, b)
	
	damage  = a
	effects = b
	
end

-- Pings setup
pings.setFireDamage  = setDamage
pings.setFireEffects = setEffects
pings.syncFire       = syncFire

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncFire(damage, effects)
		end
		
	end
end

-- Activate actions
setDamage(damage)
setEffects(effects)

-- Setup table
local t = {}

t.damagePage = action_wheel:newAction()
	:item(itemCheck("lantern"))
	:toggleItem(itemCheck("soul_lantern"))
	:onToggle(pings.setFireDamage)
	:toggled(damage)

t.effectsPage = action_wheel:newAction()
	:item(itemCheck("flint"))
	:toggleItem(itemCheck("flint_and_steel"))
	:onToggle(pings.setFireEffects)
	:toggled(effects)

-- Update action page info
function events.TICK()
	
	t.damagePage
		:title(color.primary.."Toggle Fire Damage Indicator\n\n"..color.secondary.."Allow the tail fire to indicate overall health.\n\n§cThis feature can be intensive, and will require\n\"§5Max§c\" permission level to see gradual change.")
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
	t.effectsPage
		:title(color.primary.."Toggle Fire Effects\n\n"..color.secondary.."Allow the tail fire to create particles and sounds.")
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
end

-- Return action wheel pages
return t