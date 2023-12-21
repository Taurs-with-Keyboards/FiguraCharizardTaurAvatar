-- Connects various actions accross many scripts into pages
local mainPage = action_wheel:newPage("MainPage")
local fallPage = action_wheel:newPage("FallSoundPage")
local avatPage = action_wheel:newPage("AvatarPage")
local camPage  = action_wheel:newPage("CameraPage")
local backPage = action_wheel:newAction()
	:title("§c§lGo Back?")
	:hoverColor(vectors.hexToRGB("FF7F7F"))
	:item("minecraft:barrier")
	:onLeftClick(function() action_wheel:setPage(mainPage) end)

action_wheel:setPage(mainPage)

-- Main actions
mainPage
	:action( -1,
		action_wheel:newAction()
			:title("§6§lFall Sound Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:pufferfish")
			:onLeftClick(function() action_wheel:setPage(fallPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§6§lAvatar Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:armor_stand")
			:onLeftClick(function() action_wheel:setPage(avatPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§6§lCamera Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:redstone")
			:onLeftClick(function() action_wheel:setPage(camPage) end))
	
	:action( -1, require("scripts.Pokeball").togglePage)

-- Flop sound actions
do
	--local fall = require("scripts.FallSound")
	fallPage
		--:action( -1, fall.soundPage)
		:action( -1, backPage)
end

-- Avatar actions
do
	local avatar = require("scripts.Player")
	avatPage
		:action( -1, avatar.vanillaSkinPage)
		:action( -1, avatar.modelPage)
		--:action( -1, avatar.skinPage)
		--:action( -1, require("scripts.Animations"))
		:action( -1, require("scripts.Arms"))
		:action( -1, backPage)
end

-- Camera actions
do
	local camera = require("scripts.CameraControl")
	camPage
		:action( -1, camera.posPage)
		:action( -1, camera.rotPage)
		:action( -1, camera.eyePage)
		:action( -1, backPage)
end