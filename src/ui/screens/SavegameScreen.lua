---
-- @module SavegameScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local Translator = require( 'src.util.Translator' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local SaveHandler = require( 'src.SaveHandler' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local GridHelper = require( 'src.util.GridHelper' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local Util = require( 'src.util.Util' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SavegameScreen = Screen:subclass( 'SavegameScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TITLE_POSITION = 2
local TITLE_STRING = {
    " @@@@@     @@@@@@   @@@  @@@  @@@@@@@    @@@@@  ",
    "@@@@@@@   @@@@@@@@  @@@  @@@  @@@@@@@@  @@@@@@@ ",
    "!@@       @@!  @@@  @@!  @@@  @@!       !@@     ",
    "!@!       !@!  @!@  !@!  @!@  !@!       !@!     ",
    "!!@@!!    @!@!@!@!  @!@  !@!  @!!!:!    !!@@!!  ",
    " !!@!!!   !!!@!!!!  !@!  !!!  !!!!!:     !!@!!! ",
    "     !:!  !!:  !!!  :!:  !!:  !!:            !:!",
    "    !:!   :!:  !:!   ::!!::   :!:           !:! ",
    "::!::::    ::   ::    !:::    ::!::!!   ::!:::: ",
    " :::..      !    :     !:     :!:::::!   :::..  "
}

local BUTTON_LIST_WIDTH = 20
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function createTitle()
    local font = TexturePacks.getFont():get()
    local title = love.graphics.newText( font )
    for i, line in ipairs( TITLE_STRING ) do
        local coloredtext = {}
        for w in string.gmatch( line, '.' ) do
            if w == '@' then
                coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_1' )
                coloredtext[#coloredtext + 1] = 'O'
            elseif w == '!' then
                coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_2' )
                coloredtext[#coloredtext + 1] = w
            else
                coloredtext[#coloredtext + 1] = TexturePacks.getColor( 'ui_title_3' )
                coloredtext[#coloredtext + 1] = w
            end
            title:add( coloredtext, 0, i * font:getHeight() )
        end
    end
    return title
end

local function drawTitle( title )
    local cx, _ = GridHelper.centerElement( GridHelper.pixelsToGrid( title:getWidth(), title:getHeight() * #TITLE_STRING ))
    local tw, _ = TexturePacks.getTileDimensions()
    love.graphics.draw( title, cx * tw, TITLE_POSITION * TexturePacks.getFont():getGlyphHeight() )
end

local function createBackButton( lx, ly )
    local function callback()
        ScreenManager.switch( 'mainmenu' )
    end
    return UIButton( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, callback, Translator.getText( 'ui_back' ))
end

local function createSaveGameEntry( lx, ly, index, item, folder )
    local version = SaveHandler.loadVersion( folder )

    -- Generate the string for the savegame button showing the name of the saves,
    -- the version of the game at which they were created and their creation date.
    local str = string.format( '%2d. %s', index, item )
    str = Util.rightPadString( str, 36, ' ')
    str = str .. string.format( '  %s    %s', version, os.date( '%Y-%m-%d  %X', love.filesystem.getLastModified( folder )))

    local function callback()
        if version == getVersion() then
            local save = SaveHandler.load( folder )
            ScreenManager.switch( 'gamescreen', save )
        end
    end

    local button = UIButton( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, callback, str, 'center' )
    button:setActive( version == getVersion() )
    return button
end


local function createButtons()
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
    local ly = BUTTON_LIST_Y

    local buttonList = UIVerticalList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

    -- Create entries for last five savegames.
    local items = love.filesystem.getDirectoryItems( SaveHandler.getSaveFolder() )
    local counter = 0

    for i = #items, 1, -1 do
        local item = items[i]
        if love.filesystem.isDirectory( SaveHandler.getSaveFolder() .. '/' .. item ) then
            counter = counter + 1
            buttonList:addChild( createSaveGameEntry( lx, ly, counter, item, SaveHandler.getSaveFolder() .. '/' .. item ))
        end
    end

    buttonList:addChild( createBackButton( lx, ly ))
    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function SavegameScreen:initialize()
    self.title = createTitle()
    self.buttonList = createButtons()

    self.container = UIContainer()
    self.container:register( self.buttonList )

    self.footer = UICopyrightFooter.new()
end

function SavegameScreen:update()
    self.container:update()
end

function SavegameScreen:draw()
    drawTitle( self.title )
    self.container:draw()
    self.footer:draw()
end

function SavegameScreen:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'escape' then
        ScreenManager.switch( 'mainmenu' )
    end

    if scancode == 'up' then
        self.container:command( 'up' )
    elseif scancode == 'down' then
        self.container:command( 'down' )
    elseif scancode == 'return' then
        self.container:command( 'activate' )
    end
end

function SavegameScreen:mousemoved()
    love.mouse.setVisible( true )
end

---
-- Handle mousereleased events.
--
function SavegameScreen:mousereleased()
    self.container:mousecommand( 'activate' )
end

function SavegameScreen:resize( _, _ )
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
    local ly = BUTTON_LIST_Y
    self.buttonList:setOrigin( lx, ly )
end

return SavegameScreen
