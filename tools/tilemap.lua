
local tilemap = {}
local tilemaps = {}

local function get_autotile_tile(t, x, y)
    local tile_state = 0

    local top = y - 1
    local left = x - 1
    local bottom = y + 1
    local right = x + 1

    if top >= 1 and t.tiles[x][top] ~= -1 then -- top
        tile_state = tile_state + 1
    end
    if right <= t.width and t.tiles[right][y] ~= -1 then -- right
        tile_state = tile_state + 2
    end
    if bottom <= t.height and t.tiles[x][bottom] ~= -1 then -- bottom
        tile_state = tile_state + 4
    end
    if left >= 1 and t.tiles[left][y] ~= -1 then -- left
        tile_state = tile_state + 8
    end

    return tile_state
end

local function set_cell_state(self, x, y, is_filled)
    if is_filled then
        self.tiles[x][y] = get_autotile_tile(self, x, y)
    else
        self.tiles[x][y] = -1
    end

    local ux = -1
    local uy = -1
    for i = 1, 9 do
        local xx = x + ux
        local yy = y + uy
        if xx >= 1 and xx <= self.width
        and yy >= 1 and yy <= self.height
        and self.tiles[xx][yy] ~= -1 then
            self.tiles[xx][yy] = get_autotile_tile(self, xx, yy)
        end

        print(ux, uy)

        ux = ux + 1
        if ux > 1 then
            ux = -1
        end
        if ux == -1 then
            uy = uy + 1
        end
    end
end

function tilemap.new(path, cell_size, width, height)
    local tiles = {}
    for _ = 1, width do
        local column = {}
        for _ = 1, height do
            table.insert(column, -1)
        end
        table.insert(tiles, column)
    end

    local t = {
        texture = love.graphics.newImage(path),
        cell_size = cell_size,
        scale = 1,
        set_cell_state = set_cell_state,
        width = width,
        height = height,
        tiles = tiles,
    }

    table.insert(tilemaps, t)

    return t
end

local function draw_tile(t, x, y)
    local state = t.tiles[x][y]
    local cell_size = t.cell_size - 1
    local dx = x * cell_size * t.scale
    local dy = y * cell_size * t.scale

    local quad = love.graphics.newQuad(
        state * t.cell_size, 0,
        cell_size, cell_size,
        t.texture:getDimensions())

    love.graphics.draw(
        t.texture,
        quad,
        dx, dy,
        0,
        t.scale, t.scale)
end

function tilemap.draw_all()
    for _, t in ipairs(tilemaps) do
        for x = 1, #t.tiles do
            for y = 1, #t.tiles[x] do
                if t.tiles[x][y] ~= -1 then
                    draw_tile(t, x, y)
                end
            end
        end
    end
end

return tilemap