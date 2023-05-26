local timers = {}

local function timer_start(self, time)
    time = time or self.total_time

    self.total_time = time
    self.time = time
    self.is_over = false
end

function timers.create_timer(self, name, func, time)
    time = time or 1

    self.timers[name] = {
        start = timer_start,
        time = 0,
        total_time = time,
        is_over = false,
        func = func
    }
end

return timers
