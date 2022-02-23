love.window.setFullscreen(true)

Screen = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}

HALF_PI = math.pi/2

Sounds = require("sounds")
Ts_objects = require("ts_objects")
Ts_map = require("ts_map")
Projectiles = require("projectiles")
Enemies = require("enemies")

Game = require("game")
Controls = require("controls")
Player = require("player")
Collisions = require("collisions")
Camera = require("camera")
Pathfinding = require("pathfinding")
local beginMapYOffset = -MAP_HEIGHT * TILE_SIZE + Screen.height

function love.load()
    Ts_objects.load()
    Ts_map.load()
    Game.load()
    Player.load()
    Collisions.load()
    Enemies.load()

    -- Center the map vertically and put the camera at the bottom of the map
    Camera:setPosition((Screen.width - MAP_WIDTH * TILE_SIZE) / 2, beginMapYOffset)

    -- Change the cursor by the crosshair
    local crosshairCursor = love.mouse.newCursor("assets/images/crosshair.png", Controls.doubleCrosshair.width /2, Controls.doubleCrosshair.height /2)
    love.mouse.setCursor(crosshairCursor)
end

function love.draw()
    Camera:set()

    Game.draw()
    Collisions.draw()
    Projectiles.draw()
    Player.draw()
    Enemies.draw()
    Controls.draw()

    Camera:unset()
end

function love.update(dt)
    if Game.isRunning and not Game.isPaused then
        Controls.handleKeyboardControls(dt)
        Controls.handleMouseControls(dt)
        Player.update(dt)
        Projectiles.update(dt)
        Enemies.update(dt)
        Collisions.update(dt)

        -- Center the camera on the player with a min value fixed at the top and max at the bottom of the map
        local midScreenY = Screen.height / 2
        local y = math.min(0, math.max(midScreenY - Player.y, beginMapYOffset))

        Camera:setPosition(Camera.x, y)
    end
end
