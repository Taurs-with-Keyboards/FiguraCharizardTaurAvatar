-- Required scripts
local parts = require("lib.GroupIndex")(models)

-- Keybind config
config:name("CharizardTaur")
local bind = config:load("PokemonCryKeybind") or "key.keyboard.c"

-- Get the average of a vector
local function average(vec)
	
	local sum = 0
	for _, v in ipairs{vec:unpack()} do
		sum = sum + v
	end
	return sum / #vec
	
end

function events.TICK()
	
	-- Hit sound
	if player:getNbt()["HurtTime"] == 10 then
		if average(parts.Pokeball:getScale()) > 0.5 then
			sounds:playSound("cobblemon:poke_ball.open", player:getPos(), 0.4)
		else
			sounds:playSound("cobblemon:pokemon.charizard.cry", player:getPos(), 0.6, math.random()*0.35+0.85)
		end
	end
	
end

-- Keybind cry noise
local cooldown = 0
local function pokemonCry()
	
	sounds:playSound("cobblemon:pokemon.charizard.cry", player:getPos(), 0.6, math.random()*0.35+0.85)
	cooldown = 0
	
end

-- Keybind ping setup
pings.playPokemonCry = pokemonCry

-- Keybind
local kbCry = keybinds:newKeybind("Pokemon Cry"):onPress(function() pings.playPokemonCry() end):key(bind)

function events.TICK()
	
	-- Cooldown timer
	if cooldown < 30 then
		cooldown = cooldown + 1
	end
	
	kbCry:enabled(cooldown == 30 and player:getDeathTime() == 0)
	
	-- Config updater
	local key = kbCry:getKey()
	if key ~= bind then
		bind = key
		config:save("PokemonCryKeybind", key)
	end
	
end