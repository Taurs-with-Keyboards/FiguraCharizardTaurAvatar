-- Required scripts
local parts      = require("lib.GroupIndex")(models)
local waterTicks = require("scripts.WaterTicks")

-- Config setup
config:name("CharizardTaur")
local damage = config:load("FireDamage")
if damage == nil then damage = true end

-- Variable setup
local timer = 200
local normalText = textures["textures.normalFlame"]
local midwayText = textures:copy("textures.midwayFlame", textures["textures.normalFlame"])
local damageText = textures["textures.damageFlame"]
local dim = normalText:getDimensions()-1

-- Set Fire Parent Type
parts.Fire.Fire:parentType("CAMERA")

-- Find midway color between two pixels based on lerp
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

-- Lerp color table
local color = {
	prev = 0,
	curr = 0,
	next = 0
}

function events.TICK()
	
	-- Variables
	local exp    = math.map(math.clamp(player:getExperienceLevel(), 0, 30), 0, 30, 0.5, 1.5)
	local health = math.clamp(math.map((player:getHealth() / player:getMaxHealth()) * 1, 0.25, 1, 1, 0), 0, 1)
	
	-- Timer manipulation
	timer = timer + 1
	if waterTicks.wet == 0 then
		timer = 0
	elseif player:isOnFire() then
		timer = 200
	end
	
	-- Disable fire if below 200
	if timer < 200 then
		for enrty, value in pairs(scale) do
			scale[enrty] = 0
		end
	end
	
	color.prev = color.curr
	
	-- Targets
	scale.target = timer < 200 and 0 or exp
	color.next   = damage and math.round(health * 1000) / 1000 or 0
	
	-- Tick lerps
	scale.current  = scale.nextTick
	scale.nextTick = math.lerp(scale.nextTick, scale.target, 0.05)
	color.curr     = math.round(math.lerp(color.prev, color.next, avatar:getPermissionLevel() == "MAX" and 0.05 or 1) * 1000) / 1000
	
	if color.prev == color.curr and color.curr ~= color.next then
		for k, v in pairs(color) do
			color[k] = color.next
		end
	end
	
	-- Texture
	if avatar:getPermissionLevel() == "MAX" then
		if color.prev ~= color.curr then
			
			-- Compare and change pixels
			for x = 0, dim.x do
				for y = 0, dim.y do
					comparePixel(x, y, color.curr)
				end
			end
			
			-- Update texture
			midwayText:update()
			
		end
	end
	
end

function events.RENDER(delta, context)
	
	-- Render lerps
	scale.currentPos = math.lerp(scale.current, scale.nextTick, delta)
	
	-- Apply
	local texture = damage and (avatar:getPermissionLevel() == "MAX" and midwayText or color.curr == 1 and damageText or normalText) or normalText
	parts.Fire
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

-- Sync variables
local function syncFire(a)
	
	damage = a
	
end

-- Pings setup
pings.setFireDamage = setDamage
pings.syncFire      = syncFire

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncFire(damage)
		end
		
	end
end

-- Activate actions
setDamage(damage)

-- Setup table
local t = {}

t.damagePage = action_wheel:newAction("FireDamage")
	:title("§6§lToggle Fire Damage Indicator\n\n§3Allow the tail fire to indicate overall health.\n\n§cThis feature can be intensive, and will require\n\"§5Max§c\" permission level to see gradual change.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:lantern")
	:toggleItem("minecraft:soul_lantern")
	:onToggle(pings.setFireDamage)
	:toggled(damage)

-- Return action wheel pages
return t