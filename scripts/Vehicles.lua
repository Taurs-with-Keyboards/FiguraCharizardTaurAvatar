-- Table setup
local t         = {}
t.vehicle       = nil   -- Vehicle exists
t.vehicleType   = false -- Vehicle type
t.isPassenger   = false -- Player is passenger
t.hasPassenger  = false -- Player has passenger (in vehicle)
t.isVehicle     = false -- Player is vehicle 

t.player        = false -- Is player
t.boat          = false -- Is boat
t.chest_boat    = false -- Is chest boat
t.minecart      = false -- Is minecart
t.horse         = false -- Is horse
t.donkey        = false -- Is donkey
t.mule          = false -- Is mule
t.zombieHorse   = false -- Is Zombie Horse
t.skeletonHorse = false -- Is Skeleton Horse
t.pig           = false -- Is pig
t.strider       = false -- Is strider
t.camel         = false -- Is camel

-- Variables setup
local prevType = false

function events.TICK()
	-- Get player name
	local name = player:getName()
	
	-- Get vehicle data
	t.vehicle = player:getVehicle()
	if t.vehicle then
		t.vehicleType  = t.vehicle:getType()
		t.isPassenger  = t.vehicle:getControllingPassenger() and t.vehicle:getControllingPassenger():getName() ~= name or false
		t.hasPassenger = #t.vehicle:getPassengers() > 1 and not t.isPassenger
	else
		t.vehicleType  = false
		t.isPassenger  = false
		t.hasPassenger = false
	end
	
	t.isVehicle = #player:getPassengers() > 0
	
	-- Update vehicle type
	if prevType ~= t.vehicleType then
		t.player        = t.vehicleType == "minecraft:player"
		t.boat          = t.vehicleType == "minecraft:boat"
		t.chest_boat    = t.vehicleType == "minecraft:chest_boat"
		t.minecart      = t.vehicleType == "minecraft:minecart"
		t.horse         = t.vehicleType == "minecraft:horse"
		t.donkey        = t.vehicleType == "minecraft:donkey"
		t.mule          = t.vehicleType == "minecraft:mule"
		t.zombieHorse   = t.vehicleType == "minecraft:zombie_horse"
		t.skeletonHorse = t.vehicleType == "minecraft:skeleton_horse"
		t.pig           = t.vehicleType == "minecraft:pig"
		t.strider       = t.vehicleType == "minecraft:strider"
		t.camel         = t.vehicleType == "minecraft:camel"
	end
	
	prevType = t.vehicleType
end

-- GSCarrier setup
local carrier = require("lib.GSCarrier")

-- GSCarrier rider
carrier.rider.addRoots(models)
carrier.rider.addTag("gscarrier:taur")
carrier.rider.controller.setGlobalOffset(vec(0, -10, 0))
carrier.rider.controller.setModifyCamera(false)
carrier.rider.controller.setModifyEye(false)
carrier.rider.controller.setAimEnabled(false)

-- GSCarrier vehicle
carrier.vehicle.addTag("gscarrier:taur", "gscarrier:land", "gscarrier:air")

carrier.vehicle.newSeat("Seat1", models.CharizardTaur.Player.LowerBody.Midsection.Seat1, {
	priority = 1,
	tags = {["gscarrier:piggyback"] = true}
})

-- Returns table
return t