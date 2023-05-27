local module = {
    current = nil,
}

function module.change_to(room)
    module.current = room
    Objects.clear()
    room:initialize()
end

local function initialize(self)
    self.tilemap:initialize()
end

function module.new(tilemap)
    return {
        tilemap = tilemap,
        initialize = initialize,
    }
end

return module