local Messenger = require( 'src.Messenger' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );
local LEFT_CLICK  = 1;
local RIGHT_CLICK = 2;

local INPUT_MAP = {
    ['space']  = function() Messenger.publish( 'SWITCH_CHARACTERS'   ) end,
    ['return'] = function() Messenger.publish( 'SWITCH_FACTION'      ) end,
    ['a']      = function() Messenger.publish( 'ENTER_ATTACK_MODE'   ) end,
    ['escape'] = function() Messenger.publish( 'ENTER_MOVEMENT_MODE' ) end
};

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InputHandler = {};

function InputHandler.new( game )
    local self = {};

    love.mouse.setVisible( false );

    local map = game:getMap();
    local mouseX, mouseY = 0, 0;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update()
        local mx, my = love.mouse.getPosition();
        local tx, ty = math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );

        if mouseX ~= tx or mouseY ~= ty then
            mouseX, mouseY = tx, ty;
            Messenger.publish( 'MOUSE_MOVED', mouseX, mouseY );
        end
    end

    function self:keypressed( key )
        local action = INPUT_MAP[key];
        if action then
            action();
        end
    end

    function self:mousepressed( _, _, button )
        local tile = map:getTileAt( mouseX, mouseY );

        if not tile then
            return;
        end

        if button == LEFT_CLICK then
            Messenger.publish( 'LEFT_CLICKED_TILE', tile );
        elseif button == RIGHT_CLICK then
            Messenger.publish( 'RIGHT_CLICKED_TILE', tile );
        end
    end

    return self;
end

return InputHandler;
