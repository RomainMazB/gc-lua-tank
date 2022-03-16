return function (gui, x, y, w, h)
    local element = gui.newElement(x, y)
    element.w = w
    element.h = h
    element.image = nil
    element.sections = {}

    function element:setImage(image, top_size, bottom_size, left_size, right_size)
        -- These conditions allows signature polymorphism
        -- Signature: (image, borders_size)
        if bottom_size == nil then
            bottom_size = top_size
            left_size = top_size
            right_size = top_size

        -- Signature: (image, left_and_right_size, top_and_bottom_size)
        elseif left_size == nil then
            left_size = bottom_size
            right_size = bottom_size
            bottom_size = top_size
        end

        self.image = image

        -- Calculate all the 9-sliced quads to make the panel extensible
        local imageWidth = image:getWidth()
        local imageHeight = image:getHeight()
        local imageRepeatW = imageWidth - left_size - right_size
        local imageRepeatH = imageHeight - top_size - bottom_size
        local bottomY = imageHeight - bottom_size
        local rightX = imageWidth - right_size
        local panelRepeatW = self.w - left_size - right_size
        local panelRepeatH = self.h - top_size - bottom_size

        self.sections.top_left_corner = {
            quad = love.graphics.newQuad(0, 0, left_size, top_size, self.image),
            x = 0,
            y = 0,
            scaleX = 1,
            scaleY = 1
        }
        self.sections.bottom_left_corner = {
            quad = love.graphics.newQuad(0, bottomY, left_size, bottom_size, self.image),
            x = 0,
            y = self.h - bottom_size,
            scaleX = 1,
            scaleY = 1
        }
        self.sections.top_right_corner = {
            quad = love.graphics.newQuad(rightX, 0, right_size, top_size, self.image),
            x = self.w - right_size,
            y = 0,
            scaleX = 1,
            scaleY = 1
        }
        self.sections.bottom_right_corner = {
            quad = love.graphics.newQuad(rightX, bottomY, right_size, bottom_size, self.image),
            x = self.w - right_size,
            y = self.h - bottom_size,
            scaleX = 1,
            scaleY = 1
        }
        self.sections.top = {
            quad = love.graphics.newQuad(left_size, 0, imageRepeatW, top_size, self.image),
            x = left_size,
            y = 0,
            scaleX = panelRepeatW / imageRepeatW,
            scaleY = 1
        }
        self.sections.bottom = {
            quad = love.graphics.newQuad(left_size, bottomY, imageRepeatW, bottom_size, self.image),
            x = left_size,
            y = self.h - bottom_size,
            scaleX = panelRepeatW / imageRepeatW,
            scaleY = 1
        }
        self.sections.right = {
            quad = love.graphics.newQuad(rightX, top_size, right_size, imageRepeatH, self.image),
            x = self.w - right_size,
            y = top_size,
            scaleX = 1,
            scaleY = panelRepeatH / imageRepeatH
        }
        self.sections.left = {
            quad = love.graphics.newQuad(0, top_size, left_size, imageRepeatH, self.image),
            x = 0,
            y = top_size,
            scaleX = 1,
            scaleY = panelRepeatH / imageRepeatH
        }
        self.sections.filling = {
            quad = love.graphics.newQuad(left_size, top_size, imageRepeatW, imageRepeatH, self.image),
            x = left_size,
            y = top_size,
            scaleX = panelRepeatW / imageRepeatW,
            scaleY = panelRepeatH / imageRepeatH
        }
    end

    function element:update(dt)
        self:updateElement(dt)
    end

    function element:drawPanel()

        -- If no image was set, just draw a white rectangle line
        if self.image == nil then
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

        -- Else display each calculated quads of the image
        else
            for _,section in pairs(self.sections) do
                love.graphics.draw(self.image, section.quad, self.x + section.x, self.y + section.y, 0, section.scaleX, section.scaleY)
            end
        end
    end

  function element:draw()
    if self.visible then
        self:drawPanel()
    end
  end

  return element
end