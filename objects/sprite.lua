
local module = {}

local function draw_sprite(self, x, y)
    if self.frame > self.frame_count or self.frame <= 0 then
        error("in object '" .. self.type .. "', frame index " .. self.frame .. " is invalid. (" .. self.frame_count .. " frames)")
    end

    local w, h = self.texture:getDimensions()

    local frame = self.frame - 1
    local frame_size = w / self.frame_count

    local quad = love.graphics.newQuad(
        frame * frame_size, 0,
        frame_size, h,
        w, h)

    love.graphics.draw(
        self.texture,
        quad,
        x, y,
        self.rotation,
        self.scale_x, self.scale_y,
        self.offset_x + frame_size / 2, self.offset_y + h / 2)
end

--- Makes a new sprite
---@param path string
---@param frame_count integer? Default is 1
---@param fps number? Default is 10
---@return table
function module.new(path, frame_count, fps)
    frame_count = frame_count or 1
    fps = fps or 10

    return {
        path = path,
        texture = love.graphics.newImage(path),
        rotation = 0,
        scale_x = 1,
        scale_y = 1,
        offset_x = 0,
        offset_y = 0,
        frame_count = frame_count,
        frame = 1,
        animation_start = 1,
        animation_end = frame_count,
        is_playing = false,
        fps = fps,
        _time = 0,

        draw = draw_sprite,
    }
end

function module.process(sprite, dt)
    sprite._time = sprite._time + dt

    if sprite._time > 1 / sprite.fps then
        sprite.frame = math.wrap(sprite.frame + 1, sprite.animation_start, sprite.animation_end)
        sprite._time = 0
    end
end

return module