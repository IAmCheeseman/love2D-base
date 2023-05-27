local module = {}
local tilesets = {}
local tiles = {}

local function index_to_position(self, index)
    local w = self.width

    local x = (index % w) - 1
    local y = math.floor(index / w)

    return x * self.cell_size, y * self.cell_size
end

function module.draw_tile(index, x, y)
    local tile = tiles[index]
    local cell_size = tile.tileset.cell_size
    local draw_x = x * cell_size
    local draw_y = y * cell_size

    love.graphics.draw(
        tile.tileset.texture,
        tile.quad,
        draw_x, draw_y,
        0,
        tile.tileset.scale, tile.tileset.scale)
end

--- Gets the tileset with the specified name
---@param name string
function module.get_tileset(name)
    return tilesets[name]
end

--- Create a new tileset
---@param name string
---@param texture_path string
---@param cell_size integer
function module.new(name, texture_path, cell_size)
    local texture = love.graphics.newImage(texture_path)
    local tileset = {
        texture = texture,
        index_to_position = index_to_position,
        cell_size = cell_size,
        width = texture:getWidth() / cell_size,
        height = texture:getHeight() / cell_size,
        draw_tile = draw_tile,
    }

    for y = 0, tileset.height - 1 do
        for x = 0, tileset.width - 1 do
            table.insert(tiles, {
                tileset = tileset,
                quad = love.graphics.newQuad(
                    x * cell_size, y * cell_size,
                    cell_size, cell_size,
                    texture:getWidth(), texture:getHeight()
                )
            })
        end
    end

    tilesets[name] = tileset

    return tileset
end

return module