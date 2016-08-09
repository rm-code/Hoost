local Object = require( 'src.Object' );
local UIInventoryItem = require( 'src.ui.inventory.UIInventoryItem' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIInventoryList = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local PADDING = 15;
local HEADER_HEIGHT = 30;
local WIDTH = 150;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIInventoryList.new( x, y, name, inventory )
    local self = Object.new():addInstance( 'UIInventoryList' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local list;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function regenerate()
        list = {};
        for i, item in ipairs( inventory:getItems() ) do
            list[#list + 1] = UIInventoryItem.new( x, HEADER_HEIGHT + ( y + PADDING ) * i, item );
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        regenerate();
    end

    function self:draw()
        love.graphics.setColor( 0, 0, 0 );
        love.graphics.rectangle( 'fill', x, y, WIDTH, HEADER_HEIGHT );
        love.graphics.setColor( 200, 200, 200 );
        love.graphics.rectangle( 'line', x, y, WIDTH, HEADER_HEIGHT );
        love.graphics.setColor( 255, 255, 255 );
        love.graphics.setScissor( x, y, WIDTH, HEADER_HEIGHT );
        love.graphics.printf( name, x, y + 5, WIDTH, 'center' );
        love.graphics.setScissor();

        for _, slot in ipairs( list ) do
            slot:draw();
        end
    end

    function self:update( dt )
        for _, slot in ipairs( list ) do
            slot:update( dt );
        end
    end

    function self:isMouseOver()
        local mx = love.mouse.getX();
        return ( mx > x and mx < x + WIDTH );
    end

    function self:drop( item )
        inventory:addItem( item );
        regenerate();
        return true;
    end

    function self:drag()
        for _, uiItem in ipairs( list ) do
            if uiItem:isMouseOver() then
                local item = uiItem:drag();
                inventory:removeItem( item );
                regenerate();
                return item;
            end
        end
    end

    return self;
end

return UIInventoryList;