function love.keypressed(key, scancode, is_repeat)
    Objects.call_on_all("on_key_pressed", { key, scancode, is_repeat })
end

function love.keyreleased(key, scancode)
    Objects.call_on_all("on_key_released", { key, scancode })
end

function love.mousemoved(x, y, dx, dy, is_touch)
    Objects.call_on_all("on_mouse_moved", { x, y, dx, dy, is_touch })
end

function love.mousepressed(x, y, button, is_touch, presses)
    Objects.call_on_all("on_mouse_pressed", { x, y, button, is_touch, presses })
end

function love.mousereleased(x, y, button, is_touch, presses)
    Objects.call_on_all("on_mouse_released", { x, y, button, is_touch, presses })
end

function love.wheelmoved(x, y)
    Objects.call_on_all("on_wheel_moved", { x, y })
end

function love.update(dt)
    Objects.process_objects(dt)
end

function love.draw()
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)

    Objects.draw_objects()
end