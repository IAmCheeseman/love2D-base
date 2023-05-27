local module = {}

--- Starts a timer
---@param self table
---@param time number? Default is what was last set
local function timer_start(self, time)
    time = time or self.total_time

    self.total_time = time
    self.time = time
    self.is_over = false
end

--- Create a timer
---@param self table
---@param name string
---@param func function Called when the timer ends
---@param time number
function module.create_timer(self, name, func, time)
    time = time or 1

    self.timers[name] = {
        start = timer_start,
        time = 0,
        total_time = time,
        is_over = false,
        func = func
    }
end

--- Processes an object's timers
---@param object table
---@param dt number
function module.process(object, dt)
    for _, timer in pairs(object.timers) do
        timer.time = timer.time - dt

        if timer.time < 0 and not timer.is_over then
            if timer.func then
                timer.func(object)
            end
            timer.is_over = true
        end
    end
end

return module
