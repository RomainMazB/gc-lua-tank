local module = {}

local level, hero, projectilesLst, enemiesLst, hostagesLst
function module.load(game)
    hero = game.Player.hero;
    projectilesLst = game.Projectiles.projectilesLst;
    hostagesLst = game.Hostages.hostagesLst;
    enemiesLst = game.Enemies;
    level = game.Level;
end

function module.update(dt)
    local tilemapheroX, tilemapheroY = level.revProjection(hero.body.x, hero.body.y)
    -- Detect tank collisions on up and down of the map
    if tilemapheroY < 0 or tilemapheroY == level.mapHeight then
        hero.speed = 0
        hero.body.vx = 0
        hero.body.vy = 0
    end

    -- Detect obstacle collisions in the range: x-1>x+1 and y-1>y-1
    for y=tilemapheroY-1, tilemapheroY+1 do
        if level.obstacles[y] ~= nil then
            for x=tilemapheroX-1, tilemapheroX+1 do
                if level.obstacles[y][x] ~= nil and hero.body:isTouching(level.obstacles[y][x].body) then
                    hero.body:collides(dt, level.obstacles[y][x], hero)
                end
            end
        end
    end

    -- Detect projectiles colissions
    for pIndex=#projectilesLst,1,-1 do
        local projectile = projectilesLst[pIndex]
        -- If the projectile collides an obstacle
        -- Desinstegrate it and abort
        local tilemapProjectileX, tilemapProjectileY = level.revProjection(projectile.body.x, projectile.body.y)
        if
            level.obstacles[tilemapProjectileY] ~= nil and
            level.obstacles[tilemapProjectileY][tilemapProjectileX] ~= nil
        then
            projectile.body:collides(dt, level.obstacles[tilemapProjectileY][tilemapProjectileX], projectile)
            goto continue
        end

        for e=#enemiesLst,1,-1 do
            local enemy = enemiesLst[e]
            if projectile.body:isTouching(enemy.body) then
                projectile.body:collides(dt, enemy, projectile)
            end
        end

        ::continue::
    end

    -- Detect hostage<>hero colissions
    for hIndex=#hostagesLst,1,-1 do
        local hostage = hostagesLst[hIndex]
        if hostage.body:isTouching(hero.body) then
            hostage.body:collides(dt, hero, hostage)
        end
    end
end

return module