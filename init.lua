local path = (...):gsub("%init$", "")
Objects = require(path .. ".objects.object")
Room = require(path .. ".objects.room")
Sprite = require(path .. ".objects.sprite")
Vector = require(path .. ".tools.vector")
AABB = require(path .. ".tools.aabb")
require(path .. ".tools.mathfunctions")

local settings = require(path .. ".settings")

local module = {
    camera_x = 0,
    camera_y = 0,
}

function love.directorydropped(path)
    Objects.call_on_all("on_directory_drop", path)
end

function love.displayrotated(index, orientation)
    Objects.call_on_all("on_display_rotate", index, orientation)
end

function love.filedropped(file)
    Objects.call_on_all("on_file_drop", file)
end

function love.focus(is_focused)
    Objects.call_on_all("on_window_focus", is_focused)
end

function love.mousefocus(is_focused)
    Objects.call_on_all("on_window_mouse_focus", is_focused)
end

function love.resize(w, h)
    Objects.call_on_all("on_window_resize", w, h)
end

function love.visible(is_visible)
    Objects.call_on_all("on_window_visible", is_visible)
end


function love.keypressed(key, scancode, is_repeat)
    Objects.call_on_all("on_key_press", key, scancode, is_repeat)
end

function love.keyreleased(key, scancode)
    Objects.call_on_all("on_key_release", key, scancode)
end

function love.textedited(text, start, length)
    Objects.call_on_all("on_text_edit", text, start, length)
end

function love.textinput(text)
    Objects.call_on_all("on_text_input", text)
end


function love.mousemoved(x, y, dx, dy, is_touch)
    local mx, my = love.mouse.getPosition()
    Objects.call_on_all("on_mouse_move", mx, my, dx, dy, is_touch)
end

function love.mousepressed(x, y, button, is_touch, presses)
    local mx, my = love.mouse.getPosition()
    Objects.call_on_all("on_mouse_press", mx, my, button, is_touch, presses)
end

function love.mousereleased(x, y, button, is_touch, presses)
    local mx, my = love.mouse.getPosition()
    Objects.call_on_all("on_mouse_release", mx, my, button, is_touch, presses)
end

function love.wheelmoved(x, y)
    Objects.call_on_all("on_mouse_wheel_move", x, y)
end


function love.update(dt)
    Objects.process_objects(dt)
end

local sw, sh = settings.screen_width, settings.screen_height
local canvas = love.graphics.newCanvas(sw + 1, sh + 1)
local gui = love.graphics.newCanvas(sw, sh)
canvas:setFilter("nearest", "nearest")
gui:setFilter("nearest", "nearest")

local function get_draw_transform()
    local ww, wh = love.graphics.getDimensions()

    local w, h = ww + settings.screen_width, wh + settings.screen_height

    while w > ww do
        w = w - settings.screen_width
    end
    while h > wh do
        h = h - settings.screen_height
    end

    local scale = w / settings.screen_width < h / settings.screen_height 
        and w / settings.screen_width 
        or  h / settings.screen_height
    
    w = settings.screen_width * scale
    h = settings.screen_height * scale

    local x, y = (ww - w) / 2, (wh - h) / 2

    return x, y, scale
end

function love.draw()
    love.graphics.setCanvas(canvas)
    local background_color = Room.level.backgroundColor
    love.graphics.clear(background_color[1], background_color[2], background_color[3])

    love.graphics.translate(
        math.floor(-module.camera_x + sw / 2), 
        math.floor(-module.camera_y + sh / 2))

    Room.draw()
    Objects.draw_objects()
    
    love.graphics.setCanvas(gui)

    love.graphics.clear(1, 1, 1, 0)

    love.graphics.translate(
        math.floor(module.camera_x - sw / 2), 
        math.floor(module.camera_y - sh / 2))

    Objects.draw_gui()

    love.graphics.setCanvas()
    
    local x, y, scale = get_draw_transform()
    local quad = love.graphics.newQuad(
        math.frac(module.camera_x), math.frac(module.camera_y),
        settings.screen_width, settings.screen_height,
        canvas:getWidth(), canvas:getHeight())
    love.graphics.draw(canvas, quad, x, y, 0, scale, scale)
    love.graphics.draw(gui, x, y, 0, scale, scale)
end

local loveMouseGetPosition = love.mouse.getPosition

function love.mouse.getPosition()
    local x, y, scale = get_draw_transform()
    local mx, my = loveMouseGetPosition()
    mx = mx - x
    my = my - y

    mx = module.camera_x + mx / scale
    my = module.camera_y + my / scale
    return mx - settings.screen_width / 2, my - settings.screen_height / 2
end

return module