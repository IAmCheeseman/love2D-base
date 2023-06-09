local path = (...):gsub("%object$", "")
local timers = require(path .. "timer")

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
    return (module.are_paused and object.pause_mode ~= "never") or object.pause_mode == "always"
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
    -- Add each object first so objects can reference other objects made on the same frame
    for _, object in ipairs(create_queue) do
        table.insert(objects, object)
        table.insert(object_types[object.type].instances, object)
    end
    for i = #create_queue, 1, -1 do
        local object = create_queue[i]
        if object.on_create then
            object:on_create()
        end
        table.remove(create_queue, i)
    end

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
        love.graphics.setColor(1, 1, 1, 1)
        object:on_draw()
    end
end

function module.draw_gui()
    local sorted_objects = table.sort(objects, function(a, b) return a.depth < b.depth end)
    for _, object in ipairs(objects) do
        love.graphics.setColor(1, 1, 1)
        if object.on_gui ~= nil then
            object:on_gui()
        end
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

local function create_type(type, name) 
    object_types[name] = {
        object = type,
        instances = {}
    }
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
    set_property_default(object, "depth", 0)
    set_property_default(object, "pause_mode", "normally")

    object.type = name
    object.create_timer = timers.create_timer
    object.timers = {}

    if object.on_draw == nil then
        object.on_draw = module.default_draw
    end

    create_type(object, name)
end

--- Calls a function from the base type
---@param self table
---@param name string
local function call_from_base(self, name, ...)
    object_types[self.inherits_from].object[name](self, ...)
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

    local derived = deep_copy(object_types[inherited].object)

    for k, v in pairs(object) do
        derived[k] = v
    end

    derived.inherits_from = inherited
    derived.call_from_base = call_from_base

    create_type(derived, name)
end

function module.does_type_exist(type_name)
    return object_types[type_name] ~= nil
end

--- Creates an object
---@param object_type string
---@return table
function module.instance(object_type)
    if not module.does_type_exist(object_type) then
        error("Object of type `" .. object_type .. "` doesn't exist.")
    end

    local object = deep_copy(object_types[object_type].object)

    table.insert(create_queue, object)

    return object
end

--- Creates an object at the specified coordinates
---@param object_type string
---@param x number
---@param y number
---@return table
function module.instance_at(object_type, x, y)
    local object = module.instance(object_type)
    object.x = x
    object.y = y
    return object
end

--- Destroys an object
---@param object table the object
function module.destroy(object)
    local destroyed = false
    for i, v in ipairs(objects) do
        if v == object then
            table.remove(objects, i)
            destroyed = true
            break
        end
    end
    for i, v in ipairs(object_types[object.type].instances) do
        if v == object then
            table.remove(object_types[object.type].instances, i)
            destroyed = true
            break
        end
    end
    return destroyed
end

--- Clears all objects that are not persistent
function module.clear()
    for i = #objects, 1, -1 do
        local object = objects[i]
        if not object.persistent then
            table.remove(objects, i)
        end
    end

    for _, type in pairs(object_types) do
        for i = #type.instances, 1, -1 do
            local object = type.instances[i]
            if not object.persistent then
                table.remove(type.instances, i)
            end
        end
    end
end

--- Grabs the first object it sees of the specified type
---@param object_type string
function module.grab(object_type)
    if object_types[object_type] == nil then
        error("Object of type `" .. object_type .. "` doesn't exist.")
    end
    local instances = object_types[object_type].instances
    if #instances == 0 then
        return nil
    end
    return instances[1]
end

local function is_type_correct(object, type)
    if object.type == type or object.inherits_from == type then
        return true
    end

    if object.inherits_from ~= nil then
        return is_type_correct(object_types[object.inherits_from].object, type)
    end
end

function module.count_type(object_type)
    if object_types[object_type] == nil then
        error("Object of type `" .. object_type .. "` doesn't exist.")
    end
    return #object_types[object_type].instances
end

--- Run a function on every object of a specified type
---@param object_type string
---@param func function
function module.with(object_type, func)
    for _, object in ipairs(object_types[object_type].instances) do
        if is_type_correct(object, object_type) then
            func(object)
        end
    end

    if object_types[object_type].object.inherits_from ~= nil then
        module.with(object_types[object_type].object.inherits_from, func)
    end
end

return module