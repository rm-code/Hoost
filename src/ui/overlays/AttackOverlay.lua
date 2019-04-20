---
-- @module AttackOverlay
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Bresenham = require( 'lib.Bresenham' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local AttackInput = require( 'src.turnbased.helpers.AttackInput' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local AttackOverlay = Class( 'AttackOverlay' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function AttackOverlay:initialize( game, pulser, camera )
    self.game = game
    self.map = game:getMap()
    self.pulser = pulser
    self.camera = camera

    self.attackPath = {}
    self.tileset = TexturePacks.getTileset()
    self.tw, self.th = self.tileset:getTileDimensions()
end

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function drawLine( self, character, target )
    local origin = character:getTile()
    local px, py = origin:getPosition()
    local tx, ty = target:getPosition()

    -- Each tile in the path can have one of the following statuses.
    --   => 1 means the projectile can pass freely.
    --   => 2 means the projectile might be blocked by a world object or character.
    --   => 3 means the projectile will be blocked by a world object.
    local status = 1
    Bresenham.line( px, py, tx, ty, function( sx, sy )
        local tile = self.map:getTileAt( math.floor( sx + 0.5 ), math.floor( sy + 0.5 ))

        -- Ignore origin.
        if tile == origin then
            return true
        end

        if tile:hasCharacter() or not character:canSee( tile ) then
            status = math.max( status, 2 )
        elseif tile:hasWorldObject() then
            status = math.max( tile:getWorldObject():isDestructible() and 2 or 3 )
        end

        self.attackPath[tile] = status
        return true
    end)
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function AttackOverlay:generate()
    -- Exit early if we aren't in the attack input mode.
    if not self.game:getState():getInputMode():isInstanceOf( AttackInput ) then
        return
    end

    -- Exit early if the character doesn't have a weapon or the weapon is
    -- of type melee.
    local weapon = self.game:getCurrentCharacter():getWeapon()
    if not weapon or weapon:getSubType() == WEAPON_TYPES.MELEE then
        return
    end

    -- Exit early if we don't have a valid target at the mouse position or
    -- if the target hasn't changed since the last frame.
    local cx, cy = self.camera:getMouseWorldGridPosition()
    local target = self.map:getTileAt( cx, cy )
    if not target then
        return
    end

    drawLine( self, self.game:getCurrentCharacter(), target )
end

function AttackOverlay:draw()
    for tile, status in pairs( self.attackPath ) do
        local color
        if status == 1 then
            color = TexturePacks.getColor( 'ui_shot_valid' )
        elseif status == 2 then
            color = TexturePacks.getColor( 'ui_shot_potentially_blocked' )
        elseif status == 3 then
            color = TexturePacks.getColor( 'ui_shot_blocked' )
        end
        love.graphics.setColor( color[1], color[2], color[3], self.pulser:getPulse() )
        love.graphics.rectangle( 'fill', tile:getX() * self.tw, tile:getY() * self.th, self.tw, self.th )

        self.attackPath[tile] = nil
    end
    TexturePacks.resetColor()
end

return AttackOverlay
