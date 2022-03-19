io.stdout:setvbuf("no")

-- Add some useful but missing method to math native library
math.half_pi = math.pi/2

Screen = {
    width = 0,
    height = 0,
    midWidth = 0,
    midHeight = 0
}

-- Globally register the utilities modules
GameState = require 'gamestate'
Animation = require 'animation'
Gui = require 'gui.main'
require 'math-extended'

function love.load()
    -- Setup the OS window
    -- love.window.setFullscreen(true)
    love.window.setTitle('Battle Tank')
    love.window.setIcon(love.image.newImageData('assets/images/crosshair.png'))

    -- Setup the screen dimension
    Screen.width = love.graphics.getWidth()
    Screen.height = love.graphics.getHeight()
    Screen.midWidth = Screen.width/2
    Screen.midHeight = Screen.height/2

    -- Initialize the gamestates manager
    GameState.registerStates('menu', 'settings', 'init-game', 'game', 'game-over', 'level-win')
    GameState.setState('menu')
end
