---
-- This module offers functions to save and load temporary game data. The data
-- is stored on the harddisk and loaded again if needed. This can be used to
-- pass around the data between different states.
--
-- @module DataHandler
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Compressor = require( 'src.util.Compressor' )
-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local DataHandler = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEMP_FOLDER = 'tmp'
local PLAYER_FACTION_SAVE = 'tmp_faction.data'

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Copies the current player faction to the harddisk as a temporary file.
-- This should only be used to copy and paste the player faction data between
-- different states.
-- @tparam table t The player faction data.
--
function DataHandler.copyPlayerFaction( t )
    Log.info( 'Saving player faction...', 'DataHandler' )

    -- Create the saves folder it doesn't exist already.
    if not love.filesystem.getInfo( TEMP_FOLDER ) then
        love.filesystem.createDirectory( TEMP_FOLDER )
    end

    Compressor.save( t, TEMP_FOLDER .. '/' .. PLAYER_FACTION_SAVE )
end

---
-- Loads the temporary player faction file from the harddisk.
-- This should only be used to copy and paste the player faction data between
-- different states.
-- @treturn table The player faction data.
--
function DataHandler.pastePlayerFaction()
    Log.info( 'Loading player faction...', 'DataHandler' )
    return Compressor.load( TEMP_FOLDER .. '/' .. PLAYER_FACTION_SAVE )
end

---
-- Removes all files in the temporary folder and the folder itself from the
-- player's save directory.
--
function DataHandler.removeTemporaryFiles()
    Log.info( 'Removing temporary files...', 'DataHandler' )

    for _, item in pairs( love.filesystem.getDirectoryItems( TEMP_FOLDER )) do
        love.filesystem.remove( TEMP_FOLDER .. '/' .. item )
    end
    love.filesystem.remove( TEMP_FOLDER )
end

return DataHandler