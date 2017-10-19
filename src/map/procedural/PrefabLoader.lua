---
-- This class handles the generation of procedural maps.
-- @module PrefabLoader
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Prefab = require( 'src.map.procedural.Prefab' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabLoader = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local PREFAB_SOURCE_FOLDER = 'res/data/maps/prefabs/'

local INFO_FILE = 'info'
local GROUND_LAYER_FILE = 'ground.png'
local OBJECT_LAYER_FILE = 'objects.png'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local prefabs = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Tries to map a pixel to a template based on its RGBA values.
-- @tparam  table  templates Table containing the template to RGBA mappings.
-- @tparam  number r         The red-component read from the ground layer.
-- @tparam  number g         The green-component read from the ground layer.
-- @tparam  number b         The blue-component read from the ground layer.
-- @tparam  number a         The alpha value read from the ground layer.
-- @treturn string           The template id.
--
--
local function mapPixels( templates, r, g, b, _ )
    local id
    for _, template in ipairs( templates ) do
        if template.r == r and template.g == g and template.b == b then
            id = template.id
            break
        end
    end
    return id
end

---
-- Iterates over all pixels in the image file and tries to map the colors to
-- a template provided in the info file inside of a 2d array.
-- @tparam  table templates Table containing the template to RGBA mappings.
-- @tparam  Image img       The image containing the layout.
-- @treturn table           Grid containing the mapped templates.
--
local function convertImageToTemplates( templates, img )
    local grid = {}
    for x = 1, img:getWidth() do
        grid[x] = {}
        for y = 1, img:getHeight() do
            grid[x][y] = mapPixels( templates, img:getPixel( x - 1, y - 1 )) or false
        end
    end
    return grid
end

---
-- Creates a prefab object based on the loaded data from the template files.
-- @tparam  table  info    The data loaded from the info file.
-- @tparam  Image  ground  The image representing the ground layer.
-- @tparam  Image  objects The image representing the objects layer.
-- @treturn Prefab         The newly created Prefab.
--
local function createPrefab( info, ground, objects )
    local prefab = Prefab.new( info.name, info.parcelsize, info.rotatable )

    prefab:setTiles( convertImageToTemplates( info.ground, ground ))
    prefab:setObjects( convertImageToTemplates( info.objects, objects ))

    return prefab
end

---
-- Loads a prefab template.
-- It'll look for an info file and two images representing the tile and object
-- layers.
-- @tparam  string  src The path to load the template from.
-- @treturn boolean     True if the prefab was loaded correctly.
-- @treturn table       The loaded prefabTemplate (only if successful).
--
local function load( src )
    if not love.filesystem.exists( src .. INFO_FILE .. '.lua' ) then
        Log.warn( string.format( 'Can\'t find info file. Ignoring path %s', src ), 'PrefabLoader' )
        return false
    end

    local module = require( src .. INFO_FILE )
    if not module then
        Log.warn( string.format( 'Couldn\'t load prefab from %s. Bad format on info file.', src ), 'PrefabLoader' )
        return false
    end

    local ground  = love.image.newImageData( src .. GROUND_LAYER_FILE )
    local objects = love.image.newImageData( src .. OBJECT_LAYER_FILE )

    return true, createPrefab( module, ground, objects )
end

---
-- Loads prefabs from the provided path.
-- @tparam string sourceFolder The path to check.
--
local function loadPrefabTemplates( sourceFolder )
    local count = 0
    for _, item in ipairs( love.filesystem.getDirectoryItems( sourceFolder )) do
        local path = sourceFolder .. item .. '/'
        if love.filesystem.isDirectory( path ) then
            local success, prefab = load( path )

            if success then
                prefabs[prefab:getName()] = prefab

                count = count + 1
                Log.debug( string.format( '  %3d. %s', count, prefab.name ))
            end
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads all prefab templates the game can find.
--
function PrefabLoader.load()
    Log.debug( 'Loading parcel prefabs:' )
    loadPrefabTemplates( PREFAB_SOURCE_FOLDER )
end

function PrefabLoader.getRandomPrefab()
    local array = {}
    for i, _ in pairs( prefabs ) do
        array[#array + 1] = i
    end

    local name = array[love.math.random( #array )]
    return prefabs[name]
end

return PrefabLoader