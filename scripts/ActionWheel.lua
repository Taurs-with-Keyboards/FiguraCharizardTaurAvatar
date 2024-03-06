-- Required scripts
local itemCheck = require("lib.ItemCheck")
local avatar    = require("scripts.Player")
local armor     = require("scripts.Armor")
local camera    = require("scripts.CameraControl")
local arms      = require("scripts.Arms")
local color     = require("scripts.ColorProperties")
local fall      = require("scripts.FallSound")
local fire      = require("scripts.Fire")
local anims     = require("scripts.Anims")
local pokeball  = require("scripts.Pokeball")

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

-- Page setups
local pages = {

	main    = action_wheel:newPage(),
	avatar  = action_wheel:newPage(),
	armor   = action_wheel:newPage(),
	camera  = action_wheel:newPage(),
	pokemon = action_wheel:newPage(),
	fire    = action_wheel:newPage(),
	anims   = action_wheel:newPage()
	
}

-- Page actions
local pageActions = {
	
	main = action_wheel:newAction()
		:item(itemCheck("armor_stand"))
		:onLeftClick(function() descend(pages.avatar) end),
	
	pokemon = action_wheel:newAction()
		:item(itemCheck("cobblemon:fire_stone", "campfire"))
		:onLeftClick(function() descend(pages.pokemon) end),
	
	anims = action_wheel:newAction()
		:item(itemCheck("jukebox"))
		:onLeftClick(function() descend(pages.anims) end),
	
	armor = action_wheel:newAction()
		:item(itemCheck("iron_chestplate"))
		:onLeftClick(function() descend(pages.armor) end),
	
	camera = action_wheel:newAction()
		:item(itemCheck("redstone"))
		:onLeftClick(function() descend(pages.camera) end),
	
	fire = action_wheel:newAction()
		:item(itemCheck("campfire"))
		:onLeftClick(function() descend(pages.fire) end)
	
}

-- Update action page info
function events.TICK()
	
	pageActions.main
		:title(color.primary.."Avatar Settings")
		:hoverColor(color.hover)
	
	pageActions.pokemon
		:title(color.primary.."Pokemon Settings")
		:hoverColor(color.hover)
	
	pageActions.anims
		:title(color.primary.."Animations")
		:hoverColor(color.hover)
	
	pageActions.armor
		:title(color.primary.."Armor Settings")
		:hoverColor(color.hover)
	
	pageActions.camera
		:title(color.primary.."Camera Settings")
		:hoverColor(color.hover)
	
	pageActions.fire
		:title(color.primary.."Tail Fire Settings")
		:hoverColor(color.hover)
	
end

-- Action back to previous page
local backAction = action_wheel:newAction()
	:title("§c§lGo Back?")
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item(itemCheck("barrier"))
	:onLeftClick(function() ascend() end)

-- Set starting page to main page
action_wheel:setPage(pages.main)

-- Main actions
pages.main
	:action( -1, pageActions.main)
	:action( -1, pageActions.pokemon)
	:action( -1, pageActions.anims)
	:action( -1, pokeball.togglePage)

-- Avatar actions
pages.avatar
	:action( -1, avatar.vanillaSkinPage)
	:action( -1, avatar.modelPage)
	:action( -1, pageActions.armor)
	:action( -1, pageActions.camera)
	:action( -1, backAction)

-- Armor actions
pages.armor
	:action( -1, armor.allPage)
	:action( -1, armor.bootsPage)
	:action( -1, armor.leggingsPage)
	:action( -1, armor.chestplatePage)
	:action( -1, armor.helmetPage)
	:action( -1, backAction)

-- Camera actions
pages.camera
	:action( -1, camera.posPage)
	:action( -1, camera.eyePage)
	:action( -1, backAction)

pages.pokemon
	:action( -1, arms.holdPage)
	:action( -1, color.shinyPage)
	:action( -1, fall.soundPage)
	:action( -1, pageActions.fire)
	:action( -1, backAction)

-- Fire actions
pages.fire
	:action( -1, fire.damagePage)
	:action( -1, fire.effectsPage)
	:action( -1, backAction)

-- Animation actions
pages.anims
	:action( -1, arms.movePage)
	:action( -1, backAction)