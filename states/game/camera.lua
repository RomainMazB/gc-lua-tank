local module = {
    x = 0,
    y = 0,
    scaleX = 1,
    scaleY = 1,
    rotation = 0
}

local hero, level

function module.load(game)
    hero = game.Player.hero
    level = game.Level
end

function module.update(dt)
    -- Center the camera on the hero with a min value fixed at the top and max at the bottom of the map
    if Screen.width < level.mapWidth * level.tileWidth then
        module.x = math.max(
            Screen.width - level.mapWidth * level.tileWidth,
            math.min(
                0,
                Screen.midWidth - hero.body.x
            )
        )
    else
        module.x = (Screen.width - level.mapWidth * level.tileWidth) / 2
    end

    -- If the map height is greater than the screen, we need to handle the scroll
    if Screen.height < level.mapHeight * level.tileHeight then
        module.y = math.max(
            -- Can't go out of the map bottom
            Screen.height - level.mapHeight * level.tileHeight,
            math.min(
                -- Can't go out of the map top
                0,
                -- Centered on the player
                Screen.midHeight - hero.body.y
            )
        )
    else
        module.y = (Screen.height - level.mapHeight * level.tileHeight) / 2
    end
end

-- Save the current love.graphics configuration and modify it to simulate a camera positionning
function module:set()
    love.graphics.push()
    love.graphics.rotate(self.rotation)
    love.graphics.scale(self.scaleX, self.scaleY)
    love.graphics.translate(self.x, self.y)
end

-- Reset the initial love.graphics
function module:unset()
    love.graphics.pop()
end

-- Move the camera to x and y
function module:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

-- Rotate the camera
function module:rotate(dr)
    self.rotation = self.rotation + dr
end

-- Scale the camera with ScaleX and ScaleY
function module:scale(sx, sy)
    sx = sx or 1
    self.scaleX = self.scaleX + sx
    self.scaleY = self.scaleY + sy
end

-- Set the camera position, defaults to current
function module:setPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
end

-- Return the position of a point relatively to the camera position
function module:getRelativePosition(x, y)
    return x - self.x, y - self.y
end

-- Return the mouse position relatively to the camera position
function module:getMousePosition()
    return self:getRelativePosition(love.mouse.getPosition())
end

return module