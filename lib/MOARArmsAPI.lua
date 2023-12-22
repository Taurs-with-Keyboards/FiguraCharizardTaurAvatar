--MOAR Arms API by MitchOfTarcoola
--Allows for creation of custom player arms, mainly for avatars with more than 2 arms.
--Designed to fully replace vanilla arms
--Very W.I.P

--[[
FEATURES:

* arms will visually behave almost like vanilla arms (its not perfect but it works well)
* Works with items that have custom hold/use poses (bows, cbows, tridents, shields, etc)
  * Modded items that have custom hold/use can be inserted into the ItemOverrides table to work.
* Arms can be set up to hold specific hotbar slots, alongside mainhand and offhand. The arm holding the mainhand slot won't hold items assigned to other arms, that arm does it instead.
* Arm animations can be configured, and custom bbench anims added, per arm


to-do (if I can be bothered)

 * proper item-specific use anims for key items, instead of just using vanilla rots
   * find a way to make certain items display like in vanilla when used (things like bow/cbow charging, and trident/spyglass rotating)
 * cleanup/bugfixes where needed
   * better commenting, both for myself and anyone trying to understand how this all works
 * other stuff that i havent thought about yet



HOW TO USE

--at the top of the script, put a require for this stored as a variable, like this:

Arm = require("MOARArmsAPI")

then, in the script, define the arms using Arm:newArm(id, side, item pivot, arm model, held slot, anim options, custom animations)

Each pair of arms must have a different ID, with the 2 arms in each pair sharing ID values
the side is either "LEFT" or "RIGHT", depending on which side the arm is on
item pivot is the part where the item is rendered, just like Left/RightItemPivot parent types.
arm model is the root model of the arm itself
the held slot is what this arm will hold. If set to "MAINHAND" or "OFFHAND", the arm will generally hold whatever is in your main or off hand.
the held slot can also be set to a number from 0-8, corresponding to the hotbar slots. The arm will hold whatever item is in that hotbar slot, and when the slot is selected, the mainhand arm will remain holding what it was and this arm will swing when using that item. This allows your avatar to use all their arms.
anim options is a table with options for what API anims to use, with keys "IDLE","HOLD","CROUCH","RIDE","WALK","SWING","ATTACK","USE","DROP","OVERRIDE","OVERRIDE_AIM"
anim option values can be 0,1,2. 0 = off, 1 = off if no higher custom anim playing, 2 = always on
omitted values default to 1 if there's a arm model, 0 otherwise.
custom anims are set up like anim options, but the values instead are the animation to play for that key.

e.g. 1, a simple 4 armed character:

Arm:newArm(1, "RIGHT", models.model.Body.RightArm.RightItem, models.model.Body.RightArm, "MAINHAND")
Arm:newArm(1, "LEFT", models.model.Body.LeftArm.LeftItem, models.model.Body.LeftArm, "OFFHAND")
Arm:newArm(2, "RIGHT", models.model.Body.RightArm2.RightItem2, models.model.Body.RightArm2, 0)
Arm:newArm(2, "LEFT", models.model.Body.LeftArm2.LeftItem2, models.model.Body.LeftArm2, 1)

e.g. 2, a character that uses their tail alongside their hands, with only an attack animation

Arm:newArm(1, "RIGHT", models.model.Body.RightArm.RightItem, models.model.Body.RightArm, "MAINHAND")
Arm:newArm(1, "LEFT", models.model.Body.LeftArm.LeftItem, models.model.Body.LeftArm, "OFFHAND")
Arm:newArm(2, "RIGHT", models.model.Body.Tail1.Tail2.Tail3.TailItem, nil, 0, {}, {SWING=animations.model.tailAttack}})


Arms can also be saved to a variable, allowing access to some of its values, such as the RenderTask for the item, or whether it is currently attacking.
There are some functions that can be used to manipulate the arms.
Messing with the variables will likely cause problems

ExtraArm = Arm:newArm(2, "RIGHT", models.model.SecondRightArm.SecondRightItem, models.model.SecondRightArm, 1)




]]
--configurable vars. Generally alternative code for if another mod or something breaks the script

--false: uses maths to calculate arm swinging from walking. My math isn't perfect.
--true: uses the vanilla model's leg rotation to calculate arm swinging from walking. Looks better, but will break if something messes with vanilla model legs
local useLegRotForArmAnim = true





local isLeftHanded = false
events.ENTITY_INIT:register(function ()
    if player:isLeftHanded() then
        isLeftHanded = true
    end
end)



