---
-- This Action is used when a character tries to climb over a wall or any other
-- climbable object. It removes the Character from the current Tile and places
-- it on the target Tile on top of the WorldObject.
-- @module ClimbOver
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local Messenger = require( 'src.Messenger' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ClimbOver = Action:subclass( 'ClimbOver' )

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

function ClimbOver:initialize( character, target )
    Action.initialize( self, character, target, target:getWorldObject():getInteractionCost( character:getStance() ))
end

function ClimbOver:perform()
    local current = self.character:getTile()

    assert( self.target:isAdjacent( current ), 'Character has to be adjacent to the target tile!' )

    current:removeCharacter()
    self.target:setCharacter( self.character )
    self.character:setTile( self.target )

    Messenger.publish( 'SOUND_CLIMB' )
    return true
end

return ClimbOver
