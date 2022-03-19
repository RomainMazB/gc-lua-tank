local states = {
    current = nil,
    registeredStates = {}
}

local loveCallbacks = {
    -- General
    'displayrotated', 'draw', 'load', 'lowmemory', 'quit', 'run', 'update',

    -- Error handling, uncomment the next line only if you redefine them!
    -- 'errhand', 'errorhandler', 'threaderror',

    -- Window
    'directorydropped', 'filedropped', 'focus', 'mousefocus', 'resize', 'visible',

    -- Keyboard
    'keypressed', 'keyreleased', 'textedited', 'textinput',

    -- Mouse
    'mousemoved', 'mousepressed', 'mousereleased', 'wheelmoved',

    -- Joystick
    'gamepadaxis', 'gamepadpressed', 'gamepadreleased', 'joystickadded',
    'joystickaxis', 'joystickhat', 'joystickpressed', 'joystickreleased', 'joystickremoved',

    -- Touch
    'touchmoved', 'touchpressed', 'touchreleased'
}

local GAMESTATE_PREFIX = 'love_'
local prefixedStateLoveCallbacksName = {}

for _, loveCallbackName in pairs(loveCallbacks) do
    table.insert(prefixedStateLoveCallbacksName, GAMESTATE_PREFIX..loveCallbackName)
end

-- Reset all the love callbacks to an empty callback
local function clearLoveCallbacks()
    for _, loveCallback in pairs(loveCallbacks) do
        love[loveCallback] = function () end
    end
end

return {
    -- Verify the existence of a state and register it
    registerStates = function (...)
        for _,name in pairs({...}) do
            local path = "states/"..name.."/main"

            -- Verify that the path exists or crash
            if love.filesystem.getInfo(path..'.lua') == nil then
                error("Unable to register the \""..name.."\" gamestate. The file \""..path..".lua\" doesn't exist.")
            end

            if states.registeredStates[name] == nil then
                states.registeredStates[name] = require(path)
            end
        end
    end,

    -- Switch to another game state
    setState = function (name, ...)
        if not states.registeredStates[name] then
            error("Unable to the \""..name.."\" gamestate. Did you registered it correctly?")
        end

        -- Clear all the registered love native callbacks
        clearLoveCallbacks()

        -- If the current gamestate registered a "destroy" callback, call it
        if current and 'function' == type(states.registeredStates[current][GAMESTATE_PREFIX..'destroy']) then
            states.registeredStates[current][GAMESTATE_PREFIX..'destroy']()
        end

        -- For all the native callbacks:
        -- If the new gamestate redefine it, register the gamestate callback into the love natives
        for _, loveCallback in pairs(loveCallbacks) do
            if 'function' == type(states.registeredStates[name][GAMESTATE_PREFIX..loveCallback]) then
                love[loveCallback] = states.registeredStates[name][GAMESTATE_PREFIX..loveCallback]
            end
        end

        -- If the new gamestate registered a load function, call it
        if 'function' == type(states.registeredStates[name][GAMESTATE_PREFIX..'load']) then
            states.registeredStates[name][GAMESTATE_PREFIX..'load'](...)
        end

        current = name
    end
}