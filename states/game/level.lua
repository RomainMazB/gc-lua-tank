local module = {
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
    obstacles = {}
}

local enemies, hostages
function module.load(game, level)
    enemies = game.Enemies
    hostages = game.Hostages

    module.mapData = dofile(love.filesystem.getWorkingDirectory()..'/levels/level'..level..'.lua')
    module.mapWidth = module.mapData.width
    module.mapHeight = module.mapData.height
    module.tileWidth = module.mapData.tilewidth
    module.tileHeight = module.mapData.tileheight
    module.tilesets.map.image = love.graphics.newImage("assets/images/tilesets/map.png")
    module.tilesets.map.width = module.tilesets.map.image:getWidth()
    module.tilesets.map.height = module.tilesets.map.image:getHeight()
    local nbColumns = module.tilesets.map.width / module.tileWidth
    local nbLines = module.tilesets.map.height / module.tileHeight

    for l=1,nbLines do
      for c=1,nbColumns do
        table.insert(
            module.tilesets.map.items,
            love.graphics.newQuad(
                (c-1)*module.tileWidth, (l-1) * module.tileHeight,
                module.tileWidth, module.tileHeight,
                module.tilesets.map.width, module.tilesets.map.height
            )
        )
      end
    end

    -- Load all the obstacles images
    for _,obstacle in pairs(module.mapData.tilesets[2].tiles) do
       local obstacleImage = love.graphics.newImage(obstacle.image:sub(4))
       module.tilesets.obstacles.items[module.mapData.tilesets[2].firstgid + obstacle.id] = {
           image = obstacleImage,
           width = obstacleImage:getWidth(),
           height = obstacleImage:getHeight()
       }
    end

    -- Load all the enemies images
    for _,enemy in pairs(module.mapData.tilesets[3].tiles) do
       local enemyImage = love.graphics.newImage(enemy.image:sub(4))
       module.tilesets.enemies.items[module.mapData.tilesets[3].firstgid + enemy.id] = {
           image = enemyImage,
           width = enemyImage:getWidth(),
           height = enemyImage:getHeight()
       }
    end

    -- Read the map data to feed the map's obstacles
    for _,obstacle in pairs(module.mapData.layers[2].objects) do
        local tilesetObstacles = module.tilesets.obstacles.items[obstacle.gid]

        if tilesetObstacles ~= nil then
            -- Because Tiled gives items layers position by the left **bottom** of the object
            -- We need to apply an offset to x and y to sync with our positionment method
            -- Cf: https://github.com/mapeditor/tiled/issues/1710#issuecomment-325672568
            local x = obstacle.x + obstacle.width/2
            local y = obstacle.y - obstacle.height/2
            local xMap, yMap = module.revProjection(x, y)

            if module.obstacles[yMap] == nil then
                module.obstacles[yMap] = {}
            end

            local newObstacle = {}
            newObstacle.image = tilesetObstacles.image
            newObstacle.body = physics.newPhysicsBody(physics.KINDS.FIXED_OBSTACLE, x, y, 0, 0, obstacle.width, obstacle.height, math.rad(obstacle.rotation))

            -- Because obstacles are moving, we feed the tilemap coordinates to reduce the amouse of search for collisions
            newObstacle.tilemapCoords = {
                x = xMap,
                y = yMap,
            }

            module.obstacles[yMap][xMap] = newObstacle
        end
    end

    -- Read the map data to feed the map's enemies
    for _,enemy in pairs(module.mapData.layers[3].objects) do
        local tilesetEnemies = module.tilesets.enemies.items[enemy.gid]

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
    for _,hostage in pairs(module.mapData.layers[4].objects) do
        local tilesetHostages = module.tilesets.obstacles.items[hostage.gid]

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

function module.projection(column, row)
    return column * module.tileWidth + module.tileWidth/2, row * module.tileHeight + module.tileHeight/2
end

function module.revProjection(x, y)
    return math.floor(x / module.tileWidth), math.floor(y / module.tileHeight)
end

function module.draw()
    local levelData = module.mapData.layers[1].data
    for l=module.mapHeight,1,-1 do
        for c=module.mapWidth,1,-1 do
            local tile = levelData[(l-1)*module.mapWidth+c]

            if tile > 0 then
                local image = module.tilesets.map.image
                local texQuad = module.tilesets.map.items[tile]
                local x, y = module.projection(c-1, l-1)

                if texQuad ~= nil then
                    love.graphics.draw(image, texQuad, x, y, 0, 1, 1, module.tileWidth/2, module.tileHeight/2)
                end
            end

            local obstacle = module.obstacles[l] ~= nil and module.obstacles[l][c] ~= nil and module.obstacles[l][c] or nil
            if obstacle ~= nil then
                love.graphics.draw(obstacle.image, obstacle.body.x, obstacle.body.y, obstacle.body.angle, 1, 1, obstacle.body.width/2, obstacle.body.height/2)
            end
        end
    end
end

function module.destroy()
    module.mapData = {}
    module.obstacles = {}
end

return module