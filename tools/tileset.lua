local tileset = {}
local tilesets = {}

local function index_to_position(self, index)
    local w = self.width

    local x = (index % w) - 1
    local y = math.floor(index / w)

    return x * self.cell_size, y * self.cell_size
end

local function draw_tile(self, i, x, y)
    local cell_size = self.cell_size
    local dx = x * cell_size
    local dy = y * cell_size

    local qx, qy = self:index_to_position(i)
    local quad = love.graphics.newQuad(
        qx, qy,
        cell_size, cell_size,
        self.texture:getDimensions())

    love.graphics.draw(
        self.texture,
        quad,
        dx, dy,
        0,
        self.scale, self.scale)
end

function tileset.get_tileset(name)
    return tilesets[name]
end

function tileset.new(name, texture_path, cell_size)
    local texture = love.graphics.newImage(texture_path)
    local ts = {
        texture = texture,
        index_to_position = index_to_position,
        cell_size = cell_size,
        width = texture:getWidth() / cell_size,
        height = texture:getHeight() / cell_size,
        draw_tile = draw_tile,
    }

    tilesets[name] = ts

    return ts
end

return tileset