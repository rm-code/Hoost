local Object = require( 'src.Object' );
local Map = require( 'src.map.Map' );
local Factions = require( 'src.characters.Factions' );
local TurnManager = require( 'src.turnbased.TurnManager' );
local ItemFactory = require( 'src.items.ItemFactory' );
local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );
local SoundManager = require( 'src.SoundManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local SaveHandler = require( 'src.SaveHandler' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Game = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Game.new()
    local self = Object.new():addInstance( 'Game' );

    local map;
    local factions;
    local turnManager;
    local observations = {};

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        ItemFactory.loadTemplates();
        TileFactory.loadTemplates();
        WorldObjectFactory.loadTemplates();
        SoundManager.loadResources();

        map = Map.new();
        factions = Factions.new( map );
        factions:init();

        -- Load previously saved state or create new state.
        if SaveHandler.hasSaveFile() then
            local savegame = SaveHandler.load();
            savegame:loadMap( map );
            savegame:loadCharacters( map, factions );
        else
            map:init();
            factions:spawnCharacters();
        end

        turnManager = TurnManager.new( map, factions );

        ProjectileManager.init( map );
        ExplosionManager.init( map );

        -- Register obsersvations.
        observations[#observations + 1] = map:observe( self );

        -- Free memory if possible.
        collectgarbage( 'collect' );
    end

    function self:receive( event, ... )
        if event == 'TILE_UPDATED' then
            local tile = ...;
            assert( tile:instanceOf( 'Tile' ), 'Expected an object of type Tile.' );
            factions:getFaction():regenerateFOVSelectively( tile );
        end
    end

    function self:update( dt )
        map:update();
        turnManager:update( dt )
    end

    function self:getMap()
        return map;
    end

    function self:getFactions()
        return factions;
    end

    function self:keypressed( key )
        turnManager:keypressed( key );
        if key == '.' then
            -- TODO Optimisation!
            SaveHandler.save( map:serialize() );
            collectgarbage( 'collect' );
        end
    end

    function self:mousepressed( mx, my, button )
        turnManager:mousepressed( mx, my, button );
    end

    function self:getState()
        return turnManager:getState();
    end

    function self:getCurrentCharacter()
        return factions:getFaction():getCurrentCharacter();
    end

    return self;
end

return Game;
