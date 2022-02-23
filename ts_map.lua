TILE_SIZE = 64

local Ts_map = {
    TileSheet = {},
    TileTextures = {},
    TilesIndex = {}
}

function Ts_map.load()
    Ts_map.TileSheet = love.graphics.newImage("assets/images/map_tilesheet.png")
    local nbColumns = Ts_map.TileSheet:getWidth() / TILE_SIZE
    local nbLines = Ts_map.TileSheet:getHeight() / TILE_SIZE
    local id = 1

    Ts_map.TileTextures[0] = nil
    for l=1,nbLines do
      for c=1,nbColumns do
        Ts_map.TileTextures[id] = love.graphics.newQuad(
          (c-1)*TILE_SIZE, (l-1)*TILE_SIZE,
          TILE_SIZE, TILE_SIZE,
          Ts_map.TileSheet:getWidth(), Ts_map.TileSheet:getHeight()
        )
        id = id + 1
      end
    end

    -- Grass
    Ts_map.TilesIndex["g"] = 1 -- Grass
    Ts_map.TilesIndex["g2"] = 11 -- Grass2

    -- Grass Roads
    Ts_map.TilesIndex["g_r_I_ns"] = 2 -- Grass Road I North South
    Ts_map.TilesIndex["g_r_I_ew"] = 3 -- Grass Road I East West
    Ts_map.TilesIndex["g_r_T_nes"] = 4 -- Grass Road T North East South
    Ts_map.TilesIndex["g_r_T_nsw"] = 5 -- Grass Road T North South West
    Ts_map.TilesIndex["g_r_T_new"] = 6 -- Grass Road T North East West
    Ts_map.TilesIndex["g_r_T_esw"] = 7 -- Grass Road T East South West
    Ts_map.TilesIndex["g_r_+c"] = 12 -- Grass Road + Curved
    Ts_map.TilesIndex["g_r_+"] = 13 -- Grass Road +
    Ts_map.TilesIndex["g_r_90_es"] = 14 -- Grass Road 90° East South
    Ts_map.TilesIndex["g_r_90_sw"] = 15 -- Grass Road 90° South West
    Ts_map.TilesIndex["g_r_90_ne"] = 16 -- Grass Road 90° North East
    Ts_map.TilesIndex["g_r_90_nw"] = 17 -- Grass Road 90° North West

    -- Sand
    Ts_map.TilesIndex["s"] = 21 -- Sand
    Ts_map.TilesIndex["s2"] = 31 -- Sand2

    -- Sand Roads
    Ts_map.TilesIndex["s_r_I_ns"] = 22 -- Sand Road I North South
    Ts_map.TilesIndex["s_r_I_ew"] = 23 -- Sand Road I East West
    Ts_map.TilesIndex["s_r_nes"] = 24 -- Sand Road North East South
    Ts_map.TilesIndex["s_r_nsw"] = 25 -- Sand Road North South West
    Ts_map.TilesIndex["s_r_new"] = 26 -- Sand Road North East West
    Ts_map.TilesIndex["s_r_esw"] = 27 -- Sand Road East South West
    Ts_map.TilesIndex["s_r_+c"] = 32 -- Sand Road + Curved
    Ts_map.TilesIndex["s_r_+"] = 33 -- Sand Road +
    Ts_map.TilesIndex["s_r_90_es"] = 34 -- Sand Road 90° East South
    Ts_map.TilesIndex["s_r_90_sw"] = 35 -- Sand Road 90° South West
    Ts_map.TilesIndex["s_r_90_ne"] = 36 -- Sand Road 90° North East
    Ts_map.TilesIndex["s_r_90_nw"] = 37 -- Sand Road 90° North West

    -- Grass to Sand transitions
    Ts_map.TilesIndex["gs_we"] = 8 -- Grass to Sand West to East
    Ts_map.TilesIndex["gs_ew"] = 9 -- Grass to Sand East to West
    Ts_map.TilesIndex["gs_ns"] = 18 -- Grass to Sand North to South
    Ts_map.TilesIndex["gs_sn"] = 19 -- Grass to Sand South to North

    -- Grass to Sand Road transitions
    Ts_map.TilesIndex["gs_r_we"] = 28 -- Grass to Sand Road West To East
    Ts_map.TilesIndex["gs_r_ew"] = 29 -- Grass to Sand Road East To West
    Ts_map.TilesIndex["gs_r_sn"] = 38 -- Grass to Sand Road South to North
    Ts_map.TilesIndex["gs_r_ns"] = 39 -- Grass to Sand Road North to South

    -- Grass to Sand Dirty Road transitions
    Ts_map.TilesIndex["gs_dr_ew"] = 10 -- Grass to Sand Dirty Road East to West
    Ts_map.TilesIndex["gs_dr_ns"] = 20 -- Grass to Sand Dirty Road North to South
    Ts_map.TilesIndex["gs_dr_we"] = 30 -- Grass to Sand Dirty Road West to East
    Ts_map.TilesIndex["gs_dr_sn"] = 40 -- Grass to Sand Dirty Road South to North
end

return Ts_map