local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local HelpScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function HelpScreen.new()
    local self = Screen.new();

    local t = {
        'CHARACTERS',
        'backspace - Select previous character',
        'space - Select next character',
        'return - End turn',
        ' NOTE: Characters can also be selected by right clicking on them.',
        'i - Open inventory',
        '',
        'WEAPONS',
        'left  - select previous firing mode',
        'right - select next firing mode',
        'r - reload current weapon',
        '',
        'STANCES',
        's - change stance to Stand',
        'c - change stance to Crouch',
        'p - change stance to Prone',
        '',
        'INPUT MODES',
        'a - Switch to Attack Mode',
        'm - Switch to Movement Mode',
        'e - Switch to Interaction Mode (e.g. to open barrels or doors)',
    }

    function self:draw()
        love.graphics.setColor( 0, 0, 0, 220 );
        love.graphics.rectangle( 'fill', 5, 5, love.graphics.getWidth() - 5, love.graphics.getHeight() - 5 );
        love.graphics.setColor( 200, 200, 200, 200 );
        love.graphics.rectangle( 'line', 5, 5, love.graphics.getWidth() - 5, love.graphics.getHeight() - 5 );
        love.graphics.setColor( 255, 255, 255, 255 );

        for i, line in ipairs( t ) do
            love.graphics.print( line, 20, 20 * i );
        end
    end

    function self:keypressed( key )
        if key == 'escape' then
            ScreenManager.pop();
        end
    end

    return self;
end

return HelpScreen;