---
-- @module IngameCombatMenu
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local SaveHandler = require( 'src.SaveHandler' )
local DataHandler = require( 'src.DataHandler' )
local Translator = require( 'src.util.Translator' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )
local UIContainer = require( 'src.ui.elements.UIContainer' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local IngameCombatMenu = Screen:subclass( 'IngameCombatMenu' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 14
local UI_GRID_HEIGHT = 9

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Generates the outlines for this screen.
-- @tparam  number     x The origin of the screen along the x-axis.
-- @tparam  number     y The origin of the screen along the y-axis.
-- @treturn UIOutlines   The newly created UIOutlines instance.
--
local function generateOutlines( x, y )
    local outlines = UIOutlines( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    -- Horizontal borders.
    for ox = 0, UI_GRID_WIDTH-1 do
        outlines:add( ox, 0                ) -- Top
        outlines:add( ox, 2                ) -- Header
        outlines:add( ox, UI_GRID_HEIGHT-1 ) -- Bottom
    end

    -- Vertical outlines.
    for oy = 0, UI_GRID_HEIGHT-1 do
        outlines:add( 0,               oy ) -- Left
        outlines:add( UI_GRID_WIDTH-1, oy ) -- Right
    end

    outlines:refresh()
    return outlines
end

local function createSaveGameButton( lx, ly, game )
    -- Create the callback for the save button.
    local function saveGame()
        -- Create the callback for the confirmation dialog.
        local function confirmationCallback( name )
            local save = game:serialize()
            save.baseInventory = DataHandler.pasteBaseInventory()

            SaveHandler.save( save, name )
            ScreenManager.pop() -- Close input dialog.
            ScreenManager.pop() -- Close ingame combat menu.
        end

        -- Generate date as a default save name.
        local date = os.date( '%d-%m-%Y_%H%M%S', os.time() )

        ScreenManager.push( 'inputdialog', Translator.getText( 'ui_ingame_input_save_name' ), date, confirmationCallback )
    end

    return UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, saveGame, Translator.getText( 'ui_ingame_save_game' ))
end

local function createAbortMissionButton( lx, ly, playerFaction )
    local function abortMission()
        DataHandler.copyPlayerFaction( playerFaction:serialize() )
        ScreenManager.switch( 'base' )
    end
    return UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, abortMission, Translator.getText( 'ui_ingame_abort' ))
end

local function createButtons( game )
    local lx, ly = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    local buttonList = UIVerticalList( lx, ly, 0, 3, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    local saveGameButton = createSaveGameButton( lx, ly, game )
    buttonList:addChild( saveGameButton )

    local openHelpButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.push( 'help' ) end, Translator.getText( 'ui_ingame_open_help' ))
    buttonList:addChild( openHelpButton )

    local abortMissionButton = createAbortMissionButton( lx, ly, game:getPlayerFaction() )
    buttonList:addChild( abortMissionButton )

    local exitButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.switch( 'mainmenu' ) end, Translator.getText( 'ui_ingame_exit' ))
    buttonList:addChild( exitButton )

    local resumeButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.pop() end, Translator.getText( 'ui_ingame_resume' ))
    buttonList:addChild( resumeButton )

    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function IngameCombatMenu:initialize( game )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.outlines = generateOutlines( self.x, self.y )
    self.buttonList = createButtons( game )
    self.container = UIContainer()
    self.container:register( self.buttonList )
end

function IngameCombatMenu:draw()
    self.background:draw()
    self.outlines:draw()

    self.container:draw()
    local tw, th = TexturePacks.getTileDimensions()
    love.graphics.printf( Translator.getText( 'ui_ingame_paused' ), (self.x+1) * tw, (self.y+1) * th, (UI_GRID_WIDTH - 2) * tw, 'center' )
end

function IngameCombatMenu:update()
    self.container:update()
end

function IngameCombatMenu:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'up' then
        self.container:command( 'up' )
    elseif scancode == 'down' then
        self.container:command( 'down' )
    elseif scancode == 'return' then
        self.container:command( 'activate' )
    end

    if scancode == 'escape' then
        ScreenManager.pop()
    end
end

function IngameCombatMenu:mousereleased()
    self.container:command( 'activate' )
end

function IngameCombatMenu:mousemoved()
    love.mouse.setVisible( true )
end

function IngameCombatMenu:resize( _, _ )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.background:setOrigin( self.x, self.y )
    self.outlines:setOrigin( self.x, self.y )
    self.buttonList:setOrigin( self.x, self.y )
end

return IngameCombatMenu
