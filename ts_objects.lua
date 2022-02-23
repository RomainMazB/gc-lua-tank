local Ts_objects = {
  TileTextures = {},
  TilesIndex = {}
}

function Ts_objects.load()
  Ts_objects.TileTextures["barricade_metal"] = love.graphics.newImage("assets/images/misc/barricadeMetal.png")
  Ts_objects.TileTextures["barricade_wood"] = love.graphics.newImage("assets/images/misc/barricadeWood.png")
  Ts_objects.TileTextures["tree_brown_large"] = love.graphics.newImage("assets/images/misc/treeBrown_large.png")
  Ts_objects.TileTextures["tree_brown_twigs"] = love.graphics.newImage("assets/images/misc/treeBrown_twigs.png")
  Ts_objects.TileTextures["crate_metal"] = love.graphics.newImage("assets/images/misc/crateMetal.png")
  Ts_objects.TileTextures["crate_wood"] = love.graphics.newImage("assets/images/misc/crateWood.png")
  Ts_objects.TileTextures["barrel_black_side"] = love.graphics.newImage("assets/images/misc/barrelBlack_side.png")
  Ts_objects.TileTextures["barrel_black_top"] = love.graphics.newImage("assets/images/misc/barrelBlack_top.png")
  Ts_objects.TileTextures["barrel_green_side"] = love.graphics.newImage("assets/images/misc/barrelGreen_side.png")
  Ts_objects.TileTextures["barrel_green_top"] = love.graphics.newImage("assets/images/misc/barrelGreen_top.png")
  Ts_objects.TileTextures["barrel_red_side"] = love.graphics.newImage("assets/images/misc/barrelRed_side.png")
  Ts_objects.TileTextures["barrel_red_top"] = love.graphics.newImage("assets/images/misc/barrelRed_top.png")
  Ts_objects.TileTextures["barrel_rust_side"] = love.graphics.newImage("assets/images/misc/barrelRust_side.png")
  Ts_objects.TileTextures["barrel_rust_top"] = love.graphics.newImage("assets/images/misc/barrelRust_top.png")
  Ts_objects.TileTextures["fence_red"] = love.graphics.newImage("assets/images/misc/fenceRed.png")
  Ts_objects.TileTextures["fence_yellow"] = love.graphics.newImage("assets/images/misc/fenceYellow.png")
  Ts_objects.TileTextures["oil_spill_large"] = love.graphics.newImage("assets/images/misc/oilSpill_large.png")
  Ts_objects.TileTextures["oil_spill_small"] = love.graphics.newImage("assets/images/misc/oilSpill_small.png")
  Ts_objects.TileTextures["sandbag_beige"] = love.graphics.newImage("assets/images/misc/sandbagBeige.png")
  Ts_objects.TileTextures["sandbag_beige_open"] = love.graphics.newImage("assets/images/misc/sandbagBeige_open.png")
  Ts_objects.TileTextures["sandbag_brown"] = love.graphics.newImage("assets/images/misc/sandbagBrown.png")
  Ts_objects.TileTextures["sandbag_brown_open"] = love.graphics.newImage("assets/images/misc/sandbagBrown_open.png")
  Ts_objects.TileTextures["wire_crooked"] = love.graphics.newImage("assets/images/misc/wireCrooked.png")
  Ts_objects.TileTextures["wire_straight"] = love.graphics.newImage("assets/images/misc/wireStraight.png")
end

return Ts_objects