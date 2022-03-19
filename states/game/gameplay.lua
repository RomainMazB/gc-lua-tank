local module = {
    isPaused = false
}

local timer
local hostageImage
local timerImage
local warningMessageText
local warningMessageTimer = 0
local warningMessageFont

local WARNING_SECONDS = 3

local camera, level, hero, hostagesLst
function module.load(game)
    camera = game.Camera
    level = game.Level
    hero = game.Player.hero
    hostagesLst = game.Hostages.hostagesLst

    -- Init the timer from the level
    timer = level.mapData.properties.timer

    -- Init the images
    timerImage = love.graphics.newImage('assets/images/misc/clock.png')
    hostageImage = love.graphics.newImage('assets/images/misc/soldier.png')

    -- Init the warningMessageFont
    warningMessageFont = love.graphics.newFont('assets/fonts/kenney_pixel_square.ttf', 25)

    -- Init the UI Canvas
    love.graphics.newCanvas()
end

function module.rescueHostage()
    if #hostagesLst == 0 then
        GameState.setState('level-win')
    end
end

function module.displayWarningMessage(message)
    -- Update the warning message only if different from the one actually displayed
    if not warningMessageText or message ~= warningMessageText.text then
        local x, y = camera:getRelativePosition(0, 0)
        warningMessageText = Gui.text(x, y, Screen.width, Screen.height, message, warningMessageFont, "center", "center")
        warningMessageTimer = WARNING_SECONDS
    end
end

function module.update(dt)
    timer = timer - dt
    if warningMessageTimer > 0 then
        warningMessageTimer = warningMessageTimer - dt
    elseif warningMessageText then
        warningMessageText = nil
    end

    if timer <= 0 or hero.life <= 0 then
        GameState.setState('game-over')
    end
end

function module.timerInMinutes()
    local timerInSeconds = math.ceil(timer)
    local minutes, seconds = math.floor(timerInSeconds / 60), timerInSeconds % 60
    return (minutes < 10 and '0'..minutes or minutes).. ':' .. (seconds < 10 and '0'..seconds or seconds)
end

function module.draw()
    love.graphics.draw(timerImage, camera:getRelativePosition(20, 20))
    love.graphics.print(module.timerInMinutes(), camera:getRelativePosition(60, 25))
    love.graphics.draw(hostageImage, camera:getRelativePosition(20, 70))
    love.graphics.print(#hostagesLst, camera:getRelativePosition(60, 80))

    if warningMessageTimer > 0 then
        warningMessageText.color = {1, 1, 1, 1 * warningMessageTimer / WARNING_SECONDS}
        warningMessageText:draw()
    end
end

function module.destroy()
    module.isPaused = false
end

return module
