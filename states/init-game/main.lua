local initGame = {
    splashImage = nil,
    panelGroup = {}
}

local function load()
    local buttonImage = love.graphics.newImage('assets/images/gui/panel_boltsDetail.png')
    local font = love.graphics.newFont('assets/fonts/kenney_pixel_square.ttf')
    initGame.splashImage = love.graphics.newImage('assets/images/menu_splash.png')

    -- Define the buttons text and click callback
    local buttons = {
        {
            text = 'Level 1',
            callback = function () GameState.setState('game', 1) end
        },
        {
            text = 'Level 2',
            callback = function () GameState.setState('game', 2) end
        },
        {
            text = 'Level 3',
            callback = function () GameState.setState('game', 3) end
        }
    }

    -- Calculate the needed panel size
    local nbButton = #buttons
    local buttonHeight = 45
    local panelWidth = 400
    local panelPadding = 40
    local buttonSpacing = 10
    local panelHeight = panelPadding * 2 + nbButton * buttonHeight + (nbButton-1) * buttonSpacing

    -- Group
    initGame.panelGroup = Gui.group(Screen.midWidth - panelWidth/2, Screen.midHeight - panelHeight/2)

    -- Panel
    local panel = initGame.panelGroup:panel(0, 0, panelWidth, panelHeight)
    panel:setImage(love.graphics.newImage('assets/images/gui/panel_woodPaperDetailSquare.png'), 31, 31, 31, 31)

    -- Loop through all the buttons to create them
    for i, button in pairs(buttons) do
        local btn = initGame.panelGroup:button(
            panelWidth/2 - 100, panelPadding + (buttonHeight + buttonSpacing)* (i-1),
            200, buttonHeight,
            button.text, font
        )
        btn:setImages(buttonImage, 17, 17, 17, 17)
        btn:setEvent('click', button.callback)
    end
end

local function update(dt)
    initGame.panelGroup:update(dt)
end

local function draw()
    love.graphics.draw(initGame.splashImage, Screen.midWidth, Screen.midHeight, 0, 1, 1, initGame.splashImage:getWidth()/2, initGame.splashImage:getHeight()/2)
    initGame.panelGroup:draw()
end

local function keypressed(key)
    if key == 'escape' then
        GameState.setState('menu')
    end
end

-- Register the game state methods
return {
    love_load = load,
    love_update = update,
    love_draw = draw,
    love_keypressed = keypressed
}