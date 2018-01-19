---
-- @module UITileInfo
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local GridHelper = require( 'src.util.GridHelper' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UITileInfo = UIElement:subclass( 'UITileInfo' )
-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH = 16
local UI_GRID_HEIGHT = 8

local MAX_ITEMS_DISPLAYED = 5

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Adds colored text to the text object and returns the width of the added item.
-- @tparam Text   textObject The Text object to modify.
-- @tparam table  colorTable The table to use for adding colored text.
-- @tparam number y          The position at which to add the text along the x-axis.
-- @tparam number x          The position at which to add the text along the y-axis.
-- @tparam table  color      A table containing RGBA values.
-- @tparam string text       The text string to add.
-- @treturn number The width of the added text item.
--
local function addToTextObject( textObject, colorTable, x, y, color, text )
    colorTable[1], colorTable[2] = color, text
    textObject:add( colorTable, x, y )
    return textObject:getDimensions()
end

---
-- Draws some information of the tile the mouse is currently hovering over.
-- @tparam Text   textObject The Text object to modify.
-- @tparam table  colorTable The table to use for adding colored text.
-- @tparam Tile   tile       The tile object to inspect.
--
local function inspectTile( textObject, colorTable, tile )
    local x, y = 0, 0
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), Translator.getText( tile:getID() ))
    y = y + textObject:getHeight()

    if tile:isPassable() then
        addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_success' ), Translator.getText( 'ui_tile_info_passable' ))
    else
        addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_error' ), Translator.getText( 'ui_tile_info_impassable' ))
    end
    y = y + textObject:getHeight() + textObject:getHeight()

    local items = tile:getInventory():getItems()
    for i, item in ipairs( tile:getInventory():getItems() ) do
        if i > MAX_ITEMS_DISPLAYED then
            addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), string.format( Translator.getText( 'ui_tile_info_moreitems' ), #items - MAX_ITEMS_DISPLAYED ))
            break
        end

        addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( item:getID() ))
        y = y + textObject:getHeight()
    end
end

---
-- Draws some information about the world object contained on a certain tile.
-- @tparam Text        textObject  The Text object to modify.
-- @tparam table       colorTable  The table to use for adding colored text.
-- @tparam WorldObject worldObject The tile object to inspect.
--
local function inspectWorldObject( textObject, colorTable, worldObject )
    local x, y = 0, 0
    local dx, dy = addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), Translator.getText( worldObject:getID() ))

    if worldObject:isClimbable() then
        dx, dy = addToTextObject( textObject, colorTable, x, y + dy, TexturePacks.getColor( 'ui_text_success' ), Translator.getText( 'ui_worldobject_info_climbable' ))
    elseif worldObject:isOpenable() then
        dx, dy = addToTextObject( textObject, colorTable, x, y + dy, TexturePacks.getColor( 'ui_text_success' ), Translator.getText( 'ui_worldobject_info_openable' ))
    elseif worldObject:isContainer() then
        dx, dy = addToTextObject( textObject, colorTable, x, y + dy, TexturePacks.getColor( 'ui_text_success' ), Translator.getText( 'ui_worldobject_info_lootable' ))
    elseif worldObject:doesBlockPathfinding() then
        dx, dy = addToTextObject( textObject, colorTable, x, y + dy, TexturePacks.getColor( 'ui_text_error' ), Translator.getText( 'ui_tile_info_impassable' ))
    end

    if worldObject:isDestructible() then
        addToTextObject( textObject, colorTable, x + dx, y + dy, TexturePacks.getColor( 'ui_text_warning' ), Translator.getText( 'ui_worldobject_info_destructible' ))
    else
        addToTextObject( textObject, colorTable, x + dx, y + dy, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_worldobject_info_indestructible' ))
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UITileInfo:initialize()
    local sw, _ = GridHelper.getScreenGridDimensions()
    UIElement.initialize( self, sw - UI_GRID_WIDTH, UI_GRID_HEIGHT, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.textObject = love.graphics.newText( TexturePacks.getFont():get() )
    self.colorTable = {}
end

function UITileInfo:draw()
    local tw, th = TexturePacks.getTileDimensions()
    love.graphics.draw( self.textObject, (self.ax+1) * tw, (self.ay+1) * th )
end

function UITileInfo:update( mouseX, mouseY, map )
    self.textObject:clear()

    local tile = map:getTileAt( mouseX, mouseY )
    if not tile then
        return
    end

    if tile:hasWorldObject() then
        inspectWorldObject( self.textObject, self.colorTable, tile:getWorldObject() )
    else
        inspectTile( self.textObject, self.colorTable, tile )
    end
end

return UITileInfo