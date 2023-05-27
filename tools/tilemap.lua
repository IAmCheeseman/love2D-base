local module = {}
local tilemaps = {}

--- Returns a layer from a tilemap
---@param tilemap table
---@param layer_name string
local function get_layer(tilemap, layer_name)
    for _, layer in ipairs(tilemap.layers) do
        if layer.name == layer_name then
            return layer
        end
    end
    return nil
end

--- Checks if the tile at x and y is filled, x and y are in global coordinates
---@param tilemap table
---@param layer_name string
---@param x number
---@param y number
local function is_cell_filled(tilemap, layer_name, x, y)
    local layer = tilemap:get_layer(layer_name)
    local tileset = Tileset.get_tileset(layer_name)

    local layer_x = math.floor(x / tileset.cell_size + 1)
    local layer_y = math.floor(y / tileset.cell_size + 0.25)
    local index = layer_y * layer.height + layer_x
    return layer.data[index] ~= 0
end

local function add_objects(layer)
    for _, object_data in ipairs(layer.objects) do
        local object = Objects.create_object_at(
            object_data.name, 
            object_data.x, object_data.y)
        for name, value in pairs(object_data.properties) do
            object[name] = value
        end
    end
end

--- Create a new tilemap
---@param path string
function module.new(path)
    local tilemap = require(path)
    tilemap.is_cell_filled = is_cell_filled
    tilemap.get_layer = get_layer
    
    for i = #tilemap.layers, 1, -1 do
        local layer = tilemap.layers[i]
        if layer.type == "objectgroup" then
            add_objects(layer)
            table.remove(tilemap.layers, i)
        end
        if layer.type == "imagelayer" then
            if layer.name == "Background" then
                tilemap.background_image = love.graphics.newImage(layer.image)
                tilemap.background_image:setWrap("repeat")
            end
            table.remove(tilemap.layers, i)
        end
    end

    table.insert(tilemaps, tilemap)

    return tilemap
end

function module.draw_all()
    for _, tilemap in ipairs(tilemaps) do
        if tilemap.background_image then
            local quad = love.graphics.newQuad(
                0, 0, 
                tilemap.width * tilemap.tilewidth,
                tilemap.height * tilemap.tileheight,
                tilemap.background_image:getWidth(),
                tilemap.background_image:getHeight())
            love.graphics.draw(
                tilemap.background_image,
                quad,
                0, 0)
        end


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