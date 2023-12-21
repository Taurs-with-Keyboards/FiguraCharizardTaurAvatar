-- Variable setup
config:name("LaprasTaur")
local timer = config:load("FallSoundDryTimer") or 400

-- Table setup
local t = {}
t.wet   = timer -- Rain
t.water = timer -- In Water
t.under = timer -- Underwater

-- Each tick add one to each timer. Reset if confition met.
function events.TICK()
	t.wet   = t.wet   + 1
	t.water = t.water + 1
	t.under = t.under + 1
	if player:isWet() then
		t.wet   = 0
	end
	if player:isInWater() or player:isInLava() then
		t.water = 0
	end
	if player:isUnderwater() or player:isInLava() then
		t.under = 0
	end
end

-- Return table
return t