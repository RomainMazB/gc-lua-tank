local Collisions = {}

function Collisions.load()
end

function Collisions.draw()
end

function Collisions.update(dt)
    local tilemapPlayerX, tilemapPlayerY = Game.revProjection(Player.x, Player.y)
    -- Detect tank collision on up and down of the map
    if tilemapPlayerY < 0 or tilemapPlayerY == MAP_HEIGHT then
        Player.speed = 0
    end

    -- Detect obstacle collision
    for l=tilemapPlayerY-1, tilemapPlayerY+1 do
        if Game.Obstacles[l] ~= nil then
            for c=tilemapPlayerX-1, tilemapPlayerX+1 do
                if Game.Obstacles[l][c] ~= nil and Collisions.isTouching(Game.Obstacles[l][c], Player) then
                    -- On hero collision stop its speed
                    Player.speed = 0
                    -- Resolve the collision by applying a reverse vx/vy
                    Player.x = Player.x - Player.vx * dt
                    Player.y = Player.y - Player.vy * dt
                end
            end
        end
    end

    for p=#Projectiles.projectiles,1,-1 do
        local projectile = Projectiles.projectiles[p]
        -- If the projectile collides an obstacle that can't be traversed
        -- Desinstegrate it and abort
        local tilemapProjectileX, tilemapProjectileY = Game.revProjection(projectile.x, projectile.y)
        if
            Game.Obstacles[tilemapProjectileY] ~= nil and
            Game.Obstacles[tilemapProjectileY][tilemapProjectileX] ~= nil and
            not Game.Obstacles[tilemapProjectileY][tilemapProjectileX].canBeTraversed
        then
            projectile.desintegrate(p)
            goto continue
        end

        for e=#Enemies.enemies,1,-1 do
            local enemy = Enemies.enemies[e]
            if Collisions.isTouching(enemy, projectile) then
                projectile.afflictDamageCallback(enemy)
                table.remove(Projectiles.projectiles, p)

                if enemy.life <= 0 then
                    table.remove(Enemies.enemies, e)
                end
            end
        end

        ::continue::
    end
end

function Collisions.distanceToCenter(a, b)
    return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

function Collisions.distanceBetween(a, b)
    return math.max(0, Collisions.distanceToCenter(a, b) - Collisions.getBoundingBox(a)/2 - Collisions.getBoundingBox(b)/2)
end

-- Calculate the circular bouding box size of an object from the average of its width and height
function Collisions.getBoundingBox(a)
    return (a.width + a.height) / 2
end

function Collisions.isTouching(a, b)
    return Collisions.distanceBetween(a, b) == 0
end

return Collisions