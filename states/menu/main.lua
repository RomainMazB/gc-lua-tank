local menu = {
    splashImage = nil,
    panelGroup = {}
}

local function load()
    local buttonImage = love.graphics.newImage('assets/images/gui/panel_boltsDetail.png')
    local font = love.graphics.newFont('assets/fonts/kenney_pixel_square.ttf')
    menu.splashImage = love.graphics.newImage('assets/images/menu_splash.png')

    -- Define the buttons text and click callback
    local buttons = {
        {
            text = 'Play',
            callback = function () GameState.setState('init-game') end
        },
        {
            text = 'Settings',
            callback = function () GameState.setState('settings') end
        },
        {
            text = 'Quit',
            callback = function () love.event.quit() end
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
    menu.panelGroup = Gui.group(Screen.midWidth - panelWidth/2, Screen.midHeight - panelHeight/2)

    -- Panel
    local panel = menu.panelGroup:panel(0, 0, panelWidth, panelHeight)
    panel:setImage(love.graphics.newImage('assets/images/gui/panel_woodPaperDetailSquare.png'), 31, 31, 31, 31)

    -- Loop through all the buttons to create them
    for i, button in pairs(buttons) do
        local btn = menu.panelGroup:button(
            panelWidth/2 - 100, panelPadding + (buttonHeight + buttonSpacing)* (i-1),
            200, buttonHeight,
            button.text, font
        )
        btn:setImages(buttonImage, 17, 17, 17, 17)
        btn:setEvent('click', button.callback)
    end
end

local function keypressed(key)
    if (key == 'escape') then
        love.event.quit()
    end
end

local function update(dt)
    menu.panelGroup:update(dt)
end

local function draw()
    love.graphics.draw(menu.splashImage, Screen.midWidth, Screen.midHeight, 0, 1, 1, menu.splashImage:getWidth()/2, menu.splashImage:getHeight()/2)
    menu.panelGroup:draw()
end

-- Register the game state methods
return {
    love_load = load,
    love_keypressed = keypressed,
    love_update = update,
    love_draw = draw
}