local Projectile = require( 'src.items.weapons.Projectile' );
local Messenger = require( 'src.Messenger' );
local Queue = require( 'src.Queue' );

local ProjectileManager = {};

local projectileQueue = Queue.new();
local projectiles = {};
local id = 0;
local timer = 0;

---
-- Removes a projectile from the world and hits a tile with the projectile
-- damage.
-- @param index      (number)     The index of the projectile to remove.
-- @param tile       (Tile)       The tile to hit.
-- @param projectile (Projectile) The projectile to remove.
--
local function hitTile( index, tile, projectile )
    projectiles[index] = nil;
    tile:hit( projectile:getDamage() );
end

local function spawnProjectile()
    id = id + 1;
    projectiles[id] = projectileQueue:dequeue();
    Messenger.publish( 'SOUND_SHOOT' );
    return projectiles[id];
end

function ProjectileManager.update( dt, map )
    timer = timer - dt;
    if timer < 0 and not projectileQueue.isEmpty() then
        local projectile = spawnProjectile();
        timer = projectileQueue.isEmpty() and 0 or 1 / projectile:getWeapon():getShots();
    end

    for i, projectile in pairs( projectiles ) do
        projectile:update( dt );

        local tile = map:getTileAt( projectile:getTilePosition() );
        if projectile:getTile() ~= tile then
            projectile:setTile( tile );

            if not tile then
                print( "Reached map border" );
                projectiles[i] = nil;
            elseif tile:hasWorldObject() then
                if love.math.random( 0, 100 ) < tile:getWorldObject():getSize() then
                    print( "Hit impassable tile" );
                    hitTile( i, tile, projectile );
                end
            elseif tile == projectile:getTarget() then
                print( "Reached target" );
                hitTile( i, tile, projectile );
            elseif tile:isOccupied() and tile:getCharacter() ~= projectile:getCharacter() then
                print( "Hit character" );
                hitTile( i, tile, projectile );
            end
        end
    end
end

function ProjectileManager.iterate( callback )
    for _, projectile in pairs( projectiles ) do
        callback( projectile:getPosition() );
    end
end

function ProjectileManager.register( character, origin, target, angle )
    projectileQueue:enqueue( Projectile.new( character, origin, target, angle ));
end

function ProjectileManager.isDone()
    local count = 0;
    for _, _ in pairs( projectiles ) do
        count = count + 1;
    end
    return projectileQueue.isEmpty() and count == 0;
end

return ProjectileManager;
