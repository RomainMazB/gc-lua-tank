local module = {}


local hero, projectiles, camera
function module.load(game)
    hero = game.Player.hero
    projectiles = game.Projectiles
    camera = game.Camera
end

function module.handleKeyboardControls(dt)
    -- On Z key pressure, increase the acceleration if necessary
    if love.keyboard.isDown("z") and hero.speed < hero.tank.maxSpeed then
        hero.speed = math.min(hero.tank.maxSpeed, hero.speed + hero.tank.maxSpeed / 3 * dt)

    -- On S key pressure, decrease the acceleration and then move forward
    elseif love.keyboard.isDown("s") then
        hero.speed = math.max(-hero.tank.forwardMaxSpeed, hero.speed - hero.tank.maxSpeed / 3 * dt)

    -- If no speed key (Z or S) is pressed and the tank is moving,
    -- slowly decrease/increase the speed to get the velocity back to 0
    elseif hero.speed ~= 0 then
        hero.speed = hero.speed - hero.speed / 2 * dt

        -- Because Lua can't round with a specific decimals number,
        -- we multiply the speed by 100 to increase the precision
        if hero.speed < 0 then
            hero.speed = math.ceil(hero.speed*100)/100
        else
            hero.speed = math.floor(hero.speed*100)/100
        end
    end

    -- On D key pressure, rotate the tank to the right
    if love.keyboard.isDown("d") then
        local tankRotationDt = hero.tank.rotationSpeed / 2 * dt
        local newAngle = hero.body.angle + tankRotationDt
        hero.body.angle = newAngle
        hero.weapon.angle = hero.weapon.angle + tankRotationDt
    end

    -- On Q key pressure, rotate the tank to the left
    if love.keyboard.isDown("q") then
        local tankRotationDt = hero.tank.rotationSpeed / 2 * dt
        local newAngle = hero.body.angle - tankRotationDt
        hero.body.angle = newAngle
        hero.weapon.angle = hero.weapon.angle - tankRotationDt
    end
end

function module.handleMouseControls(dt)
    local mouseX, mouseY = camera:getMousePosition()
    -- The weapon follows the mouse as fast as the weapon rotation speed allows it
    local tankToMouseAngle = math.atan2(mouseY - hero.body.y, mouseX - hero.body.x)
    local angleDifference = math.atan2(math.sin(tankToMouseAngle-hero.weapon.angle), math.cos(tankToMouseAngle-hero.weapon.angle))
    if angleDifference > 0 then
        hero.weapon.angle = hero.weapon.angle + hero.weapon.rotationSpeed * dt
    else
        hero.weapon.angle = hero.weapon.angle - hero.weapon.rotationSpeed * dt
    end
end

function module.mousepressed(_, _, button)
    -- On primary key press, fire a new bullet
    if button == 1 then
        local weaponCosAngle = math.cos(hero.weapon.angle)
        local weaponSinAngle = math.sin(hero.weapon.angle)

        -- Calculate the offset point to make the bullet start at the end of the weapon
        -- And so does the bang!
        local offsetX = weaponCosAngle * (hero.weapon.width - hero.weapon.offsetX) - hero.weapon.offsetX
        local offsetY = weaponSinAngle * (hero.weapon.width - hero.weapon.offsetX)
        local bulletStartingX = hero.body.x + hero.weapon.offsetX + offsetX
        local bulletStartingY = hero.body.y + hero.weapon.offsetY + offsetY

        -- Calculate the bullet's velocity and add the tank's velocity to it
        local bulletVx = weaponCosAngle * hero.weapon.bulletSpeed
        local bulletVy = weaponSinAngle * hero.weapon.bulletSpeed
        local bulletOffsetHyp = hero.body:distanceToCenterOf({x = bulletStartingX, y = bulletStartingY})
        projectiles.new(projectiles.KINDS.ALLY, bulletStartingX, bulletStartingY, bulletVx, bulletVy, hero.body.vx, hero.body.vy, hero.weapon.angle, hero.weapon.range - bulletOffsetHyp)
    end
end

return module