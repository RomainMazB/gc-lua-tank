local module = {
    hostagesLst = {}
}
local IA_STATES = {
    MOTIONLESS = 1,
    MOVING = 2,
    RESCUED = 3
}

local hero, level, enemiesLst, pathfinding, gameplay
function module.load(game)
    hero = game.Player.hero
    level = game.Level
    enemiesLst = game.Enemies.enemiesLst
    pathfinding = game.Pathfinding
    gameplay = game.Gameplay
end

function module.new(x, y, width, height, angle)
    local hostage = {}
    hostage.body = physics.newPhysicsBody(physics.KINDS.HOSTAGE, x, y, 0, 0, width, height, angle)
    hostage.canSeeTheHero = false
    hostage.tilemapCoords = {}
    hostage.ia = {
        lastKnownHeroPosition = {
            x = 0,
            y = 0
        },
        runPath = {},
        movingTo = {},
        state = IA_STATES.MOTIONLESS
    }

    function hostage.body:collides(dt, collider, hostageRef)
        if collider.body.kind == physics.KINDS.HERO then
            -- If the hostage state is MOTIONLESS, it means that an enemy can see him
            if hostageRef.ia.state == IA_STATES.MOTIONLESS then
                -- Display a warning message: you need to kill all visible enemies before rescuing hostages
                gameplay.displayWarningMessage("You need to defeat all visible enemies first!!!")
            else
            -- Make this hostage rescued so it will be removed from the table on the next update
            hostageRef.ia.state = IA_STATES.RESCUED
            -- TODO: Play an animation?
            -- table.insert(module.explosionsLst, Animation.new(tankExplosion.image, self.x, self.y, 128, tankExplosion.height, .3, true))
            end
        end
    end

    -- Assign a new target position to move to and activate the moving state
    function hostage:moveTo(x, y)
        self.ia.movingTo = { x = x, y = y}
        self.body.angle = math.atan2(y - self.body.y, x - self.body.x)
        local hostageCosAngle = math.cos(self.body.angle)
        local hostageSinAngle = math.sin(self.body.angle)
        self.body.vx = hostageCosAngle * 50
        self.body.vy = hostageSinAngle * 50
        self.ia.state = IA_STATES.MOVING
    end

    -- Put all velocity to 0 and switch to the motionless state
    function hostage:stopMoving()
        self.body.vx = 0
        self.body.vy = 0
        self.ia.state = IA_STATES.MOTIONLESS
    end

    table.insert(module.hostagesLst, hostage)

    return module.hostagesLst[#module.hostagesLst]
end

function module.update(dt)
    for h=#module.hostagesLst,1,-1 do
        local hostage = module.hostagesLst[h]

        -- Register the rescued hostage, remove him from the list and abort
        if hostage.ia.state == IA_STATES.RESCUED then
            table.remove(module.hostagesLst, h)
            goto continue
        end

        -- Update tilemapCoords x and y to sync the tilemap pathfinding
        local hostageX, hostageY = level.revProjection(hostage.body.x, hostage.body.y)
        hostage.tilemapCoords.x = hostageX
        hostage.tilemapCoords.y = hostageY
        hostage.canSeeTheHero = pathfinding.canSee(hostage.tilemapCoords.x, hostage.tilemapCoords.y, hero.tilemapCoords.x, hero.tilemapCoords.y, level.obstacles)

        -- If the hostage can see the hero
        if hostage.canSeeTheHero then
            for _,enemy in ipairs(enemiesLst) do
                -- Detect if an enemy can see the hostage
                local EnemyX, EnemyY = level.revProjection(enemy.body.x, enemy.body.y)
                if pathfinding.canSee(hostage.tilemapCoords.x, hostage.tilemapCoords.y, EnemyX, EnemyY, level.obstacles) then
                    -- In that case, make sure the hostage remains motionless and abort
                    hostage.ia.state = IA_STATES.MOTIONLESS
                    -- Abort because performance: it's not necessary to look further if the hostage should move
                    goto continue
                end
            end

            -- Only recalculate the hostage target point if the hero changed its last known position
            if (hostage.ia.lastKnownHeroPosition.x ~= hero.tilemapCoords.x or hostage.ia.lastKnownHeroPosition.y ~= hero.tilemapCoords.y) then
                -- Store the last known hero position to not recalculate before it has changed
                hostage.ia.lastKnownHeroPosition = { x = hero.tilemapCoords.x, y = hero.tilemapCoords.y }
                hostage:moveTo(hero.body.x, hero.body.y)
            end
        end

        -- Update the position on moving state
        if hostage.ia.state == IA_STATES.MOVING then
            hostage.body:move(dt)

            -- If hostage can't see the hero and reached the hero's last known position
            if not hostage.canSeeTheHero
            and hostage.tilemapCoords.x == hostage.ia.lastKnownHeroPosition.x and hostage.tilemapCoords.y == hostage.ia.lastKnownHeroPosition.y then
                -- Stop movement
                hostage:stopMoving()
            end
        end

        ::continue::
    end
end

function module.draw()
    for _, hostage in ipairs(module.hostagesLst) do
        love.graphics.draw(hostage.image, hostage.body.x, hostage.body.y, hostage.body.angle, 1, 1, 0, hostage.image:getHeight() /2)
    end
end

function module.destroy()
    module.hostagesLst = {}
end

return module