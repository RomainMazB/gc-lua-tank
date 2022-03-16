local Level = {
    isPaused = false,
    mapHeight = 0,
    mapWidth = 0,
    tileWidth = 0,
    tileHeight = 0,
    mapData = {},
    tilesets = {
        map = {
            image = nil,
            width = 0,
            height = 0,
            quads = {},
            items = {}
        },
        obstacles = {
            items = {}
        },
        enemies = {
            items = {}
        }
    },
    obstacles = {},
    enemies = {}
}

local enemies, hostages
function Level.load(game, level)
    enemies = game.Enemies
    hostages = game.Hostages

    Level.mapData = require('levels.level'..level)
    Level.mapWidth = Level.mapData.width
    Level.mapHeight = Level.mapData.height
    Level.tileWidth = Level.mapData.tilewidth
    Level.tileHeight = Level.mapData.tileheight
    Level.tilesets.map.image = love.graphics.newImage("assets/images/tilesets/map.png")
    Level.tilesets.map.width = Level.tilesets.map.image:getWidth()
    Level.tilesets.map.height = Level.tilesets.map.image:getHeight()
    local nbColumns = Level.tilesets.map.width / Level.tileWidth
    local nbLines = Level.tilesets.map.height / Level.tileHeight

    Level.tilesets.map.items[0] = nil
    for l=1,nbLines do
      for c=1,nbColumns do
        table.insert(
            Level.tilesets.map.items,
            love.graphics.newQuad(
                (c-1)*Level.tileWidth, (l-1) * Level.tileHeight,
                Level.tileWidth, Level.tileHeight,
                Level.tilesets.map.width, Level.tilesets.map.height
            )
        )
      end
    end

    -- Load all the obstacles images
    for _,obstacle in pairs(Level.mapData.tilesets[2].tiles) do
       local obstacleImage = love.graphics.newImage(obstacle.image:sub(4))
       Level.tilesets.obstacles.items[Level.mapData.tilesets[2].firstgid + obstacle.id] = {
           image = obstacleImage,
           width = obstacleImage:getWidth(),
           height = obstacleImage:getHeight()
       }
    end

    -- Load all the enemies images
    for _,enemy in pairs(Level.mapData.tilesets[3].tiles) do
       local enemyImage = love.graphics.newImage(enemy.image:sub(4))
       Level.tilesets.enemies.items[Level.mapData.tilesets[3].firstgid + enemy.id] = {
           image = enemyImage,
           width = enemyImage:getWidth(),
           height = enemyImage:getHeight()
       }
    end

    -- Read the map data to feed the map's obstacles
    for _,obstacle in pairs(Level.mapData.layers[2].objects) do
        local tilesetObstacles = Level.tilesets.obstacles.items[obstacle.gid]

        if tilesetObstacles ~= nil then
            -- Because Tiled gives items layers position by the left **bottom** of the object
            -- We need to apply an offset to x and y to sync with our positionment method
            -- Cf: https://github.com/mapeditor/tiled/issues/1710#issuecomment-325672568
            local x = obstacle.x + obstacle.width/2
            local y = obstacle.y - obstacle.height/2
            local xMap, yMap = Level.revProjection(x, y)

            if Level.obstacles[yMap] == nil then
                Level.obstacles[yMap] = {}
            end

            local newObstacle = {}
            newObstacle.image = tilesetObstacles.image
            newObstacle.body = physics.newPhysicsBody(physics.KINDS.FIXED_OBSTACLE, x, y, 0, 0, obstacle.width, obstacle.height, math.rad(obstacle.rotation))

            -- Because obstacles are moving, we feed the tilemap coordinates to reduce the amouse of search for collisions
            newObstacle.tilemapCoords = {
                x = xMap,
                y = yMap,
            }

            Level.obstacles[yMap][xMap] = newObstacle
        end
    end

    -- Read the map data to feed the map's enemies
    for _,enemy in pairs(Level.mapData.layers[3].objects) do
        local tilesetEnemies = Level.tilesets.enemies.items[enemy.gid]

        if tilesetEnemies ~= nil then
            -- Because Tiled gives items layers position by the left **bottom** of the object
            -- We need to apply an offset to x and y to sync with our positionment method
            -- Cf: https://github.com/mapeditor/tiled/issues/1710#issuecomment-325672568
            local x = enemy.x + enemy.width/2
            local y = enemy.y - enemy.height/2

            local newEnemy = enemies.new(x, y, enemy.width, enemy.height, math.rad(enemy.rotation))

            newEnemy.image = tilesetEnemies.image
        end
    end

    -- Read the map data to feed the map's hostages
    for _,hostage in pairs(Level.mapData.layers[4].objects) do
        local tilesetHostages = Level.tilesets.obstacles.items[hostage.gid]

        if tilesetHostages ~= nil then
            -- Because Tiled gives items layers position by the left **bottom** of the object
            -- We need to apply an offset to x and y to sync with our positionment method
            -- Cf: https://github.com/mapeditor/tiled/issues/1710#issuecomment-325672568
            local x = hostage.x + hostage.width/2
            local y = hostage.y - hostage.height/2

            local newHostage = hostages.new(x, y, hostage.width, hostage.height, math.rad(hostage.rotation))

            newHostage.image = tilesetHostages.image
        end
    end
end

function Level.projection(column, row)
    return column * Level.tileWidth + Level.tileWidth/2, row * Level.tileHeight + Level.tileHeight/2
end

function Level.revProjection(x, y)
    return math.floor(x / Level.tileWidth), math.floor(y / Level.tileHeight)
end

function Level.draw()
    local levelData = Level.mapData.layers[1].data
    for l=Level.mapHeight,1,-1 do
        for c=Level.mapWidth,1,-1 do
            local tile = levelData[(l-1)*Level.mapWidth+c]

            if tile > 0 then
                local image = Level.tilesets.map.image
                local texQuad = Level.tilesets.map.items[tile]
                local x, y = Level.projection(c-1, l-1)

                if texQuad ~= nil then
                    love.graphics.draw(image, texQuad, x, y, 0, 1, 1, Level.tileWidth/2, Level.tileHeight/2)
                end
            end

            local obstacle = Level.obstacles[l] ~= nil and Level.obstacles[l][c] ~= nil and Level.obstacles[l][c] or nil
            if obstacle ~= nil then
                love.graphics.draw(obstacle.image, obstacle.body.x, obstacle.body.y, obstacle.body.angle, 1, 1, obstacle.body.width/2, obstacle.body.height/2)
            end
        end
    end
end

return Level