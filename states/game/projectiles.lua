local module = {
    projectilesLst = {},
    detonationsLst = {},
    explosionsLst = {},
    KINDS = {
        ALLY = 0,
        ENEMY = 0
    }
}

local DETONATION_TIME = .1
local bullet
local bang
local shotSound
local tankExplosionSound
local objectExplosionSound
local tankExplosion
local objectExplosion

function module.load()
    -- Load all assets
    bullet = love.graphics.newImage("assets/images/bullets/bulletRed1_outline.png")
    bang = love.graphics.newImage("assets/images/shots/shotThin.png")
    shotSound = love.audio.newSource("assets/sounds/shot.wav","static")
    tankExplosionSound = love.audio.newSource("assets/sounds/shot.wav","static")
    objectExplosionSound = love.audio.newSource("assets/sounds/shot.wav","static")

    tankExplosion = {
        image = love.graphics.newImage("assets/images/explosions/explosion2_spritesheet.png")
    }
    tankExplosion.width = tankExplosion.image:getWidth()
    tankExplosion.height = tankExplosion.image:getHeight()

    objectExplosion = {
        image = love.graphics.newImage("assets/images/explosions/explosion1_spritesheet.png")
    }
    objectExplosion.width = objectExplosion.image:getWidth()
    objectExplosion.height = objectExplosion.image:getHeight()
end

function module.new(kind, x, y, vx, vy, fromVX, fromVY, angle, range, damage)
    local projectile = {}
    projectile.body = physics.newPhysicsBody(physics.KINDS.PROJECTILE, x, y, vx, vy, bullet:getWidth(), bullet:getHeight(), angle)
    projectile.range = range
    projectile.damage = damage
    projectile.kind = kind

    function projectile.body:collides(dt, collider, projectileRef)
        if collider.body.kind == physics.KINDS.FIXED_OBSTACLE then
            table.insert(module.explosionsLst, Animation.new(objectExplosion.image, self.x, self.y, 128, objectExplosion.height, .3, true))
        elseif collider.body.kind == physics.KINDS.ENEMY and projectileRef.kind == module.KINDS.ALLY then
            collider.life = collider.life - 10
            table.insert(module.explosionsLst, Animation.new(tankExplosion.image, self.x, self.y, 128, tankExplosion.height, .3, true))
            -- TODO: increase the score
        elseif collider.body.kind == physics.KINDS.ALLY and projectileRef.kind == module.KINDS.ENEMY then
            collider.life = collider.life - 10
            table.insert(module.explosionsLst, Animation.new(tankExplosion.image, self.x, self.y, 128, tankExplosion.height, .3, true))
        end

        -- Make this projectile nil so it will be removed from the table on the next update
        projectileRef.range = 0
    end

    table.insert(module.projectilesLst, projectile)

    -- Create the detonation image and inject it into the detonationLst
    local detonation = {}
    detonation.body = physics.newPhysicsBody(nil, x, y, fromVX, fromVY, bang:getWidth(), bang:getHeight(), angle)
    detonation.remainingTime = DETONATION_TIME
    table.insert(module.detonationsLst, detonation)

    -- Because a single audio source can't be played multiple times in parallel
    -- We need to stop the audio before playing it another time
    -- shotSound:stop()
    -- shotSound:play()

    return projectile
end

function module.update(dt)
    for p=#module.projectilesLst,1,-1 do
        local projectile = module.projectilesLst[p]

        -- Remove out of range projectiles
        if projectile.range <= 0 then
            table.remove(module.projectilesLst, p)
            goto continue
        end

        local deltaVx = projectile.body.vx * dt
        local deltaVy = projectile.body.vy * dt

        -- Move the projectile
        projectile.body:move(dt)

        -- Decrease its remaining range to make it disappear
        projectile.range = projectile.range - math.sqrt(deltaVx^2 + deltaVy^2)

        ::continue::
    end

    for d= #module.detonationsLst,1,-1 do
        local detonation = module.detonationsLst[d]
        -- When a bullet is being fired, set a remaining timer to delay the disappearing of the detonation
        detonation.remainingTime = detonation.remainingTime - dt

        if detonation.remainingTime < 0 then
            table.remove(module.detonationsLst, d)
        end

        -- Update the detonation x/y to make it follow the weapon
        detonation.body:move(dt)
    end

    for d= #module.explosionsLst,1,-1 do
        local explosion = module.explosionsLst[d]
        explosion.currentTime = explosion.currentTime + dt

        if explosion.currentTime >= explosion.duration then
            table.remove(module.explosionsLst, d)
        end
    end
end

function module.draw()
    for _, projectile in ipairs(module.projectilesLst) do
        love.graphics.draw(bullet, projectile.body.x, projectile.body.y, projectile.body.angle, 1, 1, 0, bullet:getHeight() /2)
    end

    -- Draw the detonations, the DETONATION_TIME is used to make it appear growing
    for _, detonation in ipairs(module.detonationsLst) do
        love.graphics.draw(bang, detonation.body.x, detonation.body.y, detonation.body.angle,
        DETONATION_TIME / (DETONATION_TIME+detonation.remainingTime), 1, 5, detonation.body.height / 2)
    end

    -- Draw the explosions
    for _, explosion in ipairs(module.explosionsLst) do
        explosion:draw()
    end
end

return module
