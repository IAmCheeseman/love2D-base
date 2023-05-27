--- Linearly interpolates a to b
---@param a number
---@param b number
---@param t number
function math.lerp(a, b, t) return (b - a) * t + a end
--- Wraps a number between min and max
---@param a number
---@param min number
---@param max number
function math.wrap(a, min, max)
    if a > max then
        return math.wrap(a - max, min, max)
    elseif a < min then
        return math.wrap(a + max, min, max)
    end
    return a
end
--- Keeps a number between min and max
---@param a number
---@param min number
---@param max number
function math.clamp(a, min, max)
    if a > max then
        return max
    elseif a < min then
        return min
    end
    return a
end