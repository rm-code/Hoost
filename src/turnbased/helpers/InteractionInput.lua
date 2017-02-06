local State = require( 'src.turnbased.states.State' );
local Log = require( 'src.util.Log' );
local Open = require( 'src.characters.actions.Open' );
local Close = require( 'src.characters.actions.Close' );
local OpenInventory = require( 'src.characters.actions.OpenInventory' );

local InteractionInput = {};

function InteractionInput.new()
    local self = State.new():addInstance( 'InteractionInput' );

    function self:request( ... )
        local target, character = ...;

        if not target:isAdjacent( character:getTile() ) then
            return false;
        end

        if target:hasWorldObject() then
            if target:getWorldObject():isOpenable() then
                if target:isPassable() then
                    character:enqueueAction( Close.new( character, target ));
                else
                    character:enqueueAction( Open.new( character, target ));
                end
                return true;
            elseif target:getWorldObject():isContainer() then
                character:enqueueAction( OpenInventory.new( character, target ));
                return true;
            end
        elseif target:isOccupied() then
            if target:getCharacter():getFaction():getType() == character:getFaction():getType() then
                Log.info( target:getCharacter():getFaction():getType(), character:getFaction():getType())
                character:enqueueAction( OpenInventory.new( character, target ));
                return true;
            end
        end

        return false;
    end

    return self;
end

return InteractionInput;
