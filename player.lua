local Player = {
    x = 0,
    y = 0,
    vx = 0,
    vy = 0,
    width = 0,
    height = 0,
    angle = -HALF_PI,
    weaponAngle = -HALF_PI,
    speed = 0,
    isFiring = false,
    life = 100,
    maxLife = 100,
    tank = {
        image = love.graphics.newImage("assets/images/tanks/tankBody_bigRed_outline.png"),
        width = 0,
        height = 0,
        maxSpeed = 80,
        rotationSpeed = HALF_PI,
        weaponCenterX = 8,
        weapon = {
            image = love.graphics.newImage("assets/images/weapons/tankRed_barrel2_outline.png"),
            width = 0,
            height = 0,
            damage = 10,
            rotationSpeed = HALF_PI,
            bulletSpeed = 250,
            offsetX = 0,
            offsetY = 0,
            lastTimeShot = 0,
            range = 400
        }
    }
}

function Player.load()
    Player.tank.width = Player.tank.image:getWidth()
    Player.tank.height = Player.tank.image:getHeight()
    Player.width = Player.tank.image:getWidth()
    Player.height = Player.tank.image:getHeight()
    Player.tank.weapon.width = Player.tank.weapon.image:getWidth()
    Player.tank.weapon.height = Player.tank.weapon.image:getHeight()

    -- Put the player's tank at the bottom of the map
    Player.y = (MAP_HEIGHT-2) * TILE_SIZE
    Player.x = MAP_WIDTH / 2 * TILE_SIZE
end

function Player.draw (dt)
    love.graphics.draw(Player.tank.image, Player.x, Player.y, Player.angle,
        1, 1, Player.tank.width / 2 + Player.tank.weaponCenterX, Player.tank.height / 2)

    love.graphics.draw(Player.tank.weapon.image, Player.x, Player.y, Player.weaponAngle,
        1, 1, 5, Player.tank.weapon.height / 2)
end

function Player.update(dt)
    local playerCosAngle = math.cos(Player.angle)
    local playerSinAngle = math.sin(Player.angle)
    Player.vx = playerCosAngle * Player.speed
    Player.vy = playerSinAngle * Player.speed

    Player.x = Player.x + Player.vx * dt
    Player.y = Player.y + Player.vy * dt
end

return Player