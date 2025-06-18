-- Disables code if not avatar host
if not host:isHost() then return end

-- Required script
local itemCheck = require("lib.ItemCheck")

local s, avatar = pcall(require, "scripts.Player")
if not s then avatar = {} end

local s, armor = pcall(require, "scripts.Armor")
if not s then armor = {} end

local s, camera = pcall(require, "scripts.CameraControl")
if not s then camera = {} end

local s, squapi = pcall(require, "scripts.SquishyAnims")
if not s then squapi = {} end

local s, pokeball = pcall(require, "scripts.Pokeball")
if not s then pokeball = {} end

local s, shiny = pcall(require, "scripts.Shiny")
if not s then shiny = {} end

local s, fire = pcall(require, "scripts.Fire")
if not s then fire = {} end

local s, arms = pcall(require, "scripts.Arms")
if not s then arms = {} end

local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

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
	
	main      = action_wheel:newPage("Main"),
	avatar    = action_wheel:newPage("Avatar"),
	armor     = action_wheel:newPage("Armor"),
	camera    = action_wheel:newPage("Camera"),
	charizard = action_wheel:newPage("Charizard"),
	fire      = action_wheel:newPage("Fire"),
	anims     = action_wheel:newPage("Anims")
	
}

-- Page actions
local pageActs = {
	
	avatar = action_wheel:newAction()
		:item(itemCheck("armor_stand"))
		:onLeftClick(function() descend(pages.avatar) end),
	
	charizard = action_wheel:newAction()
		:item(itemCheck("cobblemon:fire_stone", "campfire"))
		:onLeftClick(function() descend(pages.charizard) end),
	
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

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		pageActs.avatar
			:title(toJson(
				{text = "Avatar Settings", bold = true, color = c.primary}
			))
		
		pageActs.charizard
			:title(toJson(
				{text = "Charizard Settings", bold = true, color = c.primary}
			))
		
		pageActs.anims
			:title(toJson(
				{text = "Animations", bold = true, color = c.primary}
			))
		
		pageActs.armor
			:title(toJson(
				{text = "Armor Settings", bold = true, color = c.primary}
			))
		
		pageActs.camera
			:title(toJson(
				{text = "Camera Settings", bold = true, color = c.primary}
			))
		
		pageActs.fire
			:title(toJson(
				{text = "Tail Fire Settings", bold = true, color = c.primary}
			))
		
		for _, act in pairs(pageActs) do
			act:hoverColor(c.hover)
		end
	
	end
	
end

-- Action back to previous page
local backAct = action_wheel:newAction()
	:title(toJson(
		{text = "Go Back?", bold = true, color = "red"}
	))
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item(itemCheck("barrier"))
	:onLeftClick(function() ascend() end)

-- Set starting page to main page
action_wheel:setPage(pages.main)

-- Main actions
pages.main
	:action( -1, pageActs.avatar)
	:action( -1, pageActs.charizard)
	:action( -1, pageActs.anims)

-- Avatar actions
pages.avatar
	:action( -1, avatar.vanillaSkinAct)
	:action( -1, avatar.modelAct)
	:action( -1, pageActs.armor)
	:action( -1, pageActs.camera)
	:action( -1, backAct)

-- Armor actions
pages.armor
	:action( -1, armor.allAct)
	:action( -1, armor.bootsAct)
	:action( -1, armor.leggingsAct)
	:action( -1, armor.chestplateAct)
	:action( -1, armor.helmetAct)
	:action( -1, backAct)

-- Camera actions
pages.camera
	:action( -1, camera.posAct)
	:action( -1, camera.eyeAct)
	:action( -1, backAct)

-- Charizard actions
pages.charizard
	:action( -1, pokeball.toggleAct)
	:action( -1, shiny.shinyAct)
	:action( -1, pageActs.fire)
	:action( -1, backAct)

-- Fire actions
pages.fire
	:action( -1, fire.effectsAct)
	:action( -1, fire.experienceAct)
	:action( -1, fire.reigniteAct)
	:action( -1, fire.colorAct)
	:action( -1, fire.damageAct)
	:action( -1, backAct)

-- Animation actions
pages.anims
	:action( -1, squapi.armsAct)
	:action( -1, backAct)