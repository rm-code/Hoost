local StorageSlot = require( 'src.inventory.StorageSlot' );

local EquipmentSlot = {};

function EquipmentSlot.new( itemType )
    local self = StorageSlot.new():addInstance( 'EquipmentSlot' );

    function self:getItemType()
        return itemType;
    end

    return self;
end

return EquipmentSlot;