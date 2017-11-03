---
-- @module GridHelper
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GridHelper = {}

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Returns the screen dimensions in grid space.
-- @treturn number The screen's width in grid space.
-- @treturn number The screen's height in grid space.
--
function GridHelper.getScreenGridDimensions()
    local tw, th = TexturePacks.getTileDimensions()
    local sw, sh = love.graphics.getDimensions()
    return math.floor( sw / tw ), math.floor( sh / th )
end

---
-- Calculates the coordinates to be used to center an UI element of the
-- given dimensions.
-- @tparam  number w The grid width of the UI element to center.
-- @tparam  number h The grid height of the UI element to center.
-- @treturn number   The coordinate in grid space along the x-axis.
-- @treturn number   The coordinate in grid space along the y-axis.
--
function GridHelper.centerElement( w, h )
    local sw, sh = GridHelper.getScreenGridDimensions()
    return math.floor(( sw-w ) * 0.5 ), math.floor(( sh-h ) * 0.5 )
end

---
-- Maps a pixel coordinate to the grid space.
-- @tparam  number x The position in pixels along the x-axis.
-- @tparam  number y The position in pixels along the y-axis.
-- @treturn number   The coordinate in grid space along the x-axis.
-- @treturn number   The coordinate in grid space along the y-axis.
--
function GridHelper.pixelsToGrid( x, y )
    local tw, th = TexturePacks.getTileDimensions()
    return math.floor( x / tw ), math.floor( y / th )
end

return GridHelper
