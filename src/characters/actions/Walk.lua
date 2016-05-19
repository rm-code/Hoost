local Action = require('src.characters.actions.Action');

local Walk = {};

function Walk.new( character, target )
    local self = Action.new( target:getMovementCost() ):addInstance( 'Walk' );

    function self:perform()
        local current = character:getTile();

        assert( target:isPassable(), 'Target tile has to be passable!' );
        assert( not target:isOccupied(), 'Target tile must not be occupied by another character!' );
        assert( target:isAdjacent( current ), 'Character has to be adjacent to the target tile!' );

        -- Remove the character from the old tile, add it to the new one and
        -- give it a reference to the new tile.
        current:removeCharacter();
        target:addCharacter( character );
        character:setTile( target );
    end

    return self;
end

return Walk;