---@class Arm
---@field ID integer
---@field LeftRight ArmType
---@field Model ModelPart
---@field ItemModel ModelPart
---@field ItemChoice ItemChoice
---@field AnimOptions table
---@field CustomAnims table
---@field isSwinging boolean --true if arm is swinging
---@field SwingTime number --used for swing anim
---@field SwingType "ATTACK"|"USE"|"DROP" --type of swing. Mainly for custom anims.
---@field ItemSlot integer
---@field Item string
---@field ItemRender ItemTask
---@field newArm function
---@field changeItem function
---@field setAnimActive function
---@field setItemActive function
---@field setActive function
local Arm = {}

local Arms = {}

--vars
--math functions
local sin = math.sin 
local sqrt = math.sqrt
local pi = math.pi
--keys
local AtkKey = keybinds:fromVanilla("key.attack")
local UseKey = keybinds:fromVanilla("key.use")
local AtkTicker = 0
local UseTicker = 0
--calculating players horizontal velocity
local Velocity = 0 

local Pos = vec(0,0,0)
local OldPos = vec(0,0,0)


--other vars
local Adjdistance = 0
local MainhandSlot = 0
local UsedSlots = {}
local isSneaking = false
local Rot
local MainHandArmSlot = -1 --current held item slot for mainhand arm



---@alias ArmType
---| "LEFT"
---| "RIGHT"


---@alias ItemChoice
---| "MAINHAND"
---| "OFFHAND"
---| integer


---Declare an Arm
---@param id integer ID of arm. Cannot match another arm on same side. Indicates which other arm is used for 2 handed animations
---@param left_right ArmType Whether arm is left or right
---@param itemPivot ModelPart ModelPart of the Held Item
---@param armModel ModelPart | nil ModelPart of the arm itself. Will remove vanilla RightArm and LeftArm parenting from the part if present, to replace with custom anims. nil value means no rotations applied (e.g fully custom anims)
---@param itemChoice ItemChoice Item to prioritise. "MAINHAND" and "OFFHAND" for vanilla hands, or a number representing a hotbar slot. (0 is leftmost slot, 8 for rightmost)
---@param animOptions Table Table containing info on which API anims to use. each anim is a key: IDLE,WALK,SWING,ATTACK,USE,DROP,OVERRIDE,OVERRIDE_AIM. Value determines whether to use anim: 0 - anim off, 1 - anim off if custom anim playing, 2 - anim always on, even if custom anims are playing
---@param customAnims Table Table containing all custom anims. Key determines when to play anim, with same keys as animOptions. All valid anims play at once, use Figura's setPriority() to make some override others when they play.
function Arm:newArm(id, left_right, itemPivot, armModel, itemChoice, animOptions, customAnims)
    --setup arm vars
    local arm = {ID=id, LeftRight = left_right, ItemPivot = itemPivot, Model = armModel, ItemChoice = itemChoice, AnimOptions = animOptions, CustomAnims = customAnims, IsAnimActive = true, IsItemActive = true}
    local animOptionlist = {"IDLE","WALK","SWING","OVERRIDE","HOLD","CROUCH","RIDE"}
    local hasModel
    if armModel then hasModel = 1 else hasModel = 0 end

    if not arm.AnimOptions then arm.AnimOptions = {} end
    for _, value in ipairs(animOptionlist) do --fill in required data in AnimOptions
        if not arm.AnimOptions[value] then arm.AnimOptions[value] = hasModel end
    end
    if not arm.CustomAnims then arm.CustomAnims = {} end
    if type(itemChoice) == "number" then
        arm.ItemSlot = itemChoice
        table.insert(UsedSlots, itemChoice)
    end
    arm.SwingTime = 0
    arm.Item = "minecraft:air"
    
    table.insert(Arms, arm)

    --stop arm parenting to vanilla, if it is
    if armModel and (armModel:getParentType() == "LeftArm" or armModel:getParentType() == "RightArm") then
        armModel:setParentType("None")
    end

    --Item RenderTask
    arm.ItemRender = arm.ItemPivot:newItem("HandItem")
    arm.ItemRender:setRot(-90,0, 180)
    if left_right == "LEFT" then
        arm.ItemRender:setDisplayMode("THIRD_PERSON_LEFT_HAND")
    elseif left_right == "RIGHT" then
        arm.ItemRender:setDisplayMode("THIRD_PERSON_RIGHT_HAND")
    end

    setmetatable(arm, self)
    self.__index = self
    return arm
end

---Set whether Arm should animate
---@param state boolean
function Arm:setAnimActive(state)
    self.IsAnimActive = state
    if (not state) and self.Model then --reset rot if turning off
        self.Model:offsetRot()
    end
end

---Set whether Arm's held item should update. the RenderTask's item can be manipulated by your own script while this is inactive.
---@param state boolean
function Arm:setItemActive(state)
    self.IsItemActive = state
    if not state then
        self.Item = "minecraft:air"
        self.ItemRender:item("minecraft:air")
    end
end

---Combines setItemActive and setAnimActive, to enable/disable entire arm
---@param state boolean
function Arm:setActive(state)
    self:setAnimActive(state)
    self:setItemActive(state)
