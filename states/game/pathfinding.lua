local module = {}

-- Use math.round a point coordinates
local roundPoint = function (point)
    return {
        x = math.round(point.x),
        y = math.round(point.y)
    }
end

-- Return the linear segment from a to b with a stepSize dimension
module.lerp = function (a, b, stepSize)
    return a + stepSize * (b - a)
end

-- Return the 2D segment from a to b with a stepSize dimension
module.lerpPoint = function (aX, aY, bX, bY, stepSize)
    return {
        x = module.lerp(aX, bX, stepSize),
        y = module.lerp(aY, bY, stepSize)
    }
end

-- Return all the nbSteps amount of points coordinates between a and b
module.lerpPoints = function (a, b, nbSteps)
    local points = {}

    for n=1,nbSteps do
        table.insert(points, module.lerpPoint(a, b, n/nbSteps))
    end

    return points
end

-- Determine the shortest "tilemaped" line from a to b
module.tiledLine = function (aX, aY, bX, bY, withDiagonals)
    local withDiagonals = withDiagonals ~= nil and withDiagonals or false
    local dx = bX - aX
    local dy = bY - aY
    local diagSize = math.max(math.abs(dx), math.abs(dy))
    local points = {}

    for n=0,diagSize do
        local step = n == 0 and 0.0 or n / diagSize
        local nextPoint = roundPoint(module.lerpPoint(aX, aY, bX, bY, step))
        -- If diagonals are not allowed and both x and y changes are detected (meaning a diagonal movement)
        if not withDiagonals and
            #points > 0 and
            math.abs(nextPoint.x - points[#points].x) + math.abs(nextPoint.y - points[#points].y)
        then
            -- We inject an intermediate point without x movement
            table.insert(points, { x = nextPoint.x, y = points[#points].y })
        end

        table.insert(points, nextPoint)
    end

    return points
end

-- Determine if a can see b
module.canSee = function (aX, aY, bX, bY, obstacles)
    for _, tile in ipairs(module.tiledLine(aX, aY, bX, bY)) do
        if obstacles[tile.y] ~= nil and obstacles[tile.y][tile.x] ~= nil then
           return false
        end
    end

    return true
end

return module
