---
-- This Action is used when a character closes an openable world object.
-- @module Close
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local SoundManager = require( 'src.SoundManager' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Close = Action:subclass( 'Close' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Close:initialize( character, target )
    Action.initialize( self, character, target, target:getWorldObject():getInteractionCost( character:getStance() ))
end

function Close:perform()
    local targetObject = self.target:getWorldObject()
    assert( targetObject:isOpenable(), 'Target needs to be openable!' )
    assert( targetObject:isPassable(), 'Target tile needs to be passable!' )
    assert( self.target:isAdjacent( self.character:getTile() ), 'Character has to be adjacent to the target tile!' )

    SoundManager.play( 'sound_door' )

    -- Update the WorldObject.
    targetObject:setPassable( false )
    targetObject:setBlocksVision( true )

    -- Mark target tile for update.
    self.target:setDirty( true )
    return true
end

return Close
