local module = {}

local path = (...):gsub("objects.room$", "")
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

function module.get_cell(layer_name, x, y)
    local layer = layers[layer_name]
    if layer.type ~= "IntGrid" then
        error("Can only test IntGrids.")
    end

    local height = module.level.width / layer.gridSize
    local layer_x = math.floor(x / layer.gridSize) + 1
    local layer_y = math.floor(y / layer.gridSize)
    local index = layer_y * height + layer_x
    return layer.grid[index]
end

local function does_entity_have_tag(entity, tag)
    for i, v in ipairs(entity.tags) do
        if v == tag then
            return true
        end
    end
    return false
end

local function convert_property(property, entity)
    if property.type == "Point" then
        return { 
            x = property.value.cx * entity.gridSize,
            y = property.value.cy * entity.gridSize,
        }
    elseif property.type == "Array<Point>" then
        local corrected = {}
        for i, v in ipairs(property.value) do
            table.insert(corrected, convert_property({ type = "Point", value = v }, entity))
        end
        return corrected
    end

    return property.value
end

function ldtk.onEntity(entity)
    if not Objects.does_type_exist(entity.id) then
        error("LDtk type '" .. entity.id .. "' does not exist. (Room '" .. module.level.id .. "')")
    end

    local object = Objects.instance_at(entity.id, entity.x, entity.y)
    for k, v in pairs(entity.props) do
        object[k] = convert_property(v, entity)
    end

    if does_entity_have_tag(entity, "AABB") then
        local aabb = AABB.new(
            entity.x, entity.y, 
            entity.width, entity.height, 
            entity.id, entity.props.identifier)

        object.aabb = aabb
    end
end

function ldtk.onLevelLoaded(level)
    module.level = level
    bg_texture = love.graphics.newImage(ldtk_path .. level.backgroundImage)
    bg_texture:setWrap("repeat", "repeat")
    layers = {}
    layer_draw_order = {}
end

function ldtk.onLayer(layer)
    layers[layer.id] = layer
    table.insert(layer_draw_order, layer.id)
end

return module