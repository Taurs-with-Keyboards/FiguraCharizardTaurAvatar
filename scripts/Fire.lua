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

-- Find midway color between two pixels based on lerp
local function comparePixel(x, y, d)
	
	local normal = normalText:getPixel(x, y)
	local damage = damageText:getPixel(x, y)
	
	local midway = math.lerp(normal, damage, d)
	
	midwayText:setPixel(x, y, midway)
	
end

-- Return number down to desired decimals
local function round(n, d)
	
	local p = 10 ^ d
	return math.floor(n * p) / p
	
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
	local exp = math.map(math.clamp(player:getExperienceLevel(), 0, 30), 0, 30, 0.5, 1.5)
	
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
	
	-- Targets
	scale.target = timer < 200 and 0 or exp
	
	-- Tick lerps
	scale.current  = scale.nextTick
	scale.nextTick = math.lerp(scale.nextTick, scale.target, 0.05)
	
	-- Texture
	if avatar:getPermissionLevel() == "MAX" then
		
		-- Set fire textures to midway textures
		parts.Fire
			:primaryTexture("CUSTOM", midwayText)
			:secondaryTexture("CUSTOM", midwayText)
		
		-- Damage target
		local health = player:getHealth() / player:getMaxHealth()
		color.next   = damage and math.clamp(math.map(health, 0.25, 1, 1, 0), 0, 1) or 0
		
		-- Tick lerp
		color.curr = round(math.lerp(color.prev, color.next, 0.05), 3)
		
		-- Apply
		if color.curr ~= color.next then
			for x = 0, dim.x do
				for y = 0, dim.y do
					comparePixel(x, y, color.curr)
				end
			end
			
			-- Store color variable and update texture
			color.prev = color.curr
			midwayText:update()
			
		end
		
	else
		
		-- Set fire textures to normal textures
		parts.Fire
			:primaryTexture("CUSTOM", normalText)
			:secondaryTexture("CUSTOM", normalText)
		
	end
	
	
end

function events.RENDER(delta, context)
	
	-- Render lerps
	scale.currentPos = math.lerp(scale.current, scale.nextTick, delta)
	
	-- Apply
	parts.Fire
		:scale(scale.currentPos)
		:secondaryRenderType(context == "RENDER" and "EMISSIVE" or "EYES")
	
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

-- Return action wheel pages
return t