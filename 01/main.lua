-- codesketch 01
-- Title: loading
-- Author: Nika Otiashvili

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600
recording = false

local lg = love.graphics

local canvas = lg.newCanvas(WINDOW_WIDTH, WINDOW_HEIGHT)

function sq(x) return x * x end

function lerp(a, b, amount)
   return a + ((b - a) * amount)
end

local randrange = function(from, to)
   return lerp(from, to, math.random())
end

local m = 3
local n = 2

function interpolate_x(x, r, amount)
   return lerp(
      lerp(x - r, x + r, math.cos(math.pi * (1 - sq(1 - amount) * m))),
      lerp(x - r, x + r, math.cos(math.pi * sq(amount) * n)),
      amount)
   -- return lerp(x - r, x + r, 1 - (1 - math.sin(math.pi * sq(1 - amount) * 2)))
end

function interpolate_y(y, r, amount)
   return lerp(
      lerp(y - r, y + r, math.sin(math.pi * (1 - sq(1 - amount) * m))),
      lerp(y - r, y + r, math.sin(math.pi * sq(amount) * n)),
      amount)
   -- return lerp(y - r, y + r, 1 - (1 - math.cos(math.pi * sq(1 - amount) * 2)))
end

function time(dt) return (love.timer.getTime() - dt) * 1000 end

local rot_radius = 70
local x_start = 400
local y_start = 400
local duration = 2000
local fps = 60
local next_tick = time(0) + duration

local new_circle = function(time_offset)
   return {
      sx = x_start,
      sy = y_start,
      center_x = WINDOW_WIDTH/2,
      center_y = WINDOW_HEIGHT/2,
      x = x_start,
      y = y_start,
      path_radius = 200,
      radius = 20,
      color = {randrange(50, 80)/255, randrange(130, 180)/255, randrange(20, 50)/255},
      time_offset = time_offset
   }
end

local circles = {}

function love.load()
   math.randomseed(time(0))
   love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

   for i=1, 10 do
      table.insert(circles, new_circle(i * 67))
   end

   if recording then
      local dt = 0.0167
      for frame=0, math.floor(duration/1000 * fps) do
         lg.setCanvas(canvas)
         lg.clear(0.2, 0.2, 0.2, 1)
         local t = dt * frame * 2000
         for i, c in pairs(circles) do
            local a = ((t + c.time_offset) % duration) / duration
            local angle = lerp(
               lerp(0, math.pi * 2, 1-sq(1-a)),
               lerp(0, math.pi * 2, sq(a)),
               a)
            -- c.x = interpolate_x(c.sx, rot_radius, ((t + c.time_offset) % duration) / duration)
            -- c.y = interpolate_y(c.sy, rot_radius, ((t + c.time_offset) % duration) / duration)
            c.x = c.center_x + math.sin(angle) * c.path_radius
            c.y = c.center_y + math.cos(angle) * c.path_radius
         end
         
         for i, c in pairs(circles) do
            lg.setColor(c.color)
            lg.circle("fill", c.x, c.y, c.radius)
            lg.setColor(1, 1, 1, 1)
            lg.circle("line", c.x, c.y, c.radius)
         end
         lg.setCanvas()
         canvas:newImageData():encode("png", string.format("01f%03i.png", frame))
      end
   end
end

function love.update(dt)
   local t = time(dt)
   for i, c in pairs(circles) do
      local a = ((t + c.time_offset) % duration) / duration
      local angle = lerp(
         lerp(0, math.pi * 2, 1-sq(1-a)),
         lerp(0, math.pi * 2, sq(a)),
         a)
      -- c.x = interpolate_x(c.sx, rot_radius, ((t + c.time_offset) % duration) / duration)
      -- c.y = interpolate_y(c.sy, rot_radius, ((t + c.time_offset) % duration) / duration)
      c.x = c.center_x + math.sin(angle) * c.path_radius
      c.y = c.center_y + math.cos(angle) * c.path_radius
   end
end

function love.draw()
   --lg.setColor(1, 0, 0, 1)
   --lg.circle("fill", 350, 350, 200)
   for i, c in pairs(circles) do
      lg.setColor(c.color)
      lg.circle("fill", c.x, c.y, c.radius)
      lg.setColor(1, 1, 1, 1)
      lg.circle("line", c.x, c.y, c.radius)
   end
end

function love.keypressed(k)
   if k == "escape" then
      love.event.quit()
   end
end
