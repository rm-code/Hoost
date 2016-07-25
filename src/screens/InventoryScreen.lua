local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local FactionManager = require( 'src.characters.FactionManager' );
local UIInventoryList = require( 'src.ui.inventory.UIInventoryList' );
local UIEquipmentList = require( 'src.ui.inventory.UIEquipmentList' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local DRAGGED_ITEM_WIDTH  = 150;
local DRAGGED_ITEM_HEIGHT =  30;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InventoryScreen.new()
    local self = Screen.new();

    local character = FactionManager.getCurrentCharacter();
    local lists;
    local dragboard;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Creates the three inventory lists for the player's equipment, his Backpack
    -- and the tile he is standing on.
    --
    function self:init()
        local characterEquipment = UIEquipmentList.new( 20, 20, 'Equipment', character:getEquipment() );
        characterEquipment:init();

        local characterInventory = UIInventoryList.new( 220, 20, 'Backpack', character:getEquipment():getBackpack():getInventory() );
        characterInventory:init();

        local tileInventory = UIInventoryList.new( 420, 20, 'Tile Inventory', character:getTile():getInventory() );
        tileInventory:init();

        lists = {
            characterEquipment,
            characterInventory,
            tileInventory
        }
    end

    ---
    -- Draws the inventory lists and the dragged item (if there is one).
    --
    function self:draw()
        -- Draw a transparent overlay.
        love.graphics.setColor( 0, 0, 0, 200 );
        love.graphics.rectangle( 'fill', 0, 0, love.graphics.getDimensions() );
        love.graphics.setColor( 255, 255, 255, 255 );

        for i = 1, #lists do
            lists[i]:draw();
        end

        if dragboard then
            local mx, my = love.mouse.getPosition();
            love.graphics.setColor( COLORS.DB00 );
            love.graphics.rectangle( 'fill', mx, my, DRAGGED_ITEM_WIDTH, DRAGGED_ITEM_HEIGHT );
            love.graphics.setColor( COLORS.DB23 );
            love.graphics.rectangle( 'line', mx, my, DRAGGED_ITEM_WIDTH, DRAGGED_ITEM_HEIGHT );
            love.graphics.setColor( COLORS.DB21 );
            love.graphics.printf( dragboard.item:getName(), mx, my + 5, DRAGGED_ITEM_WIDTH, 'center' );
        end
    end

    ---
    -- Updates the inventory lists.
    --
    function self:update( dt )
        for i = 1, #lists do
            lists[i]:update( dt );
        end
    end

    function self:keypressed( key )
        if key == 'escape' or key == 'i' then
            ScreenManager.pop();
        end
    end

    function self:mousepressed()
        for _, list in ipairs( lists ) do
            if list:isMouseOver() then
                if dragboard then
                    list:drop( dragboard.item, dragboard.origin );
                    dragboard = nil;
                    return;
                else
                    local item = list:drag();
                    if item then
                        dragboard = { item = item, origin = list };
                    end
                end
            end
        end
    end

    return self;
end

return InventoryScreen;
