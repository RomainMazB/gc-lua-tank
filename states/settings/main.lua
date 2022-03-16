local function love_load()
    print('settings')
end

local function keypressed(key)
    GameState.setState('menu')
end

return {
    love_load = love_load,
    love_keypressed = keypressed
}