local module = {}

--- Finds the length of a Vector
---@param x number
---@param y number
function module.length(x, y)
    return math.sqrt(x^2 + y^2)
end

--- Reduces the length of a vector to 1
---@param x number
---@param y number
function module.normalized(x, y)
    local l = module.length(x, y)
    if l == 0 then
        return 0, 0
    end
    return x / l, y / l
end

--- Dot product
---@param x number
---@param y number
---@param xx number
---@param yy number
function module.dot(x, y, xx, yy)
    return (x^2 + y^2) + (xx^2 + yy^2)
end

--- Finds the direction between two points
---@param x number
---@param y number
---@param xx number
---@param yy number
function module.direction_between(x, y, xx, yy)
    return module.normalized(xx - x, yy - y)
end

--- Finds the distance between two points
---@param x number
---@param y number
---@param xx number
---@param yy number
function module.distance_between(x, y, xx, yy)
    return module.length(x - xx, y - yy)
end

--- Find the angle of a vector
---@param x number
---@param y number
function module.angle(x, y)
    return math.atan2(y, x)
end

--- Finds the angle between two points
---@param x number
---@param y number
---@param xx number
---@param yy number
function module.angle_between(x, y, xx, yy)
    return module.angle(x - xx, y - yy)
end

--- Get a vector pointing in the direction the specified keys would make
---@param up string
---@param left string
---@param down string
---@param right string
function module.get_input_direction(up, left, down, right)
    local input_x, input_y = 0, 0

    if love.keyboard.isDown(up) then input_y = input_y - 1 end
    if love.keyboard.isDown(left) then input_x = input_x - 1 end
    if love.keyboard.isDown(down) then input_y = input_y + 1 end
    if love.keyboard.isDown(right) then input_x = input_x + 1 end

    return input_x, input_y
end

--- A vector rotated by r
---@param x number
---@param y number
---@param r number
function module.rotated(x, y, r)
    local new_rot = module.angle(x, y) + r
    local l = module.length(x, y)

    local nx = math.cos(new_rot) * l
    local ny = math.sin(new_rot) * l

    return nx, ny
end

return module