end



---Change Held Item of an Arm
---@param item ItemChoice
function Arm:changeItem(item)
    if type(self.ItemChoice) == "number" then
        for index, value in ipairs(UsedSlots) do --if changing from a slot, remove from UsedSlots list
            if value == self.ItemSlot then
                table.remove(UsedSlots, index)
                break
            end
        end
        for _, arm in ipairs(Arms) do --swap with mainhand, if needed
            if arm.ItemChoice == "MAINHAND" and item == arm.ItemSlot then

                arm.ItemSlot = self.ItemChoice
            end
        end

    end
    if type(item) == "number" then

        self.ItemSlot = item
        table.insert(UsedSlots, item)
    elseif item == "MAINHAND" then
        self.ItemSlot = MainHandArmSlot
    else
        self.ItemSlot = nil
    end
    self.ItemChoice = item
end


vanilla_model.HELD_ITEMS:setVisible(false)


events.ENTITY_INIT:register(function ()
    Pos = player:getPos() 
    OldPos = player:getPos()
end)


--Auto update for players first loading avatar

function pings.getArmData()
    if host:isHost() then
        
        for id, arm in pairs(Arms) do
            pings.updateArm(id, arm.Item)
        end
    end

end

local list = {}
local send_update_ping = true
local update_ping = function() pings.getArmData() end
events.TICK:register(function()
    if host:isHost() then
        
        for player_name in pairs(world.getPlayers()) do
            if not list[player_name] then
              send_update_ping = true
            end
            list[player_name] = 2
          end
          for i, v in pairs(list) do
            list[i] = v - 1
            if v < 0 then list[i] = nil end
          end
          if send_update_ping  and (world.getTime()) % 4 == 0 then
            send_update_ping = false
            update_ping()
          end
    end
  
end)






