
local tilemap = {}
local tilemaps = {}
local tilesets = {}

local function index_to_position(self, index)
    local w = self.width

    local x = (index % w) - 1
    local y = math.floor(index / w)

    return x * self.cell_size, y * self.cell_size
end

function tilemap.new_tileset(name, texture_path, cell_size)
    local texture = love.graphics.newImage(texture_path)
    local ts = {
        texture = texture,
        index_to_position = index_to_position,
        cell_size = cell_size,
        width = texture:getWidth() / cell_size,
        height = texture:getHeight() / cell_size,
    }

    tilesets[name] = ts

    return ts
end

function tilemap.new(path)
    local tm = require(path)
    table.insert(tilemaps, tm)
    return tm
end

local function draw_tile(ts, i, x, y)
    local cell_size = ts.cell_size
    local dx = x * cell_size
    local dy = y * cell_size

    local qx, qy = ts:index_to_position(i)
    local quad = love.graphics.newQuad(
        qx, qy,
        cell_size, cell_size,
        ts.texture:getDimensions())

    love.graphics.draw(
        ts.texture,
        quad,
        dx, dy,
        0,
        ts.scale, ts.scale)
end

function tilemap.draw_all()
    for _, tm in ipairs(tilemaps) do
        for layer_index, layer in ipairs(tm.layers) do
            local ts = tilesets[layer.name]
            for i, cell in ipairs(layer.data) do
                if cell ~= 0 then
                    local x = (i - 1) % layer.width
                    local y = math.floor((i - 1) / layer.width)
                    local tile_count = ts.width * ts.height
                    local index = cell - (layer_index - 1) * tile_count
                    draw_tile(ts, index, x, y) 
                end
            end
        end
    end
end

return tilemap