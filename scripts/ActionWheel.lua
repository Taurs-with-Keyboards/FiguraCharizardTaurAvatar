-- Required scripts
local avatar   = require("scripts.Player")
local armor    = require("scripts.Armor")
local camera   = require("scripts.CameraControl")
local arms     = require("scripts.Arms")
local fire     = require("scripts.Fire")
local fall     = require("scripts.FallSound")
local anims    = require("scripts.Anims")
local pokeball = require("scripts.Pokeball")

-- Page setups
local mainPage      = action_wheel:newPage("MainPage")
local avatarPage    = action_wheel:newPage("AvatarPage")
local armorPage     = action_wheel:newPage("ArmorPage")
local cameraPage    = action_wheel:newPage("CameraPage")
local charizardPage = action_wheel:newPage("CharizardPage")
local firePage      = action_wheel:newPage("FirePage")
local animsPage     = action_wheel:newPage("AnimationPage")

-- Logs pages for navigation
local navigation = {}

-- Go forward a page
local function descend(page)
	
	navigation[#navigation + 1] = action_wheel:getCurrentPage() 
	action_wheel:setPage(page)
	
end

-- Go back a page
local function ascend()
	
	action_wheel:setPage(table.remove(navigation, #navigation))
	
end

-- Action back to previous page
local backPage = action_wheel:newAction()
	:title("§c§lGo Back?")
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item("minecraft:barrier")
	:onLeftClick(function() ascend() end)

-- Set starting page to main page
action_wheel:setPage(mainPage)

-- Main actions
mainPage
	:action( -1,
		action_wheel:newAction()
			:title("§6§lAvatar Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:armor_stand")
			:onLeftClick(function() descend(avatarPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§6§lCharizard Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:campfire")
			:onLeftClick(function() descend(charizardPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§6§lAnimations")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:jukebox")
			:onLeftClick(function() descend(animsPage) end))
	
	:action( -1, pokeball.togglePage)

-- Avatar actions
avatarPage
	:action( -1, avatar.vanillaSkinPage)
	:action( -1, avatar.modelPage)
	:action( -1,
		action_wheel:newAction()
			:title("§6§lArmor Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:iron_chestplate")
			:onLeftClick(function() descend(armorPage) end))
	:action( -1,
		action_wheel:newAction()
			:title("§6§lCamera Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:redstone")
			:onLeftClick(function() descend(cameraPage) end))
	:action( -1, backPage)

-- Armor actions
armorPage
	:action( -1, armor.allPage)
	:action( -1, armor.bootsPage)
	:action( -1, armor.leggingsPage)
	:action( -1, armor.chestplatePage)
	:action( -1, armor.helmetPage)
	:action( -1, backPage)

-- Camera actions
cameraPage
	:action( -1, camera.posPage)
	:action( -1, camera.eyePage)
	:action( -1, backPage)

charizardPage
	:action( -1, arms.holdPage)
	:action( -1,
		action_wheel:newAction()
			:title("§6§lTail Fire Settings")
			:hoverColor(vectors.hexToRGB("D8741E"))
			:item("minecraft:flint_and_steel")
			:onLeftClick(function() descend(firePage) end))
	:action( -1, fall.soundPage)
	:action( -1, avatar.shinyPage)
	:action( -1, backPage)

-- Fire actions
firePage
	:action( -1, fire.damagePage)
	:action( -1, backPage)

-- Animation actions
animsPage
	:action( -1, arms.movePage)
	:action( -1, backPage)