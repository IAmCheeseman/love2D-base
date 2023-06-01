
local module = {}

--- Draws a sprite
---@param self table
---@param x number x axis
---@param y number y axis
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

    local center_x = (frame_size / 2) * self.scale_x
    local center_y = (h / 2) * self.scale_y

    love.graphics.draw(
        self.texture,
        quad,
        x - center_x, y - center_y,
        self.rotation,
        self.scale_x, self.scale_y,
        self.offset_x, self.offset_y)
end

local function apply_animation(self, animation)
    self.animation_start = animation.anim_start
    self.animation_end = animation.anim_end
    self.fps = animation.fps
end

--- Processes a sprite
---@param sprite table
---@param dt number
function module.process(sprite, dt)
    sprite._time = sprite._time + dt

    if sprite._time > 1 / sprite.fps then
        sprite.frame = sprite.frame + 1
        sprite._time = 0
    end

    if sprite.frame > sprite.animation_end or sprite.frame < sprite.animation_start then
        sprite.frame = sprite.animation_start
    end
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
        apply_animation = apply_animation,
    }
end

function module.new_animation(anim_start, anim_end, fps)
    return {
        anim_start = anim_start,
        anim_end = anim_end,
        fps = fps
    }
end

return module