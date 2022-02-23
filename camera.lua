Camera = {
    x = 0,
    y = 0,
    scaleX = 1,
    scaleY = 1,
    rotation = 0
}

function Camera:set()
    love.graphics.push()
    love.graphics.rotate(self.rotation)
    love.graphics.scale(self.scaleX, self.scaleY)
    love.graphics.translate(self.x, self.y)
end

function Camera:unset()
    love.graphics.pop()
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Camera:rotate(dr)
    self.rotation = self.rotation + dr
end

function Camera:scale(sx, sy)
    sx = sx or 1
    self.scaleX = self.scaleX + sx
    self.scaleY = self.scaleY + sy
end

function Camera:setPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
end

-- Return the vertical position on screen of an `y`
function Camera.projY(y)
    return y + Camera.y
end

return Camera