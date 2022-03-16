local module = {
    KINDS = {
        HERO = 1,
        FIXED_OBSTACLE = 2,
        ENEMY = 3,
        PROJECTILE = 4,
        HOSTAGE = 5
    }
}

-- Calculate the circular bouding box size of an object from the average of its width and height
function module.getBoundingBox(a)
    return (a.width + a.height) / 2
end

-- Return the distance between two objects relatively to their center point
function module.distanceToCenter(a, b)
    return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

-- Return the distance between two objects bounding boxes
function module.distanceBetween(a, b)
    return math.max(0, module.distanceToCenter(a, b) - module.getBoundingBox(a)/2 - module.getBoundingBox(b)/2)
end

-- Return if two objects are touching each other
function module.isTouching(a, b)
    return module.distanceBetween(a, b) <= 0
end

-- Create and return a new physics body
function module.newPhysicsBody(kind, x, y, vx, vy, width, height, angle)
    local body = {
        x = x or 0,
        y = y or 0,
        vx = vx or 0,
        vy = vy or 0,
        width = width or 0,
        height = height or 0,
        angle = angle or 0,
        kind = kind
    }

    -- Move the body according to the velocity and deltatime
    function body:move(dt)
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
    end

    -- Detect if the current body is touching another one
    function body:isTouching(other)
        return module.isTouching(self, other)
    end

    -- Return the distance from the current body and another body
    function body:distanceTo(other)
        return module.distanceBetween(self, other)
    end

    -- Return the distance from the current body center and another body center
    function body:distanceToCenterOf(other)
        return module.distanceToCenter(self, other)
    end

    -- Default collideWith handler
    function body:collides(dt, collider, parentRef)
        -- To be implemented by bodies
    end

    return body
end

return module