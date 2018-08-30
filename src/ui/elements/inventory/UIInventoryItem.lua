---
-- @module UIInventoryItem
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UILabel = require( 'src.ui.elements.UILabel' )
local Translator = require( 'src.util.Translator' )
local ItemStack = require( 'src.inventory.ItemStack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIInventoryItem = UIElement:subclass( 'UIInventoryItem' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function updateBackground( self )
    if self:isMouseOver() then
        self.background:setColor( 'ui_equipment_mouseover' )
    else
        self.background:setColor( 'sys_background' )
    end
end

local function createInfo( self )
    local count = 1
    if self.item:isInstanceOf( ItemStack ) and self.item:getItemCount() > 1 then
        count = self.item:getItemCount()
    end
    self.amount = UILabel( self.ax, self.ay, 0, 0, self.w, 1, count, 'ui_equipment_item', 'right' )
    self:addChild( self.amount )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIInventoryItem:initialize( ox, oy, rx, ry, w, h, item )
    UIElement.initialize( self, ox, oy, rx, ry, w, h )

    self.item = item

    self.background = UIBackground( self.ax, self.ay, 0, 0, self.w, self.h )
    self:addChild( self.background )

    self.label = UILabel( self.ax, self.ay, 0, 0, self.w, 1, Translator.getText( self.item:getID() ), 'ui_equipment_item' )
    self:addChild( self.label )

    createInfo( self )
end

function UIInventoryItem:draw()
    updateBackground( self )
    self.background:draw()

    self.label:draw()
    self.amount:draw()
end

function UIInventoryItem:drag( rmb, fullstack )
    if self.item:isInstanceOf( ItemStack ) and rmb then
        if self.item:getItemCount() == 1 then
            return self.item
        else
            return self.item:split()
        end
    elseif self.item:isInstanceOf( ItemStack ) and not fullstack then
        return self.item:getItem()
    end
    return self.item
end

function UIInventoryItem:getItem()
    return self.item
end

function UIInventoryItem:hasItem()
    return self.item ~= nil
end

return UIInventoryItem
