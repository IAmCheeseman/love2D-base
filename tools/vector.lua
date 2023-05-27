local module = {}

function module.length(x, y)
    return math.sqrt(x^2 + y^2)
end

function module.normalized(x, y)
    local l = module.length(x, y)
    if l == 0 then
        return 0, 0
    end
    return x / l, y / l
end

function module.dot(x, y, xx, yy)
    return (x^2 + y^2) + (xx^2 + yy^2)
end

function module.direction_to(x, y, xx, yy)
    return module.normalized(x - xx, y - yy)
end

function module.distance_to(x, y, xx, yy)
    return module.length(x - xx, y - yy)
end

function module.angle(x, y)
    return math.atan2(y, x)
end

function module.angle_to(x, y, xx, yy)
    return module.angle(x - xx, y - yy)
end

function module.get_input_direction(up, left, down, right)
    local ix, iy = 0, 0

    if love.keyboard.isDown(up) then iy = iy - 1 end
    if love.keyboard.isDown(left) then ix = ix - 1 end
    if love.keyboard.isDown(down) then iy = iy + 1 end
    if love.keyboard.isDown(right) then ix = ix + 1 end

    return ix, iy
end

function module.rotated(x, y, r)
    local new_rot = module.angle(x, y) + r
    local l = module.length(x, y)

    local nx = math.cos(new_rot) * l
    local ny = math.sin(new_rot) * l

    return nx, ny
end

return module