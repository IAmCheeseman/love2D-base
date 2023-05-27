Game = require "lib"

love.graphics.setDefaultFilter("nearest", "nearest")

Objects.create_type("pauser", {
    pause_mode = "never",

    on_quit_timeout = function(self)
        if love.keyboard.isDown("escape") then
            love.window.close()
        end
    end,

    on_create = function(self)
        self:create_timer("quit", self.on_quit_timeout, 0.5)
    end,

    on_key_press = function(self, key, _, is_repeat)
        if key == "escape" and not is_repeat then
            Objects.are_paused = not Objects.are_paused
            self.timers.quit:start()
        end
    end
})

Objects.create_type("player", {
    sprite = Sprite.new("doomguy.png", 2, 6),

    speed = 150,
    accel = 10,
    frict = 200,

    x = 50,
    y = 150,

    vx = 0,
    vy = 0,

    on_update = function(self, dt)
        local ix, iy = Vector.get_input_direction("w", "a", "s", "d")

        ix, iy = Vector.normalized(ix, iy)

        local accel_delta = self.accel
        if Vector.dot(self.vx, self.vy, ix, iy) < 0.5 then
            accel_delta = self.frict
        end

        self.vx = math.lerp(self.vx, ix * self.speed, accel_delta * dt)
        self.vy = math.lerp(self.vy, iy * self.speed, accel_delta * dt)

        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        Game.camera_x = self.x
        Game.camera_y = self.y
    end
})

function love.load()
    Tileset.new("Paths", "paths.png", 16)
    Tileset.new("Walls", "walls.png", 16)
    Tilemap.new("World")

    Objects.create_object("pauser")
end
