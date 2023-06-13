local module = {}

--- Starts a timer
---@param self table
---@param time number? Default is what was last set
local function timer_start(self, time)
    self.total_time = time or self.total_time
    self.time = self.total_time
    self.is_over = false
end

local function timer_stop(self)
    self.total_time = -1
    self.is_over = true
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
        stop = timer_stop,
        time = 0,
        total_time = time,
        is_over = true,
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
            timer.is_over = true
            if timer.func then
                timer.func(object)
            end
        end
    end
end

return module
