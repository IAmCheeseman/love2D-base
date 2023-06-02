local module = {}
local aabbs = {}

local function is_enclosing_point(self, x, y)
    return self.x + self.w > x and
            self.x < x and
            self.y + self.h > y and
            self.y < y
end

function module.new(x, y, w, h, type, identifier)
    local aabb = {
        x = x, 
        y = y,
        w = w,
        h = h,
        type = type,

        is_enclosing_point = is_enclosing_point,
    }

    aabbs[identifier] = aabb

    return aabb
end

function module.get_by_identifier(identifier)
    local aabb = aabbs[identifier]
    if aabb == nil then
        error("AABB '" .. identifier .. "' does not exist.")
    end
    return aabb
end

return module