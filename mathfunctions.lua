function math.lerp(a, b, t) return (b - a) * t + a end
function math.wrap(a, min, max)
    if a > max then
        return math.wrap(a - max, min, max)
    elseif a < min then
        return math.wrap(a + max, min, max)
    end
    return a
end