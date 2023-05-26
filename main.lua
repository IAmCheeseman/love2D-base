Objects = require "objects.object"
Sprite = require "objects.sprite"
Vector = require "vector"
require "mathfunctions"
require "binding"

love.graphics.setDefaultFilter("nearest", "nearest")
Sprite.default_sprite_x = 3
Sprite.default_sprite_y = 3

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

    on_key_pressed = function(self, key, _, is_repeat)
        if key == "escape" and not is_repeat then
            Objects.are_paused = not Objects.are_paused
            self.timers.quit:start()
        end
    end
})

Objects.create_type("red_ball", {
    destroy_timer = function(self)
        Objects.destroy_object(self)
    end,
    on_create = function(self)
        self:create_timer("destroy", self.destroy_timer, 3)
        self.timers.destroy:start()
    end,
    on_draw = function(self)
        local percentage = self.timers.destroy.time / self.timers.destroy.total_time
        love.graphics.setColor(1, 0, 0, percentage)
        love.graphics.circle("fill", self.x, self.y, 32 * percentage)
    end
})

Objects.create_type("player", {
    sprite = Sprite.new("doomguy.png", 2, 6),

    speed = 350,
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
    end
})

Objects.create_type_from("balling_player", "player", {
    on_create = function(self)
        self:create_timer("ball_cooldown", nil, 0.25)
    end,

    on_update = function(self, dt)
        self:call_from_base("on_update", { self, dt })

        if love.keyboard.isDown("space") and self.timers.ball_cooldown.is_over then
            Objects.create_object_at("red_ball", self.x, self.y)
            self.timers.ball_cooldown:start()
            self.can_place_ball = false
        end
    end
})

function love.load()
    Objects.create_object("balling_player")
    Objects.create_object("pauser")
end
