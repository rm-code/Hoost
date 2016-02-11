local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Tile = {};

function Tile.new( x, y, worldObject )
    local self = Object.new():addInstance( 'Tile' );

    self:validateType( 'number', x );
    self:validateType( 'number', y );

    local id;
    local dirty;
    local neighbours;
    local character;    -- Each tiles can hold one game character.
    local visible;
    local explored;

    function self:removeCharacter()
        character = nil;
        self:setDirty( true );
    end

    function self:setDirty( ndirty )
        dirty = ndirty;
    end

    function self:setID( nid )
        id = nid;
    end

    function self:setNeighbours( nneighbours )
        neighbours = nneighbours;
    end

    function self:isAdjacent( tile )
        for _, neighbour in pairs( neighbours ) do
            if neighbour == tile then
                return true;
            end
        end
    end

    function self:isDirty()
        return dirty;
    end

    function self:getID()
        return id;
    end

    function self:getNeighbours()
        return neighbours;
    end

    function self:getPosition()
        return x, y;
    end

    function self:getX()
        return x;
    end

    function self:getY()
        return y;
    end

    function self:getWorldObject()
        return worldObject;
    end

    function self:getCharacter()
        return character;
    end

    function self:isOccupied()
        return character ~= nil;
    end

    function self:setCharacter( nchar )
        character = nchar;
        self:setDirty( true );
    end

    function self:setVisible( nvisible )
        visible = nvisible;
    end

    function self:setExplored( nexplored )
        explored = nexplored;
    end

    function self:isExplored()
        return explored;
    end

    function self:isVisible()
        return visible;
    end

    return self;
end

return Tile;