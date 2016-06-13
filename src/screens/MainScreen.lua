local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local Game = require( 'src.Game' );
local WorldPainter = require( 'src.ui.WorldPainter' );
local CameraHandler = require('src.ui.CameraHandler');
local MousePointer = require( 'src.ui.MousePointer' );
local UserInterface = require( 'src.ui.UserInterface' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local game;
    local worldPainter;
    local userInterface;
    local camera;

    function self:init()
        game = Game.new();
        game:init();

        worldPainter = WorldPainter.new( game );
        worldPainter:init();

        userInterface = UserInterface.new( game );
        camera = CameraHandler.new();

        MousePointer.init( camera );
    end

    function self:draw()
        camera:attach();
        worldPainter:draw();
        camera:detach();
        userInterface:draw();
    end

    function self:update( dt )
        camera:update( dt );
        game:update( dt );
        worldPainter:update( dt );
        userInterface:update( dt );
    end

    function self:keypressed( key )
        game:keypressed( key );

        if key == 'i' then
            ScreenManager.push( 'inventory' );
        end
    end

    function self:mousepressed( _, _, button )
        local mx, my = MousePointer.getGridPosition();
        game:mousepressed( mx, my, button );
    end

    return self;
end

return MainScreen;
