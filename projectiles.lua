local Projectiles = {
    projectiles = {},
    detonations = {}
}
local DETONATION_TIME = .1

local bullet = love.graphics.newImage("assets/images/bullets/bulletRed1_outline.png")
local bang = love.graphics.newImage("assets/images/shots/shotThin.png")
local shot = love.audio.newSource("assets/sounds/shot.wav","static")

function Projectiles.new(x, y, vx, vy, fromVX, fromVY, angle, range, afflictDamageCallback)
    local projectile = {
        x = x,
        y = y,
        width = bullet:getWidth(),
        height = bullet:getHeight(),
        vx = vx,
        vy = vy,
        angle = angle,
        afflictDamageCallback = function(target)
            target.life = target.life - 50
        end,
        desintegrate = function(index)
            table.remove(Projectiles.projectiles, index)
        end,
        range = range
    }

    table.insert(Projectiles.projectiles, projectile)
    table.insert(Projectiles.detonations, {
        x = x,
        y = y,
        vx = fromVX,
        vy = fromVY,
        height=bang:getHeight(),
        angle = angle,
        remainingTime = DETONATION_TIME
    })

    -- Because a single audio source can't be played multiple times in parallel
    -- We need to stop the audio before playing it another time
    shot:stop()
    shot:play()

    return projectile
end

function Projectiles.draw()
    for _k, projectile in ipairs(Projectiles.projectiles) do
        love.graphics.draw(bullet, projectile.x, projectile.y, projectile.angle, 1, 1, 0, bullet:getHeight() /2)
    end

    -- Draw the detonations, the DETONATION_TIME is used to make it appear growing
    for _k, detonation in ipairs(Projectiles.detonations) do
        love.graphics.draw(bang, detonation.x, detonation.y, detonation.angle,
        DETONATION_TIME / (DETONATION_TIME+detonation.remainingTime), 1, 5, detonation.height / 2)
    end
end

function Projectiles.update(dt)
    for p=#Projectiles.projectiles,1,-1 do
        local projectile = Projectiles.projectiles[p]
        local deltaVx = projectile.vx * dt
        local deltaVy = projectile.vy * dt

        -- Move the projectile
        projectile.x = projectile.x + deltaVx
        projectile.y = projectile.y + deltaVy

        -- Decrease its remaining range to make it disappear
        projectile.range = projectile.range - math.sqrt(deltaVx^2 + deltaVy^2)
        if projectile.range <= 0 then
            table.remove(Projectiles.projectiles, p)
        end
    end

    for d=#Projectiles.detonations,1,-1 do
        local detonation = Projectiles.detonations[d]
        -- When a bullet is being fired, set a remaining timer to delay the disappearing of the detonation
        detonation.remainingTime = detonation.remainingTime - dt

        if detonation.remainingTime < 0 then
            table.remove(Projectiles.detonations, d)
        end

        -- Update the detonation x/y to make it follow the weapon
        detonation.x = detonation.x + detonation.vx * dt
        detonation.y = detonation.y + detonation.vy * dt
    end
end

return Projectiles
