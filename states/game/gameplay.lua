local module = {}

local score = 0
local timer
local nbHostagesToRecues
local hostageImage
local timerImage

local camera, level
function module.load(game)
    camera = game.Camera
    level = game.Level

    -- Init the timer from the level
    timer = level.mapData.properties.timer
    nbHostagesToRecues = #level.mapData.layers[4].objects

    -- Init the images
    timerImage = love.graphics.newImage('assets/images/misc/clock.png')
    hostageImage = love.graphics.newImage('assets/images/misc/soldier.png')

end

function module.rescueHostage()
    nbHostagesToRecues = nbHostagesToRecues -1

    if nbHostagesToRecues == 0 then
        GameState.setState('level-win')
    end
end

function module.update(dt)
    timer = timer - dt

    if timer <= 0 then
        GameState.setState('game-over')
    end
end

function module.timerInMinutes()
    local seconds = math.ceil(timer)
    return math.floor(seconds / 60) .. ':' .. seconds % 60
end

function module.draw()
    love.graphics.draw(timerImage, camera:getRelativePosition(20, 20))
    love.graphics.print(module.timerInMinutes(), camera:getRelativePosition(60, 25))
    love.graphics.draw(hostageImage, camera:getRelativePosition(20, 70))
    love.graphics.print(nbHostagesToRecues, camera:getRelativePosition(60, 80))
end

return module
