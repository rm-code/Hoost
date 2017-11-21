---
-- This class handles the loading and using of texture packs.
-- @module TexturePacks
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local TexturePack = require( 'src.ui.texturepacks.TexturePack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TexturePacks = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEXTURE_PACK_FOLDER     = 'res/texturepacks/'
local MOD_TEXTURE_PACK_FOLDER = 'mods/texturepacks/'
local INFO_FILE_NAME = 'info'
local SPRITE_DEFINITIONS = 'sprites'
local COLOR_DEFINITIONS  = 'colors'

local DEFAULT = {
    NAME = 'default',
    INFO = 'info.lua',
    COLORS = 'colors.lua',
    SPRITES = 'sprites.lua',
    IMAGEFONT = 'imagefont.png',
    SPRITESHEET = 'spritesheet.png',
}

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local texturePacks = {}
local current

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Checks if the loaded module provides all the necessary fields.
-- @tparam  table   module The loaded module to check.
-- @treturn boolean        True if the module is valid.
--
local function validate( module )
    if not module.name
    or not module.font
    or not module.tileset then
        return false
    end

    if not module.font.source
    or not module.font.glyphs
    or not module.tileset.source
    or not module.tileset.tiles then
        return false
    end

    if not module.font.glyphs.source
    or not module.font.glyphs.width
    or not module.font.glyphs.height
    or not module.tileset.tiles.width
    or not module.tileset.tiles.height then
        return false
    end

    return true
end

---
-- Loads a texture pack.
-- @tparam string   src The path to load the templates from.
-- @treturn boolean     True if the texture pack was loaded successfully.
-- @treturn TexturePack The loaded texture pack (only if successful).
--
local function load( src )
    local path = src .. INFO_FILE_NAME
    local module = require( path )
    if not module or not validate( module ) then
        return false
    end

    local spriteInfos = require( src .. SPRITE_DEFINITIONS )
    if not spriteInfos then
        return false
    end

    local colorInfos = require( src .. COLOR_DEFINITIONS )
    if not colorInfos then
        return false
    end

    local tpack = TexturePack.new()
    tpack:init( src, module, spriteInfos, colorInfos )

    return true, tpack
end

---
-- Loads texture packs from the provided path.
-- @tparam string sourceFolder The path to check for texture packs.
--
local function loadPacks( sourceFolder )
    local count = 0
    for _, item in ipairs( love.filesystem.getDirectoryItems( sourceFolder )) do
        local path = sourceFolder .. item .. '/'
        if love.filesystem.isDirectory( path ) then
            local success, tpack = load( path )

            if success then
                local name = tpack:getName()
                -- Register new texture pack and make it the current one if
                -- there isn't a current one already.
                texturePacks[name] = tpack
                if not current then
                    current = name
                end

                count = count + 1
                Log.print( string.format( '  %3d. %s', count, name ), 'TexturePacks' )
            end
        end
    end
end

---
-- Copies a file from the source folder to the target folder. Throws an error
-- if the file can't be written to the target folder.
-- @tparam string source The directory to load the file from.
-- @tparam string target The directory to save the file to.
-- @tparam string name   The file's name.
--
local function copyFile( source, target, name )
    assert( love.filesystem.write( target .. name, love.filesystem.read( source .. name )))
end

---
-- Copies the default texture pack to the mods folder in the user's save directory.
--
local function copyDefaultTexturePack()
    -- Abort if the texture pack exists already.
    if love.filesystem.isDirectory( MOD_TEXTURE_PACK_FOLDER .. DEFAULT.NAME ) then
        return
    end

    love.filesystem.createDirectory( MOD_TEXTURE_PACK_FOLDER .. DEFAULT.NAME )

    local source =     TEXTURE_PACK_FOLDER .. DEFAULT.NAME .. '/'
    local target = MOD_TEXTURE_PACK_FOLDER .. DEFAULT.NAME .. '/'

    copyFile( source, target, DEFAULT.INFO )
    copyFile( source, target, DEFAULT.COLORS )
    copyFile( source, target, DEFAULT.SPRITES )
    copyFile( source, target, DEFAULT.IMAGEFONT )
    copyFile( source, target, DEFAULT.SPRITESHEET )
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function TexturePacks.load()
    Log.print( "Load Default Texture Packs:", 'TexturePacks' )
    loadPacks( TEXTURE_PACK_FOLDER )

    -- Creates the mods folder if it doesn't exist.
    if not love.filesystem.exists( MOD_TEXTURE_PACK_FOLDER ) then
        love.filesystem.createDirectory( MOD_TEXTURE_PACK_FOLDER )
    end

    Log.print( "Load External Texture Packs:", 'TexturePacks' )
    loadPacks( MOD_TEXTURE_PACK_FOLDER )

    Log.debug( "Copying default texture pack to mod folder!" )
    copyDefaultTexturePack()
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function TexturePacks.getTexturePacks()
    return texturePacks
end

function TexturePacks.getName()
    return texturePacks[current]:getName()
end

function TexturePacks.getFont()
    return texturePacks[current]:getFont()
end

function TexturePacks.getTileset()
    return texturePacks[current]:getTileset()
end

function TexturePacks.getSprite( id, alt )
    return texturePacks[current]:getTileset():getSprite( id, alt )
end

function TexturePacks.getGlyphDimensions()
    return texturePacks[current]:getGlyphDimensions()
end

function TexturePacks.getTileDimensions()
    return texturePacks[current]:getTileset():getTileDimensions()
end

function TexturePacks.setColor( id )
    love.graphics.setColor( texturePacks[current]:getColor( id ))
end

function TexturePacks.getColor( id )
    return texturePacks[current]:getColor( id )
end

function TexturePacks.setBackgroundColor()
    love.graphics.setBackgroundColor( texturePacks[current]:getColor( 'sys_background' ))
end

function TexturePacks.resetColor()
    love.graphics.setColor( texturePacks[current]:getColor( 'sys_reset' ))
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function TexturePacks.setCurrent( ncurrent )
    current = ncurrent
end

return TexturePacks
