local Item = require( 'src.items.Item' );

local Clothing = {};

function Clothing.new( name, armor, type, clothingType )
    local self = Item.new( name, type ):addInstance( 'Clothing' );

    function self:getClothingType()
        return clothingType;
    end

    function self:isArmor()
        return armor ~= nil;
    end

    function self:getArmorProtection()
        return armor.protection;
    end

    function self:getArmorCoverage()
        return armor.coverage;
    end

    return self;
end

return Clothing;
