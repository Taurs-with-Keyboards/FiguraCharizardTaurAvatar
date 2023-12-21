-- Hit sound
function events.TICK()
	if player:getNbt()["HurtTime"] == 10 then
		if models.Pokeball:getScale().x > 0.5 then
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

if host:isHost() then

	-- Keybind config
	config:name("CharizardTaur")
	local bind = config:load("PokemonCryKeybind") or "key.keyboard.c"
	
	-- Cooldown timer
	function events.TICK()
		if cooldown < 30 then
			cooldown = cooldown + 1
		end
	end
	
	-- Keybind
	local kbCry = keybinds:newKeybind("Pokemon Cry"):onPress(function() if cooldown == 30 and player:getDeathTime() == 0 then pings.playPokemonCry() end end):key(bind)
	
	-- Config updater
	function events.TICK()
		local key = kbCry:getKey()
		if key ~= bind then
			bind = key
			config:save("PokemonCryKeybind", key)
		end
	end
end