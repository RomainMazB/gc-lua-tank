local module = {}

local level
function module.load(game)
    -- Inject dependencies
    level = game.Level

    -- Setup the hero
    module.hero = {
        speed = 0,
        isFiring = false,
        life = 100,
        maxLife = 100,
        tank = {
            image,
            width = 0,
            height = 0,
            speed = 0,
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
            offsetX = 0,
            offsetY = 0,
            lastTimeShot = 0,
            range = 400,
            offsetX = 8
        }
    }

    -- Load assets
    module.hero.tank.image = love.graphics.newImage("assets/images/tanks/tankBody_bigRed_outline.png")
    module.hero.tank.width = module.hero.tank.image:getWidth()
    module.hero.tank.height = module.hero.tank.image:getHeight()
    module.hero.weapon.image = love.graphics.newImage("assets/images/weapons/tankRed_barrel2_outline.png")
    module.hero.weapon.width = module.hero.weapon.image:getWidth()
    module.hero.weapon.height = module.hero.weapon.image:getHeight()

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

    module.hero.body:move(dt)
end

function module.draw()
    love.graphics.draw(module.hero.tank.image, module.hero.body.x, module.hero.body.y, module.hero.body.angle,
        1, 1, module.hero.tank.width / 2 + module.hero.weapon.offsetX, module.hero.tank.height / 2)

    love.graphics.draw(module.hero.weapon.image, module.hero.body.x, module.hero.body.y, module.hero.weapon.angle,
        1, 1, 5, module.hero.weapon.height / 2)
end

return module