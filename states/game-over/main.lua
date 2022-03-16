local gameOverText

local function love_load()
    local font = love.graphics.newFont('assets/fonts/kenney_pixel_square.ttf', 50)
    gameOverText = Gui.text(0, 0, Screen.width, Screen.height, "GAME OVER", font, "center", "center")
end

local function love_draw()
    gameOverText:draw()
end

local function keypressed(key)
    GameState.setState('menu')
end

return {
    love_load = love_load,
    love_draw = love_draw,
    love_keypressed = keypressed
}