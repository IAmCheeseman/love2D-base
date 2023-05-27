local module = {}
local tilemaps = {}

local function add_objects(layer)
    for _, object in ipairs(layer.objects) do
        Objects.create_object_at(
            object.name, 
            object.x, object.y)
    end
end

function module.new(path)
    local tilemap = require(path)
    
    for i = #tilemap.layers, 1, -1 do
        local layer = tilemap.layers[i]
        if layer.type == "objectgroup" then
            add_objects(layer)
            table.remove(tilemap.layers, i)
        end
    end

    table.insert(tilemaps, tilemap)

    return tilemap
end

function module.draw_all()
    for _, tilemap in ipairs(tilemaps) do
        for layer_index, layer in ipairs(tilemap.layers) do
            local tileset = Tileset.get_tileset(layer.name)
            for i, cell in ipairs(layer.data) do
                if cell ~= 0 then
                    local x = (i - 1) % layer.width
                    local y = math.floor((i - 1) / layer.width)
                    local tile_count = tileset.width * tileset.height
                    local index = cell - (layer_index - 1) * tile_count
                    tileset:draw_tile(index, x, y) 
                end
            end
        end
    end
end

return module