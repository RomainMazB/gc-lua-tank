local module = {}

local level, hero, projectilesLst, enemiesLst, hostagesLst
function module.load(game)
    hero = game.Player.hero;
    projectilesLst = game.Projectiles.projectilesLst;
    hostagesLst = game.Hostages.hostagesLst;
    enemiesLst = game.Enemies.enemiesLst;
    level = game.Level;
end

function module.update(dt)
    local tilemapheroX, tilemapheroY = level.revProjection(hero.body.x, hero.body.y)
    -- Detect tank collisions on of the map's limits
    if tilemapheroY < 0 or tilemapheroY == level.mapHeight or tilemapheroX < 0 or tilemapheroX == level.mapWidth  then
        hero.speed = 0
        hero.body.vx = 0
        hero.body.vy = 0
    end

    -- Detect obstacle collisions in the range: x-1>x+1 and y-1>y-1
    for y=tilemapheroY-1, tilemapheroY+1 do
        if level.obstacles[y] then
            for x=tilemapheroX-1, tilemapheroX+1 do
                if level.obstacles[y][x] and hero.body:isTouching(level.obstacles[y][x].body) then
                    hero.body:collides(dt, level.obstacles[y][x], hero)
                end
            end
        end
    end

    -- Detect projectiles colissions
    for pIndex=#projectilesLst,1,-1 do
        local projectile = projectilesLst[pIndex]

        -- If the projectile collides an obstacle
        local tilemapProjectileX, tilemapProjectileY = level.revProjection(projectile.body.x, projectile.body.y)
        if level.obstacles[tilemapProjectileY] and level.obstacles[tilemapProjectileY][tilemapProjectileX] then
            projectile.body:collides(dt, level.obstacles[tilemapProjectileY][tilemapProjectileX], projectile)
            goto continue
        end

        -- Loop through all the enemies to see if it collides
        for e=#enemiesLst,1,-1 do
            local enemy = enemiesLst[e]
            if projectile.body:isTouching(enemy.body) then
                projectile.body:collides(dt, enemy, projectile)
                goto continue
            end
        end

        if projectile.body:isTouching(hero.body) then
            projectile.body:collides(dt, hero, projectile)
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