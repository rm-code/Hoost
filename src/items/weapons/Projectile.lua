local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Projectile = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DEFAULT_SPEED = 30;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new Projectile.
-- @param character  (Character)         The character this projectile belongs to.
-- @param tiles      (table)             A sequence containing all tiles this projectile will pass.
-- @param damage     (number)            The damage this projectile deals.
-- @param damageType (string)            The type of damage the tile is hit with.
-- @param effects    (AmmunitionEffects) An object containing different effects associated with ammunition.
-- @return           (Projectile)        A new instance of the Projectile class.
--
function Projectile.new( character, tiles, damage, damageType, effects )
    local self = Object.new():addInstance( 'Projectile' );

    local energy = 100;
    local timer = 0;
    local index = 1;
    local tile = character:getTile();
    local previousTile;
    local speed = effects:hasCustomSpeed() and effects:getCustomSpeed() or DEFAULT_SPEED;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( dt )
        timer = timer + dt * speed;
        if timer > 1 and index < #tiles then
            index = index + 1;
            timer = 0;
        end

        if effects:hasCustomSpeed() then
            speed = math.min( speed + effects:getSpeedIncrease(), effects:getFinalSpeed() );
        end
    end

    function self:updateTile( map )
        previousTile = tile;
        tile = map:getTileAt( tiles[index].x, tiles[index].y );
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getCharacter()
        return character;
    end

    function self:getEffects()
        return effects;
    end

    function self:getDamage()
        return damage;
    end

    function self:getDamageType()
        return damageType;
    end

    function self:getEnergy()
        return energy;
    end

    function self:getTile()
        return tile;
    end

    function self:getPreviousTile()
        return previousTile;
    end

    function self:hasMoved( map )
        return tile ~= map:getTileAt( tiles[index].x, tiles[index].y );
    end

    function self:hasReachedTarget()
        return #tiles == index;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setEnergy( nenergy )
        energy = nenergy;
    end

    return self;
end

return Projectile;
