local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local UIInventoryList = require( 'src.ui.inventory.UIInventoryList' );
local UIEquipmentList = require( 'src.ui.inventory.UIEquipmentList' );
local InventoryOutlines = require( 'src.ui.inventory.InventoryOutlines' );
local Translator = require( 'src.util.Translator' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local TILE_SIZE = require( 'src.constants.TileSize' );

local VERTICAL_COLUMN_OFFSET = 3 * TILE_SIZE;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InventoryScreen.new()
    local self = Screen.new();

    local character;
    local lists;
    local dragboard;
    local target;

    local  w,  h;
    local sx, sy; -- Spacers.

    local outlines;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function getColumnWidth()
        return ( sx - 1 ) * TILE_SIZE;
    end

    local function getEquipmentColumnOffset()
        return TILE_SIZE;
    end

    local function getOtherColumnOffset()
        return ( 2 + 2 * sx ) * TILE_SIZE;
    end

    local function getBackpackColumnOffset()
        return ( 2 + sx ) * TILE_SIZE;
    end

    local function getListBelowCursor()
        for _, list in pairs( lists ) do
            if list:isMouseOver() then
                return list;
            end
        end
        return false;
    end

    local function createCharacterInventory()
        lists.equipment = UIEquipmentList.new( getEquipmentColumnOffset(), VERTICAL_COLUMN_OFFSET, sx * TILE_SIZE, 'inventory_equipment', character );
        lists.equipment:init();
    end

    local function createBackpackInventory()
        if character:getBackpack() then
            lists.backpack = UIInventoryList.new( getBackpackColumnOffset(), VERTICAL_COLUMN_OFFSET, getColumnWidth(), 'inventory_backpack', character:getBackpack():getInventory() );
            lists.backpack:init();
            return;
        end
        lists.backpack = nil;
    end

    local function createOtherInventory()
        local x, y, cw = getOtherColumnOffset(), VERTICAL_COLUMN_OFFSET, getColumnWidth();

        -- Create inventory for container world objects.
        if target:hasWorldObject() and target:getWorldObject():isContainer() then
            lists.other = UIInventoryList.new( x, y, cw, 'inventory_container_inventory', target:getWorldObject():getInventory() );
            lists.other:init();
            return;
        end

        -- Create inventory for other characters of the same faction.
        if target:isOccupied() and target:getCharacter() ~= character and target:getCharacter():getFaction():getType() == character:getFaction():getType() then
            lists.other = UIInventoryList.new( x, y, cw, 'inventory_backpack', target:getCharacter():getBackpack():getInventory() );
            lists.other:init();
            return;
        end

        -- Create inventory for a tile's floor.
        lists.other = UIInventoryList.new( x, y, cw, 'inventory_tile_inventory', target:getInventory() );
        lists.other:init();
    end

    local function returnItemToOrigin( item, origin )
        if origin:instanceOf( 'EquipmentSlot' ) then
            origin:addItem( item );
        else
            origin:drop( item );
        end
    end

    local function drag( list, button )
        if not list then
            return;
        end

        local item, slot = list:drag( button == 2, love.keyboard.isDown( 'lshift' ));
        if item then
            -- If we have an actual item slot we use it as the origin to
            -- which the item is returned in case it can't be dropped anywhere.
            dragboard = { item = item, origin = slot or list };
            if item:instanceOf( 'Bag' ) then
                createBackpackInventory();
            end
        end
    end

    local function drop( list )
        if not list then
            returnItemToOrigin( dragboard.item, dragboard.origin );
        else
            local success = list:drop( dragboard.item, dragboard.origin );
            if not success then
                returnItemToOrigin( dragboard.item, dragboard.origin );
            end
        end
        createBackpackInventory();
        dragboard = nil;
    end

    local function drawHeaders()
        love.graphics.print( lists.equipment:getLabel(), getEquipmentColumnOffset(), TILE_SIZE );

        if lists.backpack then
            love.graphics.print( lists.backpack:getLabel(), getBackpackColumnOffset(), TILE_SIZE );
        else
            love.graphics.print( 'No backpack equipped', getBackpackColumnOffset(), TILE_SIZE );
        end

        love.graphics.print( lists.other:getLabel(), getOtherColumnOffset(), TILE_SIZE );
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Creates the three inventory lists for the player's equipment, his Backpack
    -- and the tile he is standing on.
    -- @param ncharacter (Character) The character to open the inventory for.
    -- @param ntarget    (Tile)      The target tile to open the inventory for.
    --
    function self:init( ncharacter, ntarget )
        character = ncharacter;
        target = ntarget;

        love.mouse.setVisible( true );

        w  = math.floor( love.graphics.getWidth()  / TILE_SIZE );
        h  = math.floor( love.graphics.getHeight() / TILE_SIZE );
        sx = math.floor( w / 3 );
        sy = math.floor( h / 3 );

        outlines = InventoryOutlines.new( w, h, sx, sy );
        outlines:init();

        lists = {};

        createCharacterInventory();
        createOtherInventory();
    end

    ---
    -- Draws the inventory lists and the dragged item (if there is one).
    --
    function self:draw()
        -- Draw a transparent overlay.
        love.graphics.setColor( 0, 0, 0, 220 );
        love.graphics.rectangle( 'fill', 0, 0, love.graphics.getDimensions() );
        love.graphics.setColor( 255, 255, 255, 255 );

        outlines:draw( love.graphics.getDimensions() );
        drawHeaders( love.graphics.getWidth() );

        for _, list in pairs( lists ) do
            list:draw();
        end

        if dragboard then
            local mx, my = love.mouse.getPosition();
            love.graphics.setColor( COLORS.DB20 );

            local item = dragboard.item;
            local str = item and Translator.getText( item:getID() ) or Translator.getText( 'inventory_empty_slot' );
            if item:instanceOf( 'ItemStack' ) and item:getItemCount() > 1 then
                str = string.format( '%s (%d)', str, item:getItemCount() );
            end
            love.graphics.print( str, mx, my );
        end

        lists.equipment:highlightSlot( dragboard and dragboard.item );
    end

    ---
    -- Updates the inventory lists.
    --
    function self:update( dt )
        for _, list in pairs( lists ) do
            list:update( dt );
        end
    end

    function self:keypressed( key )
        if key == 'escape' or key == 'i' then
            ScreenManager.pop();
        end
    end

    function self:mousepressed( _, _, button )
        if dragboard then
            return;
        end

        local list = getListBelowCursor();
        drag( list, button );
    end

    function self:mousereleased( _, _, _ )
        if not dragboard then
            return;
        end

        local list = getListBelowCursor();
        drop( list );
    end

    function self:close()
        love.mouse.setVisible( false );

        -- Drop any item that is currently dragged.
        if dragboard then
            drop();
        end
    end

    return self;
end

return InventoryScreen;
