local tilemap = {}
local tilemaps = {}

function tilemap.new(path)
    local tm = require(path)
    table.insert(tilemaps, tm)
    return tm
end

function tilemap.draw_all()
    for _, tm in ipairs(tilemaps) do
        for layer_index, layer in ipairs(tm.layers) do
            local ts = Tileset.get_tileset(layer.name)
            for i, cell in ipairs(layer.data) do
                if cell ~= 0 then
                    local x = (i - 1) % layer.width
                    local y = math.floor((i - 1) / layer.width)
                    local tile_count = ts.width * ts.height
                    local index = cell - (layer_index - 1) * tile_count
                    ts:draw_tile(index, x, y) 
                end
            end
        end
    end
end

return tilemap