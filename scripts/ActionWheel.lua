-- Connects various actions accross many scripts into pages
local mainPage = action_wheel:newPage("MainPage")
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
	:action( 1,
		action_wheel:newAction()
			:title("§6§lAvatar Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:armor_stand")
			:onLeftClick(function() action_wheel:setPage(avatPage) end))
	
	:action( 2,
		action_wheel:newAction()
			:title("§6§lCamera Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:redstone")
			:onLeftClick(function() action_wheel:setPage(camPage) end))
	
	:action( 3, require("scripts.Pokeball").togglePage)

-- Avatar actions
do
	local avatar = require("scripts.Player")
	local arms   = require("scripts.Arms")
	avatPage
		:action( 1, avatar.vanillaSkinPage)
		:action( 2, avatar.modelPage)
		:action( 3, arms.movePage)
		:action( 4, arms.holdPage)
		:action( 5, backPage)
end

-- Camera actions
do
	local camera = require("scripts.CameraControl")
	camPage
		:action( 1, camera.posPage)
		:action( 2, camera.rotPage)
		:action( 3, camera.eyePage)
		:action( 4, backPage)
end