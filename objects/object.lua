
local timers = require "objects.timer"

local object = {
    are_paused = false,
}

local objects = {}
local object_types = {}

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

local function is_object_paused(o)
    return object.are_paused and o.pause_mode ~= "never"
end

function object.process_object(o, dt)
    if o.sprite ~= nil then
        local sprite = o.sprite
        sprite._time = sprite._time + dt

        if sprite._time > 1 / sprite.fps then
            sprite.frame = math.wrap(sprite.frame + 1, sprite.animation_start, sprite.animation_end)
            sprite._time = 0
        end
    end

    for _, timer in pairs(o.timers) do
        timer.time = timer.time - dt

        if timer.time < 0 and not timer.is_over then
            timer.func(o)
            timer.is_over = true
        end
    end

    if o.on_update then
        o:on_update(dt)
    end
end

function object.process_objects(dt)
    for _, v in ipairs(objects) do
        if not is_object_paused(v) then
            object.process_object(v, dt)
        end
    end
end

function object.default_draw(self)
    if self.sprite == nil then
        return
    end

    self.sprite:draw(self.x, self.y)
end

function object.draw_objects()
    for _, v in ipairs(objects) do
        love.graphics.setColor(1, 1, 1)
        v:on_draw()
    end
end

function object.call_on_all(function_name, values)
    for _, v in ipairs(objects) do
        if v[function_name] ~= nil and not is_object_paused(v) then
            v[function_name](v, unpack(values))
        end
    end
end

local function set_property_default(o, property, value)
    if o[property] ~= nil then
        return
    end
    o[property] = value
end

function object.create_type(name, o)
    if object_types[name] ~= nil then
        error("Object with the name of '" .. name .. "' already exists.")
    end

    set_property_default(o, "x", 0)
    set_property_default(o, "y", 0)
    set_property_default(o, "pause_mode", "normally")

    o.type = name
    o.create_timer = timers.create_timer
    o.timers = {}

    if o.on_draw == nil then
        o.on_draw = object.default_draw
    end

    object_types[name] = o
end

local function call_from_base(self, name, args)
    object_types[self.inherits_from][name](unpack(args))
end

function object.create_type_from(name, inherited, o)
    if object_types[name] ~= nil then
        error("Object with the name of '" .. name .. "' already exists.")
    end
    if object_types[inherited] == nil then
        error("'" .. name .. "' cannot inherit '" .. inherited .. "' because it does not exist.")
    end

    local derived = deep_copy(object_types[inherited])

    for k, v in pairs(o) do
        derived[k] = v
    end

    derived.inherits_from = inherited
    derived.call_from_base = call_from_base

    object_types[name] = derived
end

function object.create_object(object_type)
    if object_types[object_type] == nil then
        error("Object of type `" .. object_type .. "` doesn't exist.")
    end

    local o = deep_copy(object_types[object_type])
    table.insert(objects, o)

    if o.on_create then
        o:on_create()
    end

    return o
end

function object.create_object_at(object_type, x, y)
    local o = object.create_object(object_type)
    o.x = x
    o.y = y
    return o
end

function object.destroy_object(o)
    for i, v in ipairs(objects) do
        if v == o then
            table.remove(objects, i)
            return true
        end
    end
    return false
end

function object.grab_object(object_type)
    for _, v in ipairs(objects) do
        if v.type == object_type then
            return v
        end
    end
    return nil
end

function object.with(object_type, func)
    for _, v in ipairs(objects) do
        if v.type == object_type then
            func(v)
        end
    end
end

return object