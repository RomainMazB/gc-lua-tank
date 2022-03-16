local module = {}

function module.new(image, x, y, width, height, duration, centered)
    local animation = {
        spriteSheet = image,
        x = x,
        y = y,
        quads = {},
        offsetX = centered and width / 2 or 0,
        offsetY = centered and height / 2 or 0
    }

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    function animation:draw()
        local spriteNum = math.floor(self.currentTime / self.duration * #self.quads) + 1
        love.graphics.draw(self.spriteSheet, self.quads[spriteNum], x, y, 0, 1, 1, self.offsetX, self.offsetY)
    end

    return animation
end

return module