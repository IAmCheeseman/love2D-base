local function length(x, y)
    return math.sqrt(x^2 + y^2)
end

local function normalized(x, y)
    local l = length(x, y)
    if l == 0 then
        return 0, 0
    end
    return x / l, y / l
end

local function dot(x, y, xx, yy)
    return (x^2 + y^2) + (xx^2 + yy^2)
end

local function direction_to(x, y, xx, yy)
    return normalized(x - xx, y - yy)
end

local function distance_to(x, y, xx, yy)
    return length(x - xx, y - yy)
end

local function angle(x, y)
    return math.atan2(y, x)
end

local function angle_to(x, y, xx, yy)
    return angle(x - xx, y - yy)
end

local function get_input_direction(up, left, down, right)
    local ix, iy = 0, 0

    if love.keyboard.isDown(up) then iy = iy - 1 end
    if love.keyboard.isDown(left) then ix = ix - 1 end
    if love.keyboard.isDown(down) then iy = iy + 1 end
    if love.keyboard.isDown(right) then ix = ix + 1 end

    return ix, iy
end

local function rotated(x, y, r)
    local new_rot = angle(x, y) + r
    local l = length(x, y)

    local nx = math.cos(new_rot) * l
    local ny = math.sin(new_rot) * l

    return nx, ny
end

return {
    length = length,
    normalized = normalized,
    dot = dot,
    direction_to = direction_to,
    distance_to = distance_to,
    angle = angle,
    angle_to = angle_to,
    rotated = rotated,
    get_input_direction = get_input_direction,
}