local Pathfinding = {}
local round = function (n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

local roundPoint = function (point)
    return {
        x = round(point.x),
        y = round(point.y)
    }
end

-- Determine the shortest "tilemaped" line from a to b
Pathfinding.lerp = function (a, b, step)
    return a + step * (b - a)
end

Pathfinding.lerpPoint = function (aX, aY, bX, bY, step)
    return {
        x = Pathfinding.lerp(aX, bX, step),
        y = Pathfinding.lerp(aY, bY, step)
    }
end

Pathfinding.lerpPoints = function (a, b, steps)
    local points = {}

    for step=1,steps do
        table.insert(points, Pathfinding.lerpPoint(a, b, step/steps))
    end

    return points
end

Pathfinding.line = function (aX, aY, bX, bY)
    local dx = bX - aX
    local dy = bY - aY
    local diagDistance = math.max(math.abs(dx), math.abs(dy))
    local points = {}

    for n=0,diagDistance do
        local t = n == 0 and 0.0 or n / diagDistance
        table.insert(points, roundPoint(Pathfinding.lerpPoint(aX, aY, bX, bY, t)))
    end

    return points
end

-- Determine if a can see b
Pathfinding.canSee = function (aX, aY, bX, bY, obstacles)
    local canSee = true

    for _k, tile in ipairs(Pathfinding.line(aX, aY, bX, bY)) do
        if obstacles[tile.y+1] ~= nil and obstacles[tile.y+1][tile.x+1] ~= nil then
            canSee = false
            break
        end
    end

    return canSee
end

-- Calculate - if possible - the shortest way from a to b
Pathfinding.aStar = function(a, b, obstacles)
 -- Is this really needed?
end

return Pathfinding
