local FactionManager = require( 'src.characters.FactionManager' );
local Pulser = require( 'src.util.Pulser' );
local MousePointer = require( 'src.ui.MousePointer' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local OverlayPainter = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates an new instance of the OverlayPainter class.
-- @return (OverlayPainter) The new instance.
--
function OverlayPainter.new()
    local self = {};

    local pulser = Pulser.new( 4, 80, 80 );

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Draws a line from the character to a selected target.
    -- @param character (Character) The character to draw the LOS for.
    --
    local function drawLineOfSight( character )
        if character:hasLineOfSight() then
            love.graphics.setBlendMode( 'add' );
            character:getLineOfSight():iterate( function( tile )
                love.graphics.setColor( COLORS.DB09[1], COLORS.DB09[2], COLORS.DB09[3], pulser:getPulse() );
                if not tile:isPassable() or not character:canSee( tile ) then
                    love.graphics.setColor( COLORS.DB27[1], COLORS.DB27[2], COLORS.DB27[3], pulser:getPulse() );
                end
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );
            end)
            love.graphics.setColor( 255, 255, 255, 255 );
            love.graphics.setBlendMode( 'alpha' );
        end
    end

    ---
    -- Selects a color for the node in a path based on the distance to the
    -- target and the remaining action points the character has.
    -- @param value (number) The cost of the node.
    -- @param total (number) The total number of nodes in the path.
    --
    local function selectPathNodeColor( value, total )
        local fraction = value / total;
        if fraction < 0 then
            return COLORS.DB27;
        elseif fraction <= 0.2 then
            return COLORS.DB05;
        elseif fraction <= 0.6 then
            return COLORS.DB08;
        elseif fraction <= 1.0 then
            return COLORS.DB09;
        end
    end

    ---
    -- Draws a path for this character.
    -- @param character (Character) The character to draw the path for.
    --
    local function drawPath( character )
        if #character:getActions() ~= 0 then
            local total = character:getActionPoints();
            local ap = total;

            for _, action in ipairs( character:getActions() ) do
                ap = ap - action:getCost();

                -- Clears the tile.
                local tile = action:getTarget();

                -- Draws the path overlay.
                love.graphics.setBlendMode( 'add' );
                local color = selectPathNodeColor( ap, character:getMaxActionPoints() );
                love.graphics.setColor( color[1], color[2], color[3], pulser:getPulse() );
                love.graphics.rectangle( 'fill', tile:getX() * TILE_SIZE, tile:getY() * TILE_SIZE, TILE_SIZE, TILE_SIZE );
                love.graphics.setColor( 255, 255, 255, 255 );
                love.graphics.setBlendMode( 'alpha' );
            end
        end
    end

    ---
    -- Draws a mouse cursor that snaps to the grid.
    --
    local function drawMouseCursor()
        local mx, my = MousePointer.getWorldPosition();
        local cx, cy = math.floor( mx / TILE_SIZE ) * TILE_SIZE, math.floor( my / TILE_SIZE ) * TILE_SIZE;

        love.graphics.setBlendMode( 'add' );
        love.graphics.setColor( COLORS.DB19[1], COLORS.DB19[2], COLORS.DB19[3], pulser:getPulse() );
        love.graphics.rectangle( 'fill', cx, cy, TILE_SIZE, TILE_SIZE );
        love.graphics.setColor( 255, 255, 255, 255 );
        love.graphics.setBlendMode( 'alpha' );
    end

    ---
    -- Draws all projectiles queued up in the ProjectileManager.
    --
    local function drawProjectiles()
        ProjectileManager.iterate( function( x, y )
            love.graphics.setBlendMode( 'add' );
            love.graphics.setColor( COLORS.DB09[1], COLORS.DB09[2], COLORS.DB09[3], 180 );
            love.graphics.rectangle( 'fill', x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE );
            love.graphics.setColor( 255, 255, 255, 255 );
            love.graphics.setBlendMode( 'alpha' );
        end)
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:draw()
        local character = FactionManager.getCurrentCharacter();
        drawLineOfSight( character );
        drawPath( character );
        drawProjectiles();
        drawMouseCursor();
    end

    function self:update( dt )
        pulser:update( dt );
    end

    return self;
end

return OverlayPainter;
