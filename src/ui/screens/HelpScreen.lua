local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local HelpScreen = Screen:subclass( 'HelpScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 64
local UI_GRID_HEIGHT = 48

local HELP_TEXT = {
    {
        text = 'CHARACTERS',
        color = 'ui_help_section',
        children = {
            'NOTE: Characters can also be selected by right-clicking on them!',
            'backspace - Select previous character',
            'space     - Select next character',
            'return    - End turn',
            'i         - Open inventory',
            'h         - Open health panel'
        }
    },
    {
        text = 'WEAPONS',
        color = 'ui_help_section',
        children = {
            'left  - select previous firing mode',
            'right - select next firing mode',
            'r - reload current weapon'
        }
    },
    {
        text = 'STANCES',
        color = 'ui_help_section',
        children = {
            's - change stance to Stand',
            'c - change stance to Crouch',
            'p - change stance to Prone'
        }
    },
    {
        text = 'INPUT',
        color = 'ui_help_section',
        children = {
            'a - Switch to Attack Mode',
            'm - Switch to Movement Mode',
            'e - Switch to Interaction Mode (e.g. to open barrels or doors)'
        }
    },
    {
        text = 'MISC',
        color = 'ui_help_section',
        children = {
            'f - Switch between windowed and fullscreen modes'
        }
    }
}

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Wraps the text into a Text object.
-- @treturn Text The text object.
--
local function assembleText()
    local text = love.graphics.newText( TexturePacks.getFont():get() )
    local tw, th = TexturePacks.getTileDimensions()
    local offset = 0

    -- Draw sections first.
    for i = 1, #HELP_TEXT do
        text:addf({ TexturePacks.getColor( HELP_TEXT[i].color ), HELP_TEXT[i].text }, (UI_GRID_WIDTH-2) * tw, 'left', 0, offset * th )
        offset = offset + 1

        -- Draw sub items with a slight offset to the right.
        for j = 1, #HELP_TEXT[i].children do
            offset = offset + 1
            text:addf( HELP_TEXT[i].children[j], (UI_GRID_WIDTH-2) * tw, 'left', 4*tw, offset * th )
        end

        offset = offset + 2
    end

    return text
end

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

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function HelpScreen:initialize()
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.outlines = generateOutlines( self.x, self.y )
    self.text = assembleText()
    self.header = love.graphics.newText( TexturePacks.getFont():get(), Translator.getText( 'ui_help_header' ))
end

function HelpScreen:draw()
    self.background:draw()
    self.outlines:draw()

    local tw, th = TexturePacks.getTileDimensions()
    TexturePacks.setColor( 'ui_text' )
    love.graphics.draw( self.header, (self.x+1) * tw, (self.y+1) * th )
    love.graphics.draw( self.text,   (self.x+1) * tw, (self.y+3) * th )
    TexturePacks.resetColor()
end

function HelpScreen:keypressed( key )
    if key == 'escape' then
        ScreenManager.pop()
    end
end

function HelpScreen:resize( _, _ )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.background:setOrigin( self.x, self.y )
    self.outlines:setOrigin( self.x, self.y )
end

return HelpScreen
