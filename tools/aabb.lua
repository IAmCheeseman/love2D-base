local module = {}

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

    return aabb
end

return module