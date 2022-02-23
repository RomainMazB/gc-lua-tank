local Enemies = {
    enemies = {}
}
local enemyImage = love.graphics.newImage("assets/images/tanks/tank_blue.png")

function Enemies.load()
    -- Read the map data to generate x/y and width/height only once for all obstacles' bounding box
    for l=MAP_HEIGHT,1,-1 do
        for c=MAP_WIDTH,1,-1 do
            local x, y = Game.projection(c-1, l-1)
            if Game.enemies[l][c] == 1 then
                Enemies.new(x, y, 0, 0, HALF_PI)
            end
        end
    end
end

function Enemies.new(x, y, vx, vy, angle)
    local enemy = {
        x = x,
        y = y,
        width = enemyImage:getWidth(),
        height = enemyImage:getHeight(),
        vx = vx,
        vy = vy,
        angle = angle,
        life = 100,
        maxLife = 100,
        range = 500,
        fireSpeed = .5,
        lastFiredBulletTimer = 0,
        ia = {
            lastKnownHeroPosition = {
                x = 0,
                y = 0
            },
            runPath = {},
            movingTo = {},
            state = "motionless"
        }
    }

    table.insert(Enemies.enemies, enemy)
end

function Enemies.draw()
    for _k, enemy in ipairs(Enemies.enemies) do
        love.graphics.draw(enemyImage, enemy.x, enemy.y, enemy.angle, 1, 1, 0, enemyImage:getHeight() /2)
    end
end

function Enemies.update(dt)
    for _k, enemy in ipairs(Enemies.enemies) do
        local enemyX, enemyY = Game.revProjection(enemy.x, enemy.y)
        local playerX, playerY = Game.revProjection(Player.x, Player.y)
        local enemyCanSeeTheHero = Pathfinding.canSee(enemyX, enemyY, playerX, playerY, Game.Obstacles)

        -- If the enemy is motionless, can see the hero and the hero has move since the last known position
        -- Make the enemie move on the direction of the hero
        if
            enemyCanSeeTheHero and
            (enemy.ia.lastKnownHeroPosition.x ~= playerX or enemy.ia.lastKnownHeroPosition.y ~= playerY)
        then
            -- Store the last known hero position to not recalculate before it has changed
            enemy.ia.lastKnownHeroPosition = { x = playerX, y = playerY}
            enemy.ia.movingTo = { x = Player.x, y = Player.y}
            enemy.angle = math.atan2(Player.y - enemy.y, Player.x - enemy.x)
            local enemyCosAngle = math.cos(enemy.angle)
            local enemySinAngle = math.sin(enemy.angle)
            enemy.vx = enemyCosAngle * 50
            enemy.vy = enemySinAngle * 50
            enemy.ia.state = "moving"
        end

        -- Update the position on moving state
        if enemy.ia.state == "moving" then
            enemy.x = enemy.x + enemy.vx * dt
            enemy.y = enemy.y + enemy.vy * dt

            -- If the enemy can fire the hero depending on its range, fire!
            if enemyCanSeeTheHero and Collisions.distanceBetween(enemy, Player) <= enemy.range then
                enemy.ia.state = "shooting"
            end
        elseif enemy.ia.state == "shooting" then
            -- Make sure to not fire on each frame by using a timer
            if enemy.lastFiredBulletTimer == 0 then
                -- Calculate the offset point to make the bullet start at the end of the weapon
                -- And so does the bang!
                local weaponCosAngle = math.cos(enemy.angle)
                local weaponSinAngle = math.sin(enemy.angle)
                local offsetX = weaponCosAngle * enemy.width
                local offsetY = weaponSinAngle * enemy.width
                Projectiles.new(enemy.x + offsetX, enemy.y + offsetY, enemy.vx, enemy.vy, enemy.vx, enemy.vy, enemy.angle, enemy.range)

                enemy.lastFiredBulletTimer = enemy.fireSpeed
            else
                enemy.lastFiredBulletTimer = math.max(0, enemy.lastFiredBulletTimer - dt)
            end
        end
    end
end

return Enemies