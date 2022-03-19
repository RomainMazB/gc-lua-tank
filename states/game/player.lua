local module = {}

local tracksSrc = {}
local tracksLst = {}
local lastAddedTracks = 0
-- Used to set an index on each tracks drawn to make it slowly disappear
local tracksIndex = 0

local tankMovingSound
local tankIdleSound

local level
function module.load(game)
    -- Inject dependencies
    level = game.Level

    -- Setup the hero
    module.hero = {
        speed = 0,
        isFiring = false,
        life = 75,
        maxLife = 100,
        lireRestaurationPerSecond = 3,
        tank = {
            image,
            width = 0,
            height = 0,
            maxSpeed = 80,
            forwardMaxSpeed = 40,
            rotationSpeed = math.half_pi
        },
        weapon = {
            image,
            angle = -math.half_pi,
            width = 0,
            height = 0,
            damage = 10,
            rotationSpeed = math.half_pi,
            bulletSpeed = 250,
            offsetX = 8,
            offsetY = 0,
            lastTimeShot = 0,
            range = 400,
        }
    }

    -- Load assets
    module.hero.tank.image = love.graphics.newImage("assets/images/tanks/tankBody_bigRed_outline.png")
    module.hero.tank.width = module.hero.tank.image:getWidth()
    module.hero.tank.height = module.hero.tank.image:getHeight()
    module.hero.weapon.image = love.graphics.newImage("assets/images/weapons/tankRed_barrel2_outline.png")
    module.hero.weapon.width = module.hero.weapon.image:getWidth()
    module.hero.weapon.height = module.hero.weapon.image:getHeight()
    tracksSrc.image = love.graphics.newImage("assets/images/tracks.png")
    tracksSrc.offsetX = tracksSrc.image:getWidth()/2
    tracksSrc.offsetY = tracksSrc.image:getHeight()/2
    tankMovingSound = love.audio.newSource("assets/sounds/tank-moving.wav", "static")
    tankIdleSound = love.audio.newSource("assets/sounds/tank-idle.wav", "static")
    tankMovingSound:setLooping(true)
    tankIdleSound:setLooping(true)

    tankMovingSound:setVolume(0)
    tankIdleSound:play()
    tankMovingSound:play()

    -- Put the Player's tank at the starting position of the level
    heroStartingX, heroStartingY = level.projection(level.mapData.properties.playerstartingx, level.mapData.properties.playerstartingy)

    -- Initialize physics and other stuff
    module.hero.body = physics.newPhysicsBody(physics.KINDS.HERO, heroStartingX, heroStartingY, 0, 0, module.hero.tank.width, module.hero.tank.height, -math.half_pi)

    -- Handle obstacle collision
    function module.hero.body:collides(dt, collider, heroRef)
        -- If the collider is a fixed obstacle, default resolution would be 
        if (collider.body.kind == physics.KINDS.FIXED_OBSTACLE) then
            -- If the collider is the flag, capture it
            if collider.isFlag then
                
            else
                -- Instantly resolve the colission with an opposite movement to not get stuck
                self.x = self.x - self.vx * dt
                self.y = self.y - self.vy * dt

                -- Reverse the speed and velocity to create a bouncy-effect
                heroRef.speed = - heroRef.speed / 2
                self.vx = - self.vx
                self.vy = - self.vy
            end
        end
    end
end

function module.update(dt)
    local PlayerCosAngle = math.cos(module.hero.body.angle)
    local PlayerSinAngle = math.sin(module.hero.body.angle)
    module.hero.body.vx = PlayerCosAngle * module.hero.speed
    module.hero.body.vy = PlayerSinAngle * module.hero.speed

    local movedDistanceX, movedDistanceY = module.hero.body:move(dt)

    local movedDistance = movedDistanceX + movedDistanceY
    lastAddedTracks = lastAddedTracks + movedDistance
    tracksIndex = tracksIndex + movedDistance

    if lastAddedTracks >= 10 then
        local newTracks = {
            x = module.hero.body.x,
            y = module.hero.body.y,
            angle = module.hero.body.angle,
            index = tracksIndex
        }

        table.insert(tracksLst, newTracks)
        lastAddedTracks = 0
    end

    -- Remove old tracks
    for t=#tracksLst,1,-1 do
        local tracks = tracksLst[t]

        if tracks.index <= tracksIndex - 200 then
            table.remove(tracksLst, t)
        end
    end

    if module.hero.life < module.hero.maxLife then
        module.hero.life = math.min(module.hero.maxLife, module.hero.life + module.hero.lireRestaurationPerSecond * dt)
    end

    -- Make the idle and moving sounds volume varying according to the tank's speed
    tankMovingSound:setVolume(1 * module.hero.speed / module.hero.tank.maxSpeed)
    tankIdleSound:setVolume(1 - .3 * module.hero.speed / module.hero.tank.maxSpeed)
end

function module.draw()
    -- Tracks
    for _,tracks in ipairs(tracksLst) do
        local tracksDistanceFromChar = math.abs(tracksIndex - tracks.index)

        love.graphics.setColor(1, 1, 1, .5 - .5 * tracksDistanceFromChar / 200)
        love.graphics.draw(tracksSrc.image, tracks.x, tracks.y, tracks.angle - math.half_pi, 1, 1, tracksSrc.offsetX, tracksSrc.offsetY)
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- Tank and weapon
    love.graphics.draw(module.hero.tank.image, module.hero.body.x, module.hero.body.y, module.hero.body.angle,
        1, 1, module.hero.tank.width / 2 + module.hero.weapon.offsetX, module.hero.tank.height / 2)

    love.graphics.draw(module.hero.weapon.image, module.hero.body.x, module.hero.body.y, module.hero.weapon.angle,
        1, 1, 5, module.hero.weapon.height / 2)

    -- Lifebar
    love.graphics.setColor(1, 1, 1, .3)
    love.graphics.rectangle("line", module.hero.body.x - 50, module.hero.body.y - 50, 102, 12)
    love.graphics.setColor(0, 0, 0, .3)
    love.graphics.rectangle("fill", module.hero.body.x - 49, module.hero.body.y - 49, 100, 10)
    love.graphics.setColor(1, 0, 0, .5)
    love.graphics.rectangle("fill", module.hero.body.x - 49, module.hero.body.y - 49, module.hero.life * module.hero.maxLife / 100, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

function module.destroy()
    tankIdleSound:stop()
    tankMovingSound:stop()
end

return module