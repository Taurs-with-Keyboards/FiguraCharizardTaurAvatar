-- Required scripts
local model      = require("scripts.ModelParts")
local waterTicks = require("scripts.WaterTicks")
local origins    = require("lib.OriginsAPI")

-- Config setup
config:name("CharizardTaur")
local damage = config:load("FireDamage")
if damage == nil then damage = true end

-- Variable setup
local timer = 200

-- Lerp scale table
local scale = {
	current    = 1,
	nextTick   = 1,
	target     = 1,
	currentPos = 1
}

local color = {
	prev = 0,
	curr = 0,
	next = 0
}

function events.TICK()
	
	-- Variables
	local exp   = math.map(math.clamp(player:getExperienceLevel(), 0, 30), 0, 30, 0.5, 1.5)
	local power = origins.hasPower(player, "origins:charizard_light")
	
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
	
	-- Sets model light to match fire tail
	model.model:light((power or timer >= 200) and 15 or nil)
	
	-- Targets
	scale.target = timer < 200 and 0 or exp
	
	-- Tick lerps
	scale.current  = scale.nextTick
	scale.nextTick = math.lerp(scale.nextTick, scale.target, 0.05)
	
end

function events.RENDER(delta, context)
	
	-- Render lerps
	scale.currentPos = math.lerp(scale.current, scale.nextTick, delta)
	
	-- Apply
	model.fire
		:scale(scale.currentPos)
		:secondaryRenderType(context == "RENDER" and "EMISSIVE" or "EYES")
	
end

-- Color variables/setup
local colorCurrent, colorPrevTick, colorTarget = 0, 0, 0
local normalText = textures["textures.normalFlame"]
local damageText = textures["textures.damageFlame"]
local dim = normalText:getDimensions()-1

-- Set secondary texture to share primary texture
model.fire:secondaryTexture("CUSTOM", textures["textures.normalFlame"])

-- Check average based on colorCurrent between two textures
local function comparePixels(x, y)
	local normalPixel = normalText:getPixel(x, y)
	local damagePixel = damageText:getPixel(x, y)
	local average = math.lerp(normalPixel, damagePixel, colorCurrent)
	normalText:setPixel(x, y, average)
end

-- Return number down to desired decimals
local function round(number, decimals)
	local power = 10^decimals
	return math.floor(number * power) / power
end

-- Color functions
function events.TICK()
	if avatar:getPermissionLevel() == "MAX" then
		
		-- Damage target
		local health = player:getHealth() / player:getMaxHealth()
		colorTarget = damage and math.clamp(math.map(health, 0.25, 1, 1, 0), 0, 1) or 0
		
		-- Tick lerp
		colorCurrent = round(math.lerp(colorCurrent, colorTarget, 0.05), 3)
		
		if colorCurrent ~= colorPrevTick then
			normalText:restore()
			for x = 0, dim.x do
				for y = 0, dim.y do
					comparePixels(x, y)
				end
			end
			normalText:update()
			colorPrevTick = colorCurrent
		end
		
	end
end

-- Fire damage toggle
local function setDamage(boolean)
	damage = boolean
	config:save("FireDamage", damage)
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
	:title("§6§lToggle Fire Damage Indicator\n\n§3Allow the tail fire to indicate overall health.\n§cThis feature can be intensive, and requires \"§5Max§c\" permission level to be visible.")
	:hoverColor(vectors.hexToRGB("D8741E"))
	:toggleColor(vectors.hexToRGB("BA4A0F"))
	:item("minecraft:campfire")
	:toggleItem("minecraft:soul_campfire")
	:onToggle(pings.setFireDamage)
	:toggled(damage)

-- Return table
return t