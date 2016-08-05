local Messenger = require( 'src.Messenger' );

local SoundManager = {};

local SOUNDS = {}

---
-- Stops a source if it is currently playing.
-- @param source (Source) The source to stop.
-- @return       (Source) The stopped source.
--
local function stopBeforePlaying( source )
    if source:isPlaying() then
        source:stop();
    end
    return source;
end

function SoundManager.loadResources()
    SOUNDS.DOOR           = love.audio.newSource( 'res/sounds/door.wav' );
    SOUNDS.SELECT         = love.audio.newSource( 'res/sounds/select.wav' );
    SOUNDS.ASSAULT_RIFLE  = love.audio.newSource( 'res/sounds/ar.wav' );
    SOUNDS.SUBMACHINE_GUN = love.audio.newSource( 'res/sounds/smg.wav' );
    SOUNDS.CLIMB          = love.audio.newSource( 'res/sounds/climb.wav' );
end

Messenger.observe( 'ACTION_DOOR', function()
    love.audio.play( SOUNDS.DOOR );
end)

Messenger.observe( 'SOUND_CLIMB', function()
    love.audio.play( SOUNDS.CLIMB );
end)

Messenger.observe( 'SOUND_SHOOT', function( weapon )
    if weapon:getWeaponType() == 'Assault Rifle' then
        love.audio.play( stopBeforePlaying( SOUNDS.ASSAULT_RIFLE ));
    elseif weapon:getWeaponType() == 'Submachine Gun' then
        love.audio.play( stopBeforePlaying( SOUNDS.SUBMACHINE_GUN ));
    end
end)

Messenger.observe( 'SWITCH_CHARACTERS', function()
    love.audio.play( SOUNDS.SELECT );
end)

return SoundManager;
