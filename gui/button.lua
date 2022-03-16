local handCursor = love.mouse.getSystemCursor("hand")

return function (gui, x, y, w, h, text, font, color)
    -- Button is just a panel with a label and mouse events!
    local element = gui.panel(x, y, w, h)
    element.text = text
    element.font = font
    element.label = gui.text(x, y, w, h, text, font, "center", "center", color)
    element.isPressed = false
    element.hoverImg = nil
    element.pressedImg = nil
    element.lastClickDt = 0
    element.hoverImgIsSameAsDefaultImg = false
    element.oldButtonState = false
    element.oldHoverState = false
    element.oldPressedState = false

    -- Return the position of the mouse relatively to the button
    function element:getRelativeMousePosition()
        return love.mouse.getX() - self.x, self.y - love.mouse.getY()
    end

    -- Set the button images, the defaultImg one is mandatory, hoverImg and pressedImg state are optional
    function element:setImages(defaultImg, hoverImg, pressedImg, top_size, bottom_size, left_size, right_size)
        -- These conditions allows signature polymorphism
        -- Signature: (image, borders_size)
        if 'number' == type(hoverImg) and pressed == nil then
            self:setImage(defaultImg, hoverImg)
            self.hoverImg = defaultImg
            self.pressedImg = defaultImg
            self.hoverImgIsSameAsDefaultImg = true

        -- Signature: (image, top_size, bottom_size, left_size, right_size)
        elseif 'number' == type(pressed) and 'number' == type(hoverImg) then
            self:setImage(defaultImg, hoverImg, pressedImg, top_size, bottom_size)
            self.hoverImg = defaultImg
            self.pressedImg = defaultImg
            self.hoverImgIsSameAsDefaultImg = true

        -- Signature: (defaultImg, hoverImg, top_size, bottom_size, left_size, right_size)
        elseif 'number' == type(hoverImg) then
            self:setImage(defaultImg, top_size, bottom_size, left_size, right_size)
            self.hoverImg = hoverImg
            self.pressedImg = hoverImg

        -- Signature: (defaultImg, hoverImg, pressedImg, top_size, bottom_size, left_size, right_size)
        else
            self:setImage(defaultImg, pressedImg, top_size, bottom_size, left_size)
            self.hoverImg = hoverImg
            self.pressedImg = pressedImg
        end
    end

    function element:update(dt)
        local mouseLeftButtonIsDown = love.mouse.isDown(1)
        local mouseLeftButtonIsUp = not mouseLeftButtonIsDown

        -- Call updateElement to update the isHover property
        self:updateElement(dt)

        -- If the previous button's state was pressed and the mouse is now up
        if self.isPressed and mouseLeftButtonIsUp then
            -- Fire the `mouseup` event
            if self.eventsLst["mouseup"] ~= nil then
                self.eventsLst["mouseup"](self:getRelativeMousePosition())
            end
        end

        -- If the button is hover and the mouse is down
        if self.isHover and mouseLeftButtonIsDown and
            self.isPressed == false and
            self.oldButtonState == false then

            self.isPressed = true

            -- Fire the `mousedown` event
            if self.eventsLst["mousedown"] ~= nil then
                self.eventsLst["mousedown"](self:getRelativeMousePosition())
            end

        -- If the button is hover BUT the mouse is up
        elseif self.isHover and mouseLeftButtonIsUp and
                self.isPressed and
                self.oldButtonState then

                self.isPressed = false

                -- Fire the `click` event
                -- TODO: Maybe this should not be called when dblClick is fired on the same frame?
                if self.eventsLst["click"] ~= nil then
                    self.eventsLst["click"](self:getRelativeMousePosition())
                end

                -- Measure the time between two clicks
                local currentTime = love.timer.getTime()
                if currentTime - self.lastClickDt < 0.5 then
                    -- Fire the `dblClick` event
                    if self.eventsLst["dblClick"] ~= nil then
                        self.eventsLst["dblClick"](self:getRelativeMousePosition())
                    end
                end
                self.lastClickDt = currentTime

        -- If the current button state is pressed BUT the mouse is now up
        elseif self.isPressed == true and mouseLeftButtonIsUp then
            -- Switch the isPressed state to false to catch
            self.isPressed = false
        end

        local currentCursor = love.mouse.getCursor()
        -- If the button is hover or pressed, change the cursor from arrow to hand
        if currentCursor == nil and (self.isHover or self.isPressed) then
            love.mouse.setCursor(handCursor)

        -- Else check if the handcursor needs to be released
        -- Conditions needed:
        --      - handCursor is active, the button is not pressed and it just lost the hover state
        --      - OR button was pressed but is not anymore
        elseif (currentCursor == handCursor and not self.isPressed and self.oldHoverState ~= self.isHover)
            or (self.oldPressedState and self.oldPressedState ~= self.isPressed) then
            love.mouse.setCursor()
        end

        self.oldButtonState = mouseLeftButtonIsDown
        self.oldPressedState = self.isPressed
        self.oldHoverState = self.isHover
    end

    function element:draw()
        -- Pressed state
        if self.isPressed then

            -- Push the current graphic state on pressed state to ease (image + label) offsetting
            love.graphics.push()
            love.graphics.translate(2, 2)

            -- If no image was provided for the pressed state, draw a fulfilled rectangle
            if self.pressedImg == nil then
                self:drawPanel()
                -- When the button is pressed, we put an 2pixels offset on the button to make the image appear "pressed"
                love.graphics.setColor(1, 1, 1, 50)
                love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

            -- Else draw the pressed image
            else
                -- Store the defaultImg button image and swap it to the pressed state image
                -- to not recalculate the quads from panel:draw method
                local storedImage = self.image;
                self.image = self.pressedImg
                self:drawPanel()

                -- Restore the defaultImg image
                self.image = storedImage
            end

        -- Hover state
        elseif self.isHover then

            -- If no image was provided for the hover state, draw a rectangle
            if self.hoverImg == nil then
                self:drawPanel()
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", self.x+2, self.y+2, self.w-4, self.h-4)

            -- Else draw the hover image
            else
                -- Store the defaultImg button image and swap it to the hover state image
                -- to not recalculate the quads from herited panel:draw method
                local storedImage = self.image;
                self.image = self.hoverImg
                self:drawPanel()

                -- Restore the defaultImg image
                self.image = storedImage
            end

        -- Native state, just draw the panel defaultImg image
        else
            self:drawPanel()
        end

        -- Last but not least, draw the label!

        -- If the current button's state doesn't have an image, a gray/white button will be drawn
        -- Change the label text color to black!
        if (self.isPressed and self.pressedImg == nil) or (self.isHover and self.hoverImg == nil) then
            love.graphics.setColor(.1, .1, .1)
        end

        self.label:draw()

        -- Restore the initial graphic state if modified
        if self.isPressed then
            love.graphics.pop()
        end
    end

    return element
end