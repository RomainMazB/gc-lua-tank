local module = {
    enemiesLst = {}
}
local IA_STATES = {
    MOTIONLESS = 1,
    MOVING = 2,
    SHOOTING = 3
}

local hero, projectiles, level, pathfinding
function module.load(game)
    hero = game.Player.hero
    projectiles = game.Projectiles
    level = game.Level
    pathfinding = game.Pathfinding
end

function module.new(x, y, width, height, angle)
    local enemy = {}
    enemy.body = physics.newPhysicsBody(physics.KINDS.ENEMY, x, y, 0, 0, width, height, angle)
    enemy.life = 100
    enemy.maxLife = 100
    enemy.range = 500
    enemy.fireSpeed = 3
    enemy.lastFiredBulletTimer = 0
    enemy.bulletSpeed = 250
    enemy.canSeeTheHero = false
    enemy.tilemapCoords = {}
    enemy.ia = {
        lastKnownHeroPosition = {
            x = 0,
            y = 0
        },
        runPath = {},
        movingTo = {},
        state = IA_STATES.MOTIONLESS
    }

    -- Assign a new target position to move to and activate the moving state
    function enemy:moveTo(x, y)
        self.ia.movingTo = { x = x, y = y }
        self.body.angle = math.atan2(y - self.body.y, x - self.body.x)
        local enemyCosAngle = math.cos(self.body.angle)
        local enemySinAngle = math.sin(self.body.angle)
        self.body.vx = enemyCosAngle * 50
        self.body.vy = enemySinAngle * 50
        self.ia.state = IA_STATES.MOVING
    end

    -- Put all velocity to 0 and switch to the MOTIONLESS state
    function enemy:stopMoving()
        self.body.vx = 0
        self.body.vy = 0
        self.ia.state = IA_STATES.MOTIONLESS
    end

    -- Calculate the offset point to make the bullet start at the end of the weapon
    -- And so does the bang animation!
    function enemy:fire()
        local weaponCosAngle = math.cos(self.body.angle)
        local weaponSinAngle = math.sin(self.body.angle)
        local offsetX = weaponCosAngle * self.body.width
        local offsetY = weaponSinAngle * self.body.width
        local bulletVx = weaponCosAngle * self.bulletSpeed
        local bulletVy = weaponSinAngle * self.bulletSpeed
        projectiles.new(projectiles.KINDS.ENEMY, self.body.x + offsetX, self.body.y + offsetY, bulletVx, bulletVy, self.body.vx, self.body.vy, self.body.angle, self.range)
        self.lastFiredBulletTimer = self.fireSpeed
    end

    table.insert(module.enemiesLst, enemy)

    return module.enemiesLst[#module.enemiesLst]
end

function module.update(dt)
    for e=#module.enemiesLst,1,-1 do
        local enemy = module.enemiesLst[e]

        -- Remove dead enemies
        if enemy.life <= 0 then
            table.remove(module.enemiesLst, e)
            goto continue
        end

        local enemyX, enemyY = level.revProjection(enemy.body.x, enemy.body.y)
        enemy.tilemapCoords.x = enemyX
        enemy.tilemapCoords.y = enemyY
        local PlayerX, PlayerY = level.revProjection(hero.body.x, hero.body.y)
        local enemyCanSeeTheHero = pathfinding.canSee(enemy.tilemapCoords.x, enemy.tilemapCoords.y, PlayerX, PlayerY, level.obstacles)

        enemy.canSeeTheHero = enemyCanSeeTheHero
        -- If the enemy can see the hero and the hero moved since the last known position
        -- Make the enemy moves on the direction of the hero
        if
            enemyCanSeeTheHero and
            (enemy.ia.lastKnownHeroPosition.x ~= PlayerX or enemy.ia.lastKnownHeroPosition.y ~= PlayerY)
        then
            -- Store the last known hero position to not recalculate before it has changed
            enemy.ia.lastKnownHeroPosition = { x = PlayerX, y = PlayerY }
            enemy:moveTo(hero.body.x, hero.body.y)
        end

        -- Update the position on moving state
        if enemy.ia.state == IA_STATES.MOVING then
            enemy.body:move(dt)

            if enemyCanSeeTheHero then
                -- If the enemy can fire the hero depending on its range, fire!
                if enemy.body:distanceTo(hero.body) <= enemy.range then
                    enemy.ia.state = IA_STATES.SHOOTING
                end
            else
                -- If enemy can't see the hero and reached the hero's last known position
                -- Stop movement
                if enemy.tilemapCoords.x == enemy.ia.lastKnownHeroPosition.x and enemy.tilemapCoords.y == enemy.ia.lastKnownHeroPosition.y then
                    enemy:stopMoving()
                end
            end
        elseif enemy.ia.state == IA_STATES.SHOOTING then
            -- If the enemy can't see the hero anymore
            -- Stop firing
            if not enemyCanSeeTheHero then
                enemy:stopMoving()

            -- If the enemy can see the hero but the enemy's range is to low
            -- Move the enemy to reduce the distance between them
            elseif enemy.body:distanceTo(hero.body) > enemy.range  then
                enemy.ia.lastKnownHeroPosition = { x = PlayerX, y = PlayerY }
                enemy:moveTo(hero.body.x, hero.body.y)
            end

            -- Make sure to not fire on each frame by using a timer
            if enemy.lastFiredBulletTimer == 0 then
                enemy:fire()
            else
                enemy.lastFiredBulletTimer = math.max(0, enemy.lastFiredBulletTimer - dt)
            end
        end

        ::continue::
    end
end

function module.draw()
    for _, enemy in ipairs(module.enemiesLst) do
        love.graphics.draw(enemy.image, enemy.body.x, enemy.body.y, enemy.body.angle, 1, 1, 0, enemy.image:getHeight() /2)
    end

    -- Using two enemiesLst pass to make lifebar not hidden by other tanks
    for _, enemy in ipairs(module.enemiesLst) do
        love.graphics.setColor(1, 1, 1, .3)
        love.graphics.rectangle("line", enemy.body.x - 50, enemy.body.y - 50, 102, 12)
        love.graphics.setColor(0, 0, 0, .3)
        love.graphics.rectangle("fill", enemy.body.x - 49, enemy.body.y - 49, 100, 10)
        love.graphics.setColor(1, 0, 0, .5)
        love.graphics.rectangle("fill", enemy.body.x - 49, enemy.body.y - 49, enemy.life * enemy.maxLife / 100, 10)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function module.destroy()
    module.enemiesLst = {}
end

return module