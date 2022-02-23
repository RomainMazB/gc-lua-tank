local controls = {
    doubleCrosshair = {
        isDisplayed = false,
        image = love.graphics.newImage("assets/images/crosshair.png"),
        width = 0,
        height = 0,
        x = 0,
        y = 0
    }
}

controls.doubleCrosshair.width = controls.doubleCrosshair.image:getWidth()
controls.doubleCrosshair.height = controls.doubleCrosshair.image:getHeight()

function controls.handleKeyboardControls(dt)
    -- On Z key pressure, increase the acceleration if necessary
    if love.keyboard.isDown("z") and Player.speed < Player.tank.maxSpeed then
        Player.speed = math.min(Player.tank.maxSpeed, Player.speed + Player.tank.maxSpeed / 3 * dt)

    -- On S key pressure, decrease the acceleration and then move forward
    elseif love.keyboard.isDown("s") then
        local forwardMaxSpeed = Player.tank.maxSpeed / 2
        Player.speed = math.max(-forwardMaxSpeed, Player.speed - Player.tank.maxSpeed / 3 * dt)

    -- If no speed key (Z or S) is pressed and the tank is moving,
    -- slowly decrease/increase the speed to get the velocity back to 0
    elseif Player.speed ~= 0 then
        Player.speed = Player.speed - Player.speed / 2 * dt

        -- Because Lua can't round with a specific decimals number,
        -- we multiply the speed by 100 to increase the precision
        if Player.speed < 0 then
            Player.speed = math.ceil(Player.speed*100)/100
        else
            Player.speed = math.floor(Player.speed*100)/100
        end
    end

    -- On D key pressure, rotate the tank to the right
    if love.keyboard.isDown("d") then
        local tankRotationDt = Player.tank.rotationSpeed / 2 * dt
        local newAngle = Player.angle + tankRotationDt
        Player.angle = newAngle
        Player.weaponAngle = Player.weaponAngle + tankRotationDt
    end

    -- On Q key pressure, rotate the tank to the left
    if love.keyboard.isDown("q") then
        local tankRotationDt = Player.tank.rotationSpeed / 2 * dt
        local newAngle = Player.angle - tankRotationDt
        Player.angle = newAngle
        Player.weaponAngle = Player.weaponAngle - tankRotationDt
    end
end

function controls.handleMouseControls(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    -- The weapon follows the mouse as fast as the weapon rotation speed allows it
    mouseX = mouseX - Camera.x
    mouseY = mouseY - Camera.y
    local tankToMouseAngle = math.atan2(mouseY - Player.y, mouseX - Player.x)
    local angleDifference = math.atan2(math.sin(tankToMouseAngle-Player.weaponAngle), math.cos(tankToMouseAngle-Player.weaponAngle))
    if angleDifference > 0 then
        Player.weaponAngle = Player.weaponAngle + Player.tank.weapon.rotationSpeed * dt
    else
        Player.weaponAngle = Player.weaponAngle - Player.tank.weapon.rotationSpeed * dt
    end

    -- Calculate the position of the crosshair depending to the range of the weapon
    local distanceToMouse = math.sqrt((Player.x - mouseX)^2 + (Player.y - mouseY)^2)
    -- When the distance the to mouse is greater than the weapon range
    -- We'll draw a second crosshair to visualize the end of the bullet's run
    if distanceToMouse > Player.tank.weapon.range then
        local crosshairOffset = Pathfinding.lerpPoint(Player.x, Player.y, mouseX, mouseY, Player.tank.weapon.range/distanceToMouse)
        controls.doubleCrosshair.x = crosshairOffset.x
        controls.doubleCrosshair.y = crosshairOffset.y
        controls.doubleCrosshair.isDisplayed = true
    else
        controls.doubleCrosshair.isDisplayed = false
    end
end

function love.keypressed(key)
    -- On escape key, quit the game
    if key == 'escape' then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button)
    -- On primary key press, fire a new bullet
    if button == 1 then
        local weaponCosAngle = math.cos(Player.weaponAngle)
        local weaponSinAngle = math.sin(Player.weaponAngle)

        -- Calculate the offset point to make the bullet start at the end of the weapon
        -- And so does the bang!
        local offsetX = weaponCosAngle * Player.tank.weapon.width
        local offsetY = weaponSinAngle * Player.tank.weapon.width
        local bulletStartingX = Player.x + Player.tank.weapon.offsetX + offsetX
        local bulletStartingY = Player.y + Player.tank.weapon.offsetY + offsetY

        -- Calculate the bullet's velocity and add the tank's velocity to it
        local bulletVx = weaponCosAngle * Player.tank.weapon.bulletSpeed + Player.vx
        local bulletVy = weaponSinAngle * Player.tank.weapon.bulletSpeed + Player.vy
        local bulletOffsetHyp = Collisions.distanceToCenter(Player, {x = bulletStartingX, y = bulletStartingY})
        Projectiles.new(bulletStartingX, bulletStartingY, bulletVx, bulletVy, Player.vx, Player.vy, Player.weaponAngle, Player.tank.weapon.range - bulletOffsetHyp)
    else
        Enemies.new(1000, 1000, 0, 0, 0)
    end
end

function controls.draw()
    if controls.doubleCrosshair.isDisplayed then
        love.graphics.draw(controls.doubleCrosshair.image, controls.doubleCrosshair.x, controls.doubleCrosshair.y, 0, 1, 1, controls.doubleCrosshair.width / 2, controls.doubleCrosshair.height / 2)
    end
end

return controls