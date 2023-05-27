local tilemap = {}
local tilemaps = {}

local function add_objects(layer)
    for _, object in ipairs(layer.objects) do
        Objects.create_object_at(
            object.name, 
            object.x, object.y)
    end
end

function tilemap.new(path)
    local tm = require(path)
    
    for i = #tm.layers, 1, -1 do
        local layer = tm.layers[i]
        if layer.type == "objectgroup" then
            add_objects(layer)
            table.remove(tm.layers, i)
        end
    end

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