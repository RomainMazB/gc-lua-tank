local gameNamespace = 'states.game.'
physics = require(gameNamespace..'physics')

game = {}
game.Sounds = require(gameNamespace..'sounds')
game.Projectiles = require(gameNamespace..'projectiles')
game.Level = require(gameNamespace..'level')
game.Enemies = require(gameNamespace..'enemies')
game.Hostages = require(gameNamespace..'hostages')
game.Controls = require(gameNamespace..'controls')
game.Player = require(gameNamespace..'player')
game.Collisions = require(gameNamespace..'collisions')
game.Camera = require(gameNamespace..'camera')
game.Pathfinding = require(gameNamespace..'pathfinding')
game.Gameplay = require(gameNamespace..'gameplay')

local function load(level)
    game.Level.load(game, 1)
    game.Player.load(game)
    game.Projectiles.load(game)
    game.Enemies.load(game)
    game.Hostages.load(game)
    game.Controls.load(game)
    game.Collisions.load(game)
    game.Gameplay.load(game)
    game.Sounds.load(game)
    game.Camera.load(game)

    -- Change the cursor by the crosshair
    local crosshairCursor = love.mouse.newCursor('assets/images/crosshair.png', game.Controls.doubleCrosshair.width /2, game.Controls.doubleCrosshair.height /2)
    love.mouse.setCursor(crosshairCursor)
end

local function update(dt)
    if not game.Level.isPaused then
        game.Controls.handleKeyboardControls(dt)
        game.Controls.handleMouseControls(dt)
        game.Player.update(dt)
        game.Projectiles.update(dt)
        game.Enemies.update(dt)
        game.Hostages.update(dt)
        game.Collisions.update(dt)
        game.Gameplay.update(dt)
        game.Camera.update(dt)
    end
end

local function draw()
    game.Camera:set()

    game.Level.draw()
    game.Player.draw()
    game.Enemies.draw()
    game.Hostages.draw()
    game.Projectiles.draw()
    game.Controls.draw()
    game.Gameplay.draw()

    game.Camera:unset()
end

local function mousepressed(x, y, button)
    game.Controls.mousepressed(x, y, button)
end

local function keypressed(key)
    if key == 'escape' then
        GameState.setState('menu')
    end
end

-- Cleanup data on gamestate destroy
local function destroy()
    game = {}
end

-- Register the game state methods
return {
    love_load = load,
    love_update = update,
    love_draw = draw,
    love_mousepressed = mousepressed,
    love_keypressed = keypressed,
    love_destroy = destroy
}