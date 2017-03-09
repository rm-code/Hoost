local Log = require( 'src.util.Log' );
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' );

local BTTakeItem = {};

function BTTakeItem.new()
    local self = BTLeaf.new():addInstance( 'BTTakeItem' );

    function self:traverse( ... )
        local blackboard, character = ...;
        local target = blackboard.target;

        local pinventory = character:getInventory();
        local tinventory = target:getInventory();

        local titems = tinventory:getItems();
        Log.debug( 'Found items: ' .. #titems, 'BTTakeItem' );

        for i = #titems, 1, -1 do
            local item = titems[i];

            Log.debug( 'Items left: ' .. #titems, 'BTTakeItem' );
            local success = pinventory:addItem( item );
            if success then
                tinventory:removeItem( item );
                Log.debug( 'Took item ' .. item:getID(), 'BTTakeItem' );
            else
                Log.debug( 'Didn\'t take item ' .. item:getID(), 'BTTakeItem' );
            end
        end

        return true;
    end

    return self;
end

return BTTakeItem;
