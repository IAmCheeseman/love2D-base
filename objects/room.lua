local module = {}

local path = (...):gsub("objects.room", "")
local ldtk = require(path .. "tools.thirdparty.ldtklove.ldtk")

local ldtk_path = ""
local bg_texture = nil
local layers = {}
local layer_draw_order = {}

function module.initialize(ldtk_dir, ldtk_name, default_room)
    ldtk_path = ldtk_dir
    ldtk:load(ldtk_path .. ldtk_name)
    Room.change_to(default_room)
end

function module.draw()
    local quad = love.graphics.newQuad(
        0, 0,
        module.level.width, module.level.height,
        bg_texture:getWidth(), bg_texture:getHeight())
    love.graphics.draw(bg_texture, quad, 0, 0)

    for i = #layer_draw_order, 1, -1 do
        layers[layer_draw_order[i]]:draw()
    end
end

function module.change_to(room_name)
    Objects.clear()
    module.current = room_name
    ldtk:level(room_name)
end

function module.is_cell_filled(layer_name, x, y)
    local layer = layers[layer_name]
    if layer.type ~= "IntGrid" then
        error("Can only test IntGrids.")
    end

    local height = module.level.width / layer.gridSize
    local layer_x = math.floor(x / layer.gridSize) + 1
    local layer_y = math.floor(y / layer.gridSize)
    local index = layer_y * height + layer_x
    return layer.grid[index] ~= 0
end

function ldtk.onEntity(entity)
    Objects.create_object_at(entity.id, entity.x, entity.y)
end

function ldtk.onLevelLoaded(level)
    module.level = level
    bg_texture = love.graphics.newImage(ldtk_path .. level.backgroundImage)
    bg_texture:setWrap("repeat", "repeat")
    layers = {}
end

function ldtk.onLayer(layer)
    layers[layer.id] = layer
    table.insert(layer_draw_order, layer.id)
end

return module