Objects = require "objects.object"
Sprite = require "objects.sprite"
Tileset = require "tools.tileset"
Tilemap = require "tools.tilemap"
Vector = require "tools.vector"
require "tools.mathfunctions"

local settings = require "settings"

local module = {
    camera_x = 0,
    camera_y = 0,
}

local loveMouseGetPosition = love.mouse.getPosition

function love.mouse.getPosition()
    local mx, my = loveMouseGetPosition()
    mx = module.camera_x + mx / settings.scale
    my = module.camera_y + my / settings.scale
    return mx - settings.screen_width / 2, my - settings.screen_height / 2
end

function love.directorydropped(path)
    Objects.call_on_all("on_directory_drop", { path })
end

function love.displayrotated(index, orientation)
    Objects.call_on_all("on_display_rotate", { index, orientation })
end

function love.filedropped(file)
    Objects.call_on_all("on_file_drop", { file })
end

function love.focus(is_focused)
    Objects.call_on_all("on_window_focus", { is_focused })
end

function love.mousefocus(is_focused)
    Objects.call_on_all("on_window_mouse_focus", { is_focused })
end

function love.resize(w, h)
    Objects.call_on_all("on_window_resize", { w, h })
end

function love.visible(is_visible)
    Objects.call_on_all("on_window_visible", { is_visible })
end


function love.keypressed(key, scancode, is_repeat)
    Objects.call_on_all("on_key_press", { key, scancode, is_repeat })
end

function love.keyreleased(key, scancode)
    Objects.call_on_all("on_key_release", { key, scancode })
end

function love.textedited(text, start, length)
    Objects.call_on_all("on_text_edit", { text, start, length })
end

function love.textinput(text)
    Objects.call_on_all("on_text_input", { text })
end


function love.mousemoved(x, y, dx, dy, is_touch)
    Objects.call_on_all("on_mouse_move", { x, y, dx, dy, is_touch })
end

function love.mousepressed(x, y, button, is_touch, presses)
    Objects.call_on_all("on_mouse_press", { x, y, button, is_touch, presses })
end

function love.mousereleased(x, y, button, is_touch, presses)
    Objects.call_on_all("on_mouse_release", { x, y, button, is_touch, presses })
end

function love.wheelmoved(x, y)
    Objects.call_on_all("on_mouse_wheel_move", { x, y })
end


function love.update(dt)
    Objects.process_objects(dt)
end

local sw, sh = settings.screen_width, settings.screen_height
local canvas = love.graphics.newCanvas(sw, sh)
canvas:setFilter("nearest", "nearest")

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(117 / 255, 167 / 255, 67 / 255)

    love.graphics.translate(
        -module.camera_x + sw / 2, 
        -module.camera_y + sh / 2)

    Tilemap.draw_all()
    Objects.draw_objects()
    
    love.graphics.setCanvas()

    love.graphics.translate(
        module.camera_x - sw / 2, 
        module.camera_y - sh / 2)
    love.graphics.draw(canvas, 0, 0, 0, settings.scale, settings.scale)
end

return module