--Item Overrides. Items in here will cause arms to use vanilla rotation instead of scripted rotation. Used for things like bows, crossbows, and tridents.
--Use this when an item is held/used differently than most, visually.
--Use overrides are active when the respective item is being used
--Hold overrides are used when the item is held in an active vanilla slot, and there is no active Use override.
--Mainhand takes priority
--If using mods, insert any modded items that need it in here, e.g modded guns and bows, space mod rockets.
--an item is 'aimed' if, when holding/using it, the player points it in the direction you are looking. Bows are aimed, shields are not.
local ItemOverrides = {
    OneHandHold = {--Vanilla rot when held, for arm holding item

    },
    TwoHandHold = {--Vanilla rot when held, for arm holding item and matching opposite arm

    },
    OneHandUse = {--Vanilla rot when being used, for arm holding item
        {id = "minecraft:trident"},
        {id = "minecraft:shield"},
    },
    TwoHandUse = {--Vanilla rot when being used, for arm holding item and matching opposite arm
        {id = "minecraft:crossbow"},
        --modded
        {id = "rosia:purple_steel_rifle"},
    },

    --If item is aimed, like bows, cbows, guns, as well as things like spyglasses and goat horns, put in here.

    OneHandHoldAimed = {--Vanilla rot when held, for arm holding item

    },
    TwoHandHoldAimed = {--Vanilla rot when held, for arm holding item and matching opposite arm
        {id = "minecraft:crossbow", tag = {Charged = 1}},
        --modded
        {id = "create:potato_cannon"},
        {id = "create:handheld_worldshaper"},
        {id = "rosia:purple_steel_rifle", tag = {Charged = 1}}
    },
    OneHandUseAimed = {--Vanilla rot when being used, for arm holding item
        {id = "minecraft:goat_horn"},
        {id = "minecraft:spyglass"}
    },
    TwoHandUseAimed = {--Vanilla rot when being used, for arm holding item and matching opposite arm
        {id = "minecraft:bow"},
        --modded
        {id = "waystones:warp_stone"},
        {id = "waystones:warp_scroll"},
        {id = "waystones:return_scroll"},
        {id = "waystones:bound_scroll"},
    }
}
local OverrideNum = 0 --which pair of arms to override
local OverrideVal = "NONE" --which arms in the pair to override. can be "NONE","MAINHAND","OFFHAND","BOTH"
local OverrideisAimed = false --whether animation is 'aimed'
local OverrideisInverted = false --whether to invert the anim (item is in vanilla right hand but in model's left hand and vice versa)
local OverrideItem --the item being held/used to trigger the override. Uses the actual held item, not the stripped item used for rendering or the item in the override table. Is nil if no override or override isn't item-related. (swimming) (usage TBA)
local function compareItem(check, item) -- checks whether table 'item' contains everything in table 'check'. use the value "ANY" to indicate that the value can be any non-nil value
    for k, v in pairs(check) do
        if type(v) ~= 'table' then --item in 'check' isnt a table

            if (v ~= item[k]) and not (v == "ANY" and item[k] ~= nil) then
                return false
            end
        elseif type(item[k]) ~= 'table' then --'check' has table, 'item' doesnt
            return false
        else
            if not compareItem(v, item[k]) then return false end --recursive call on the table within table
        end
    end
    return true --if no mismatch found, true.
end
local function getOverride()
    OverrideItem = nil
    OverrideisAimed = false
    OverrideisInverted = player:isLeftHanded()
    if player:getPose() == "SWIMMING" then
        OverrideVal = "ALL"
        OverrideNum = -1
        return
    end
    local MainhandItem = player:getHeldItem()
    local OffhandItem = player:getHeldItem(true)
    local ActiveItem = player:getActiveItem()
    for _, item in ipairs(ItemOverrides.TwoHandUse) do
        if compareItem(item, ActiveItem) then --active item needs override
            OverrideItem = ActiveItem
            OverrideVal = "BOTH"
            if ActiveItem == MainhandItem then
                for _, arm in ipairs(Arms) do
                    if arm.ItemSlot == MainhandSlot then
                        if arm.LeftRight == "LEFT" then
                            OverrideisInverted = not OverrideisInverted
                        end
                        OverrideNum = arm.ID
                        return
                    end
                end
            else
                for _, arm in ipairs(Arms) do
                    if arm.ItemChoice == "OFFHAND" then
                        if arm.LeftRight == "RIGHT" then
                            OverrideisInverted = not OverrideisInverted
                        end
                        OverrideNum = arm.ID
                        return
                    end
                end
            end
        end
    end
    for _, item in ipairs(ItemOverrides.OneHandUse) do
        if compareItem(item, ActiveItem) then --active item needs override
            OverrideItem = ActiveItem
            if ActiveItem == MainhandItem then
                OverrideVal = "MAINHAND"
                for _, arm in ipairs(Arms) do
                    if arm.ItemSlot == MainhandSlot then
                        if arm.LeftRight == "LEFT" then
                            OverrideisInverted = not OverrideisInverted
                        end
                        OverrideNum = arm.ID
                        return
                    end
                end
            else
                OverrideVal = "OFFHAND"
                for _, arm in ipairs(Arms) do
                    if arm.ItemChoice == "OFFHAND" then
                        if arm.LeftRight == "RIGHT" then
                            OverrideisInverted = not OverrideisInverted
                        end
                        OverrideNum = arm.ID
                        return
                    end
                end
            end
        end
    end
    for _, item in ipairs(ItemOverrides.TwoHandHold) do
        if compareItem(item, MainhandItem) then --held item needs override
            OverrideItem = MainhandItem
            OverrideVal = "BOTH"
            for _, arm in ipairs(Arms) do
                if arm.ItemSlot == MainhandSlot then
                    if arm.LeftRight == "LEFT" then
                        OverrideisInverted = not OverrideisInverted
                    end
                    OverrideNum = arm.ID
                    return
                end
            end
        elseif compareItem(item, OffhandItem) then
            OverrideItem = OffhandItem
            OverrideVal = "BOTH"
            for _, arm in ipairs(Arms) do
                if arm.ItemChoice == "OFFHAND" then
                    if arm.LeftRight == "RIGHT" then
                        OverrideisInverted = not OverrideisInverted
                    end
                    OverrideNum = arm.ID
                    return
                end
            end
        end
    end
    for _, item in ipairs(ItemOverrides.OneHandHold) do
        if compareItem(item, MainhandItem) then --held item needs override
            OverrideItem = MainhandItem
            OverrideVal = "MAINHAND"
            for _, arm in ipairs(Arms) do
                if arm.ItemSlot == MainhandSlot then
                    if arm.LeftRight == "LEFT" then
                        OverrideisInverted = not OverrideisInverted
                    end
                    OverrideNum = arm.ID
                    return
                end
            end
        elseif compareItem(item, OffhandItem) then
            OverrideItem = OffhandItem
            OverrideVal = "OFFHAND"
            for _, arm in ipairs(Arms) do
                if arm.ItemChoice == "OFFHAND" then
                    if arm.LeftRight == "RIGHT" then
                        OverrideisInverted = not OverrideisInverted
                    end
                    OverrideNum = arm.ID
                    return
                end
            end
        end
    end
    OverrideisAimed = true --if a check below passes, item is aimed
    for _, item in ipairs(ItemOverrides.TwoHandUseAimed) do
        if compareItem(item, ActiveItem) then --active item needs override
            OverrideItem = ActiveItem
            OverrideVal = "BOTH"
            if ActiveItem == MainhandItem then
                for _, arm in ipairs(Arms) do
                    if arm.ItemSlot == MainhandSlot then
                        if arm.LeftRight == "LEFT" then
                            OverrideisInverted = not OverrideisInverted
                        end
                        OverrideNum = arm.ID
                        return
                    end
                end
            else
                for _, arm in ipairs(Arms) do
                    if arm.ItemChoice == "OFFHAND" then
                        if arm.LeftRight == "RIGHT" then
                            OverrideisInverted = not OverrideisInverted
                        end
                        OverrideNum = arm.ID
                        return
                    end
                end
            end
        end
    end
    for _, item in ipairs(ItemOverrides.OneHandUseAimed) do
        if compareItem(item, ActiveItem) then --active item needs override
            OverrideItem = ActiveItem
            if ActiveItem == MainhandItem then
                OverrideVal = "MAINHAND"
                for _, arm in ipairs(Arms) do
                    if arm.ItemSlot == MainhandSlot then
                        if arm.LeftRight == "LEFT" then
                            OverrideisInverted = not OverrideisInverted
                        end
                        OverrideNum = arm.ID
                        return
                    end
                end
            else
                OverrideVal = "OFFHAND"
                for _, arm in ipairs(Arms) do
                    if arm.ItemChoice == "OFFHAND" then
                        if arm.LeftRight == "RIGHT" then
                            OverrideisInverted = not OverrideisInverted
                        end
                        OverrideNum = arm.ID
                        return
                    end
                end
            end
        end
    end
    for _, item in ipairs(ItemOverrides.TwoHandHoldAimed) do
        if compareItem(item, MainhandItem) then --held item needs override
            OverrideItem = MainhandItem
            OverrideVal = "BOTH"
            for _, arm in ipairs(Arms) do
                if arm.ItemSlot == MainhandSlot then
                    if arm.LeftRight == "LEFT" then
                        OverrideisInverted = not OverrideisInverted
                    end
                    OverrideNum = arm.ID
                    return
                end
            end
        elseif compareItem(item, OffhandItem) then
            OverrideItem = OffhandItem
            OverrideVal = "BOTH"
            for _, arm in ipairs(Arms) do
                if arm.ItemChoice == "OFFHAND" then
                    if arm.LeftRight == "RIGHT" then
                        OverrideisInverted = not OverrideisInverted
                    end
                    OverrideNum = arm.ID
                    return
                end
            end
        end
    end
    for _, item in ipairs(ItemOverrides.OneHandHoldAimed) do
        if compareItem(item, MainhandItem) then --held item needs override
            OverrideItem = MainhandItem
            OverrideVal = "MAINHAND"
            for _, arm in ipairs(Arms) do
                if arm.ItemSlot == MainhandSlot then
                    if arm.LeftRight == "LEFT" then
                        OverrideisInverted = not OverrideisInverted
                    end
                    OverrideNum = arm.ID
                    return
                end
            end
        elseif compareItem(item, OffhandItem) then
            OverrideItem = OffhandItem
            OverrideVal = "OFFHAND"
            for _, arm in ipairs(Arms) do
                if arm.ItemChoice == "OFFHAND" then
                    if arm.LeftRight == "RIGHT" then
                        OverrideisInverted = not OverrideisInverted
                    end
                    OverrideNum = arm.ID
                    return
                end
            end
        end
    end
    OverrideisAimed = false
    OverrideVal = "NONE"
    OverrideNum = 0
end


-- Strip back excessive item NBT. Don't wanna try to ping stuff like the entire contents of a shulker box
-- "ANY" means any data there is kept. Any other value will override the value on the item, if it has an existing value
-- this is likely very incomplete
-- Most modded items that have a different appearance based on NBT would likely need said NBT added in here to show properly. Some things, like chiseled blocks with chisel mods, likely won't work at all even if listed due to ping size limits
--some modded things might hit ping size limits with these settings, like if an item contains ALL of a contained mob's NBT.
--This is also used on the host's end for displaying held items. What you see is what others see.
--note to self: clean up the stripper code
local NBTWhitelist = {
    --universal
    CustomModelData = "ANY",
    Display = "ANY",

    --tools
    Enchantments = {
        "ANY" --only ping first ench, should allow texture packs that differentiate between ench. books to work
    },
    Damage = "ANY",

    --head
    SkullOwner = "ANY",

    --crossbow
    Charged = "ANY",
    ChargedProjectiles = {
        {
            id = "ANY",
            Count = "ANY",
        }
    },

    --potions
    Potion = "ANY",
    CustomPotionColor = "ANY",

    
    --block entity stuff. (be careful when adding modded stuff here, often contains huuge data like full entity NBT data or storage block contents)
    BlockEntityTag = {
        Patterns = "ANY"
    }

    --modded

}


local function _stripItem(check, item, output)
    for k, v in pairs(check) do
        if type(v) ~= 'table' then --item in 'check' isnt a table
            if item[k] ~= nil then
                if v == "ANY" then
                    output[k] = item[k]
                end
            end

        elseif type(item[k]) ~= 'table' then --'check' has table, 'item' doesnt
            --item[k] = nil
        else
            output[k] = {}
            _stripItem(v, item[k], output[k]) --recursive call on the table within table
        end
    end
    
end

local next = next
local function tagToStackString(tag, output) --converts a tag value to a string. Like the ItemStack function, but for any table. 
    local comma = false
    if next(tag) == nil then --empty list
        output[1] = output[1] .. "[]"
    elseif tag[1] then --is a list
        --output[2] = false
        output[1] = output[1] .. "["
        for k, v in ipairs(tag) do
            if comma then
                output[1] = output[1] .. ","
            end
            comma = true
            if type(v) == "table" then
                if next(v) == nil then
                    output[1] = output[1] .. "{}"
                else
                    tagToStackString(v, output)
                end
            elseif type(v) == "string" then
                output[1] = output[1] .. "'"
                output[1] = output[1] .. v
                output[1] = output[1] .. "'"
            else
                output[1] = output[1] .. v
            end
        end
        output[1] = output[1] .. "]"
    else
        
        output[1] = output[1] .. "{"
        for k, v in pairs(tag) do
            if comma then
                output[1] = output[1] .. ","
            end
            comma = true
            output[1] = output[1] .. k
            output[1] = output[1] .. ":"
            if type(v) == "table" then
                tagToStackString(v, output)
            elseif type(v) == "string" then
                output[1] = output[1] .. "'"
                output[1] = output[1] .. v
                output[1] = output[1] .. "'"
            else
                output[1] = output[1] .. v
            end
        end
        output[1] = output[1] .. "}"
    end
    
end

local function stripItem(item) -- strip all nbt from "item" that isn't included in "check"
    if item.id == "minecraft:air" then return "minecraft:air" end --ghost NBT fix
    if next(item.tag) == nil then return item:toStackString() end --item has no tags, no need to strip what doesn't exist 
    output = {}
    _stripItem(NBTWhitelist, item.tag, output)
    local stackString = {item:getID(), false} --(Why is an ItemStack's tag read-only? WHYYYYYY) (also this code is jank, and might contain unneeded leftovers from previous attempts at it)
    tagToStackString(output, stackString)
    return stackString[1]
end



function pings.updateArm(armID, item) --getting items from specific slots is Host only, so ping it.
    local arm = Arms[armID]
    arm.Item = item
    arm.ItemRender:item(item)
end
function pings.mainHandSlot(slot)
    MainhandSlot = slot
end

function table.contains(table, element) --func for checking if an item is in a table
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end

events.TICK:register(function()

    
    
    

    --calculate velocity, use it for arm swinging anim
    if not useLegRotForArmAnim then
        OldPos = Pos
        Pos = player:getPos()
        Velocity = sqrt((Pos.x-OldPos.x)^2+(Pos.z-OldPos.z)^2)
        Adjdistance = Adjdistance + math.min(Velocity*16.8,4.2) --originally tried all kinds of math for this, before discovering that it's a piecewise linear. XD
    end
    

    --Main hand arm item. Item doesn't change when selecting a slot held in another arm
    if host:isHost() then 
        if MainhandSlot ~= player:getNbt().SelectedItemSlot then
            pings.mainHandSlot(player:getNbt().SelectedItemSlot)
        end
    end

    if not table.contains(UsedSlots, MainhandSlot) then
        MainHandArmSlot = MainhandSlot
        for _, arm in ipairs(Arms) do
            if arm.ItemChoice == "MAINHAND" then
                arm.ItemSlot = MainhandSlot
            end
        end
    end

    

    --Attack/Use keypress detection
    if AtkKey:isPressed() then
        AtkTicker = 3
        UseTicker = 0
    elseif AtkTicker > 0 then
        AtkTicker = AtkTicker - 1
    end
    if UseKey:isPressed() then
        UseTicker = 3
        AtkTicker = 0
    elseif UseTicker > 0 then
        UseTicker = UseTicker - 1
    end

    
    --Arm atk/use swing anim, and update held item model
    for k, arm in pairs(Arms) do 
        if arm.isSwinging then --Attack anim ticker
            if arm.SwingTime < 1 and OverrideVal ~= "NONE" then
                arm.isSwinging = false
                arm.SwingTime = 0
            else
                arm.SwingTime = arm.SwingTime + 1
                if arm.SwingTime == 6 then
                    arm.SwingTime = 0
                    arm.isSwinging = false
                end 
            end  
        end
        if arm.IsItemActive then
            if host:isHost() and arm.ItemChoice ~= "OFFHAND" then
                local item
                if arm.ItemSlot then
                    item = stripItem(host:getSlot(arm.ItemSlot))
                else    
                    item = "minecraft:air"
                end
                if arm.Item ~= item then
                    pings.updateArm(k, item)
    
                end
            end
            if arm.ItemChoice == "OFFHAND" then
                arm.Item = stripItem(player:getHeldItem(true))
                 arm.ItemRender:item(arm.Item)
            end
        end
        
        
    end


    
end)



events.RENDER:register(function(delta, mode)

    --Arm overrides
    getOverride()
    
    --first person stuff
    if mode == "FIRST_PERSON" then
        vanilla_model.HELD_ITEMS:setVisible(true)
    else

        vanilla_model.HELD_ITEMS:setVisible(false)
    end

    --first person stuff, arm-specific
    for _, arm in pairs(Arms) do
        if (arm.ItemChoice == "MAINHAND" or arm.ItemChoice == "OFFHAND") and arm.Model then
            if mode == "FIRST_PERSON" then
                
                if arm.LeftRight == "LEFT" then
                    arm.Model:setParentType("LeftArm")
                else
                    arm.Model:setParentType("RightArm")
                    
                end
                arm.ItemRender:setVisible(false)
            else
                
                arm.Model:setParentType("None")
                arm.ItemRender:setVisible(true)
                
            end
        end
    end
    



    isSneaking = vanilla_model.BODY:getOriginRot().x ~= 0


    --Arm swinging from walking
    local walkRot
    if useLegRotForArmAnim then
        walkRot = vanilla_model.RIGHT_LEG:getOriginRot().x*0.7

    else
        walkRot = (sin((Adjdistance+math.min(Velocity*16.8,4.2)*delta)/(2*pi)) * math.min(Velocity*3,1)) * 57.3
    end
    
    --Idle swinging
    local idleRotX = (sin(math.rad(world.getTime(delta)*18/5))*3)
    local idleRotZ = (sin(math.rad(world.getTime(delta)*18/4))*3+3)
    --mixed vars
    local isMounted = player:getVehicle() ~= nil
    local RightArmOriginRot = vanilla_model.RIGHT_ARM:getOriginRot()
    local LeftArmOriginRot = vanilla_model.LEFT_ARM:getOriginRot()
    local MainHandOriginRot
    local OffHandOriginRot
    if isLeftHanded then
        MainHandOriginRot = LeftArmOriginRot
        OffHandOriginRot = RightArmOriginRot
    else
        OffHandOriginRot = LeftArmOriginRot
        MainHandOriginRot = RightArmOriginRot
    end
    local isWalking = player:getVelocity().xz:length() > .01


    for _, arm in pairs(Arms) do
        
        
        if OverrideVal == "ALL" then --override all arms
            arm.isOverridden = true
        elseif OverrideNum == arm.ID then

            if OverrideVal == "BOTH" then
                arm.isOverridden = true
            elseif OverrideVal == "MAINHAND" and arm.ItemSlot == MainhandSlot then
                arm.isOverridden = true
            elseif OverrideVal == "OFFHAND" and arm.ItemChoice == "OFFHAND" then
                arm.isOverridden = true
            end
        end

        local ActiveAnims = {} --animations playing for this arm
        if arm.isOverridden then
            if OverrideisAimed then
                table.insert(ActiveAnims, "OVERRIDE_AIM")
            end
            table.insert(ActiveAnims, "OVERRIDE")
        else
            table.insert(ActiveAnims, "IDLE")
            if arm.Item ~= "minecraft:air" then --holding item
                table.insert(ActiveAnims, "HOLD")
            end
            
            if isSneaking then
                table.insert(ActiveAnims, "CROUCH")
            end
            if isMounted then
                table.insert(ActiveAnims, "RIDE")
            end
            

            if arm.isSwinging then
                table.insert(ActiveAnims, "SWING")
                table.insert(ActiveAnims, arm.SwingType)
            end
            if arm.ItemSlot == MainhandSlot and OverrideVal ~= "BOTH" and not arm.isSwinging then --Detect arm atk/use swinging
                
                if 12 < MainHandOriginRot.y or MainHandOriginRot.y < -12 then
                    arm.isSwinging = true
                    table.insert(ActiveAnims, "SWING")
                    if AtkTicker > 0 then arm.SwingType = "ATTACK"
                    elseif UseTicker > 0 then arm.SwingType = "USE"
                    else arm.SwingType = "DROP" end
                    table.insert(ActiveAnims, arm.SwingType)
                end
            end

            if arm.ItemChoice == "OFFHAND" and OverrideVal ~= "BOTH" and not arm.isSwinging then
                if 12 < OffHandOriginRot.y or OffHandOriginRot.y < -12 then
                    arm.isSwinging = true
                    table.insert(ActiveAnims, "SWING")
                    if AtkTicker > 0 then arm.SwingType = "ATTACK"
                    elseif UseTicker > 0 then arm.SwingType = "USE"
                    else arm.SwingType = "DROP" end
                    table.insert(ActiveAnims, arm.SwingType)
                end
            end

            if isWalking then table.insert(ActiveAnims, "WALK") end
        end
        if arm.IsAnimActive then
            local suppressedAnims = {} --API anims to disable, if set to be overridden by custom anims
            local suppressedTier = 0 --used to calc. above
            for key, anim in pairs(arm.CustomAnims) do --play all custom anims
                local playAnim = table.contains(ActiveAnims, key)
                anim:setPlaying(playAnim)
                if playAnim then
                    --nothing for override here as it always disables lower
                    if (key == "ATTACK" or key == "USE" or key == "DROP" or key == "SWING") and suppressedTier < 2 then --swings disable idle/walk
                        suppressedTier = 2
                    elseif key == "WALK" and suppressedTier < 1 then --walk disables idle
                        suppressedTier = 1
                    end
                end
                
            end
            if suppressedTier > 0 then
                suppressedAnims = {"IDLE","HOLD"}
            end
            if suppressedTier > 1 then
                table.insert(suppressedAnims, "WALK")
            end
            local function useVanilla(anim) --should this API (vanilla recreation) anim be used
                if table.contains(ActiveAnims, anim) then
                    if arm.AnimOptions[anim] == 1 and table.contains(suppressedAnims, anim) then
                        return false
                    else return arm.AnimOptions[anim] ~= 0 end
                end
                return false
            end
            --log(arm.AnimOptions.IDLE ~= 0)
            --log(useVanilla("IDLE"))
            --log(suppressedAnims)
            --log("")
            if arm.Model then
                local ArmRot = vec(0,0,0)
                local VanillaRot = {0,0}
                if useVanilla("OVERRIDE") then --using vanilla rots

                    if arm.LeftRight == "LEFT" then
                        if OverrideisInverted then
                            VanillaRot = RightArmOriginRot
                            VanillaRot.y = -VanillaRot.y
                            if OverrideisAimed then
                                VanillaRot.y = VanillaRot.y + 2 * vanilla_model.HEAD:getOriginRot().y
                            end
                        else
                            VanillaRot = LeftArmOriginRot
                        end
                    else
                        if OverrideisInverted then
                            VanillaRot = LeftArmOriginRot
                            VanillaRot.y = -VanillaRot.y
                            if OverrideisAimed then
                                VanillaRot.y = VanillaRot.y + 2 * vanilla_model.HEAD:getOriginRot().y
                            end
                        else
                            VanillaRot = RightArmOriginRot
                        end
                    end

                    
        
        
                    ArmRot = VanillaRot
                    if isSneaking then --sneaking
                        if arm.Model:getParent():getParentType() == "Body" then --if part is parented to the model's body/torso
                            ArmRot:add(50)
                        end
                    end
                else

                    if useVanilla("SWING") then --Detect arm atk/use swinging
                        arm.isSwinging = true
                        if arm.LeftRight == "RIGHT" then
                            ArmRot:add(sin((arm.SwingTime+delta)/6*pi)*80, -sin((arm.SwingTime+delta)/3*pi)*20+10, 0)
                        else
                            ArmRot:add(sin((arm.SwingTime+delta)/6*pi)*80, sin((arm.SwingTime+delta)/3*pi)*20-10, 0)
                        end
                    end
                    if useVanilla("WALK") and not isMounted then
                        if arm.ID % 2 == 0 then Rot = -walkRot else Rot = walkRot end --walking
                        if arm.Item ~= "minecraft:air" then Rot = Rot * 0.6 end --arms dont swing as far if they're holding an item.
                        if arm.LeftRight == "RIGHT" then
                            ArmRot:add(-Rot)
                        else
                            ArmRot:add(Rot)
                        end
        
                        
                    end
                    if useVanilla("IDLE") then
                        
                        
                        if arm.ID % 2 == 0 then Rot = -idleRotX else Rot = idleRotX end --Idling
                        if arm.LeftRight == "RIGHT" then
                            ArmRot:add(-Rot,0,idleRotZ)
                        else
                            ArmRot:add(Rot,0,-idleRotZ)
                        end
                        
                    end
                    if useVanilla("SNEAK") then
                        if isSneaking then --sneaking
                            if arm.Model:getParent():getParentType() == "Body" then --if part is parented to the model's body/torso
                                ArmRot:add(5)
                            else
                                ArmRot:add(-20)
                            end
                        end
                    end
                    if useVanilla("HOLD") then
                        ArmRot:add(20,0,0)

                    end
                    if useVanilla("RIDE") then
                        if isMounted then --riding
                            ArmRot:add(40)
                        end
                    end
                    
                end

                arm.Model:offsetRot(ArmRot)

            end
        end
        

        arm.isOverridden = false
    end
end)




return Arm, Arms