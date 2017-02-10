local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTHasRangedWeapon = {};

local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

function BTHasRangedWeapon.new()
    local self = BTLeaf.new():addInstance( 'BTHasRangedWeapon' );

    function self:traverse( ... )
        local _, character = ...;

        local result = character:getWeapon():getWeaponType() == WEAPON_TYPES.RANGED;
        Log.debug( result, 'BTHasRangedWeapon' );
        return result;
    end

    return self;
end

return BTHasRangedWeapon;
