local path = (...):gsub("%objects.object", "")
local timers = require(path .. "objects.timer")

local module = {
    are_paused = false,
}

local objects = {}
local object_types = {}
local create_queue = {}

local function deep_copy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = deep_copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function is_object_paused(object)
    return module.are_paused and object.pause_mode ~= "never"
end

function module.process_object(object, dt)
    if object.sprite ~= nil then
        Sprite.process(object.sprite, dt)
    end
    timers.process(object, dt)

    if object.on_update then
        object:on_update(dt)
    end
end

function module.process_objects(dt)
    for _, object in ipairs(create_queue) do
        table.insert(objects, object)
    end
    for _, object in ipairs(create_queue) do
        if object.on_create then
            object:on_create()
        end
    end
    create_queue = {}

    for _, object in ipairs(objects) do
        if not is_object_paused(object) then
            module.process_object(object, dt)
        end
    end
end

--- What gets called if there is no draw function defined
---@param self table
function module.default_draw(self)
    if self.sprite == nil then
        return
    end

    self.sprite:draw(self.x, self.y)
end

function module.draw_objects()
    local sorted_objects = table.sort(objects, function(a, b) return a.depth < b.depth end)
    for _, object in ipairs(objects) do
        love.graphics.setColor(1, 1, 1)
        object:on_draw()
    end
end

--- Calls a function on every object that defines it
---@param function_name string
function module.call_on_all(function_name, ...)
    for _, object in ipairs(objects) do
        if object[function_name] ~= nil and not is_object_paused(object) then
            object[function_name](object, ...)
        end
    end
end

local function set_property_default(object, property, value)
    if object[property] ~= nil then
        return
    end
    object[property] = value
end

--- Create an object type
---@param name string
---@param object function
function module.create_type(name, object)
    if object_types[name] ~= nil then
        error("Object with the name of '" .. name .. "' already exists.")
    end

    set_property_default(object, "x", 0)
    set_property_default(object, "y", 0)
    set_property_default(object, "depth", 1)
    set_property_default(object, "pause_mode", "normally")

    object.type = name
    object.create_timer = timers.create_timer
    object.timers = {}

    if object.on_draw == nil then
        object.on_draw = module.default_draw
    end

    object_types[name] = object
end

--- Calls a function from the base type
---@param self table
---@param name string
local function call_from_base(self, name, ...)
    object_types[self.inherits_from][name](...)
end

--- Creates a new type that inherits from another type
---@param name string
---@param inherited string
---@param object table
function module.create_type_from(name, inherited, object)
    if object_types[name] ~= nil then
        error("Object with the name of '" .. name .. "' already exists.")
    end
    if object_types[inherited] == nil then
        error("'" .. name .. "' cannot inherit '" .. inherited .. "' because it does not exist.")
    end

    local derived = deep_copy(object_types[inherited])

    for k, v in pairs(object) do
        derived[k] = v
    end

    derived.inherits_from = inherited
    derived.call_from_base = call_from_base

    object_types[name] = derived
end

function module.does_type_exist(type_name)
    return object_types[type_name] ~= nil
end

--- Creates an object
---@param object_type string
---@return table
function module.create_object(object_type)
    if not module.does_type_exist(object_type) then
        error("Object of type `" .. object_type .. "` doesn't exist.")
    end

    local object = deep_copy(object_types[object_type])

    table.insert(create_queue, object)

    return object
end

--- Creates an object at the specified coordinates
---@param object_type string
---@param x number
---@param y number
---@return table
function module.create_object_at(object_type, x, y)
    local object = module.create_object(object_type)
    object.x = x
    object.y = y
    return object
end

--- Destroys an object
---@param object table the object
function module.destroy_object(object)
    for i, v in ipairs(objects) do
        if v == object then
            table.remove(objects, i)
            return true
        end
    end
    return false
end

--- Clears all objects that are not persistent
function module.clear()
    for i = #objects, 1, -1 do
        local object = objects[i]
        if not object.persistent then
            table.remove(objects, i)
        end
    end
end

--- Grabs the first object it sees of the specified type
---@param object_type string
function module.grab_object(object_type)
    for _, object in ipairs(objects) do
        if object.type == object_type then
            return object
        end
    end
    return nil
end

--- Run a function on every object of a specified type
---@param object_type string
---@param func function
function module.with(object_type, func)
    for _, object in ipairs(objects) do
        if object.type == object_type then
            func(object)
        end
    end
end

return module