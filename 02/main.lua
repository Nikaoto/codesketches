-- Maximum number of 'layers' in the set. Increase to get more detail, but also takes longer to draw
maxIterations = 76

-- Colors
isFullscreen = false
black = {0, 0, 0}
white = {1, 1, 1, 1}
startColor = black
endColor = white
currentColor = startColor

-- Contains every point that's drawn on the screen
allPoints = {}

function love.load()
	love.window.setFullscreen(isFullscreen)
	width = love.graphics.getWidth() or 1920
	height = love.graphics.getHeight() or 1080

	for row = 1, height do 
		for col = 1, width do
			c_re = (col - width / 2) * 4 / width
			c_im = (row - height / 2) * 4 / width
			x = 0; y = 0
			iterations = 0
			while x*x + y*y < 4 and iterations < maxIterations do
				x_new = x*x - y*y + c_re
				y = 2 * x * y + c_im
				x = x_new
				iterations = iterations + 1
			end
			
			if iterations < maxIterations then 
				local ratio = iterations/maxIterations 
				currentColor = { lerp(startColor[1], endColor[1], ratio), 
								 lerp(startColor[2], endColor[2], ratio), 
								 lerp(startColor[3], endColor[3], ratio)}
				table.insert(allPoints, getPoint(col, row, currentColor)) 
			else
				table.insert(allPoints, getPoint(col, row, startColor)) 
			end
		end
	end
end

function lerp(a, b, c) 
	return a + (b - a) * c
end

function getPoint(x, y, color)
	return {x, y, color[1], color[2], color[3], color[4] or 1}
end

function love.draw()
	love.graphics.points(allPoints)
end

function love.keypressed(key)
   if key == "q" or key == "escape" then
	   love.event.quit()
   end
end
