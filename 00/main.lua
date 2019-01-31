
local lg = love.graphics

local sin15 = math.sin(math.pi / 6)
local sin45 = math.sin(math.pi / 2)
local sin30 = math.sin(math.pi / 3)

local rhomb_color = {66/255, 161/255, 86/255}
local pillar_left_color = {0/255, 105/255, 146/255}
local pillar_right_color = {172/255, 200/255, 72/255}

function draw_unit(x, y, height, width)
   local radius_x = sin30 * width / 2
   local radius_y = sin15 * width / 2
   
   -- Draw rhomb
   lg.setColor(rhomb_color)
   lg.polygon("fill",
              x - radius_x, y,
              x, y - radius_y,
              x + radius_x, y,
              x, y + radius_y)

   -- Draw right pillar
   lg.setColor(pillar_right_color)
   lg.polygon("fill",
              x + radius_x, y,
              x + radius_x, y + height,
              x, y + radius_y + height,
              x, y + radius_y)

   -- Draw left pillar
   lg.setColor(pillar_left_color)
   lg.polygon("fill",
              x - radius_x, y,
              x - radius_x, y + height,
              x, y + radius_y + height,
              x, y + radius_y)
end

function sq(x) return x * x end

function interpolate(a, b, amount)
   return a + (b - a) * (sq(amount) * (3 - 2 * amount))
end

function time()
   return math.floor(love.timer.getTime() * 1000)
end

function get_interp_amount(time, duration)
   return (time % duration) / duration
end

function get_stretch_direction(time, duration)
   return (math.floor(time / duration) % 2 == 0)
end

local rhomb_center_x = 750
local rhomb_center_y = 160
local pillar_height = 100
local pillar_min_height = 25
local pillar_max_height = 140
local pillar_width = 40
local stretch_direction = 1
local stretch_duration = 900
local next_tick = time() + stretch_duration
local global_time = time()
local diag_unit_count = 12
local horiz_unit_count = math.floor(diag_unit_count/2)
local vert_unit_count = math.floor(diag_unit_count/2)
local units = {}
local radius_x = sin30 * pillar_width / 2
local radius_y = sin15 * pillar_width / 2


local center_unit = {
   x_offset = 0,
   y_offset = 0,
   time_offset = 0
}


function love.load()
   love.window.setMode(1024, 720)
   table.insert(units, center_unit)
   local toff = 10

   for i = horiz_unit_count-1, -horiz_unit_count, -1 do
      for j = -vert_unit_count, vert_unit_count-1, 1 do
         local new_unit = {
            x_offset = radius_x * i - (horiz_unit_count - j) * radius_x * 2,
            y_offset = radius_y * -i + (vert_unit_count - i) * radius_y,
            time_offset = toff * j * i
         }
         table.insert(units, new_unit)
      end
   end
end

function love.update(dt)
   global_time = time()
end

function love.draw()
   lg.clear(1, 1, 1, 1)
   for _, v in pairs(units) do
      local t = time() + v.time_offset
      
      local interp_amount = get_interp_amount(t, stretch_duration)
      local stretch_direction = get_stretch_direction(t, stretch_duration)
      if stretch_direction then
         pillar_height = interpolate(pillar_min_height, pillar_max_height, interp_amount)
      else
         pillar_height = interpolate(pillar_max_height, pillar_min_height, interp_amount)
      end
      
      draw_unit(rhomb_center_x + v.x_offset,
                rhomb_center_y + v.y_offset + (pillar_max_height - pillar_height),
                pillar_height * 2,
                pillar_width)
   end
end

function love.keypressed(k)
   if k == "escape" then
      love.event.quit()
   end
end
