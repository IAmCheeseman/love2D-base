local module = {}

local path = (...):gsub("objects.room$", "")
local ldtk = require(path .. "tools.thirdparty.ldtklove.ldtk")
local grid = require(path .. "tools.thirdparty.jumper.grid")
local jumper = require(path .. "tools.thirdparty.jumper.pathfinder")

local map = {}
local pathfinding_grid = {}
local pathfinder = nil

local current = ""
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

    Objects.call_on_all("on_room_change", room_name)

    current = room_name
end

function module.is_room_in_range(room) 
    return room < ldtk.countOfLevels
end

function module.reset()
    module.change_to(current)
end

function module.get_cell(layer_name, x, y)
    local layer = layers[layer_name]
    if layer.type ~= "IntGrid" then
        error("Can only test IntGrids.")
    end

    local width = module.level.width / layer.gridSize
    local layer_x = math.floor(x / layer.gridSize) + 1
    local layer_y = math.floor(y / layer.gridSize)
    local index = layer_y * width + layer_x
    return layer.grid[index]
end

function module.get_cell_l(layer_name, x, y)
    local layer = layers[layer_name]
    if layer.type ~= "IntGrid" then
        error("Can only test IntGrids.")
    end

    local width = module.level.width / layer.gridSize
    local layer_x = x
    local layer_y = y
    local index = layer_y * width + layer_x
    return layer.grid[index]
end

function module.get_path(layer_name, sx, sy, ex, ey)
    local layer = layers[layer_name]
    if layer.type ~= "IntGrid" then
        error("Can only use IntGrids.")
    end

    local rsx, rsy = math.floor(sx / layer.gridSize), math.floor(sy / layer.gridSize)
    local rex, rey = math.floor(ex / layer.gridSize), math.floor(ey / layer.gridSize)

    local path, length = pathfinder:getPath(rsx, rsy, rex, rey)
    if path == nil then
        return Vector.direction_between(sx, sy, ex, ey)
    end

    local n1, n2
    for node, count in path:iter() do
        if count == 1 then
            n1 = node
        elseif count == 2 then
            n2 = node
        else
            break
        end
    end

    return Vector.direction_between(
        n1:getX() + layer.gridSize / 2, n1:getY() + layer.gridSize / 2, 
        n2:getX() + layer.gridSize / 2, n2:getY() + layer.gridSize / 2)
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
    elseif property.type == "Color" then
       local rgb = ldtk.hex2rgb(property.value)
       return {
            r = rgb[1],
            g = rgb[2],
            b = rgb[3],
       }
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

local function printtable(table)
    io.write("{")
    for i, v in ipairs(table) do
        if type(v) == "table" then
            printtable(v)
        else
            io.write(v .. ",")
        end
    end
    io.write("},\n")
end

function ldtk.onLevelCreated(level)
    map = {}

    for y = 1, level.height / 16 do
        table.insert(map, {})
        for x = 1, level.width / 16 do
            local cell = module.get_cell_l("Solids", x, y)
            local cell_is_walkable = false
            for _, v in ipairs(level.props.valid_cells) do
                if cell == v then
                    cell_is_walkable = true
                    break
                end
            end

            if cell_is_walkable then
                table.insert(map[y], 0)
            else
                table.insert(map[y], 1)
            end
        end
    end

    pathfinding_grid = grid(map)
    pathfinder = jumper(pathfinding_grid, "THETASTAR", 0)
    -- pathfinder:setMode('ORTHOGONAL')
end

return module