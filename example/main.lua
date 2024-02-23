local cam = require'cam'

-- set limits
cam.polar_lower = math.pi / 2
cam.polar_upper = 0.3
-- see the cam.lua for other limits and speed settings to configure

function lovr.update(dt)
  local t = lovr.timer.getTime()
  -- apply relative motion to camera
  -- note that user controls still work alongside with this scripted control
  cam.nudge(
    0.2 * dt,                    -- orbit clockwise around center at constant speed
    0.003 * math.sin(t),         -- bob up and down
    0.01 * math.sin(-t))         -- zoom in and out
end


function lovr.draw(pass)
  -- an example scene for testing camera controls
  pass:setColor(0x75507b)
  pass:box(0, 0.5, 0, 1)
  pass:setColor(0x623d53)
  pass:torus(0, 1.2, 0, 0.7, 0.3, math.pi/2, 1,0,0)
  pass:setColor(0xcba7a4)
  pass:torus(0, 1.28, 0, 0.72, 0.25, math.pi/2, 1,0,0)
  local tiles = 8
  for x = -tiles, tiles, 2 do
    for z = -tiles, tiles, 2 do
      local shade = math.exp(-0.05 * (x^2 + z^2))
      pass:setColor(shade * 0.5, shade * 0.8, shade * 0.7)
      pass:roundrect(x, -0.05, z,  1.8, 1.8, 0.1, math.pi / 2, 1,0,0, 0.2)
    end
  end
  pass:setColor(1,1,1)
  pass:text({
      0xf0f0f0, 'Hold ',
      0xf06000, 'left click',
      0xf0f0f0, ' to\norbit the camera'
    }, 0, 0.5, 0.52, 0.1)
  pass:text({
      0xf0f0f0, 'Scroll ',
      0xf06000, 'wheel',
      0xf0f0f0, ' to\nzoom in and out'
    }, 0.52, 0.5, 0, 0.1, math.pi/2, 0,1,0)
  pass:text({
      0xf0f0f0, 'Hold ',
      0xf06000, 'middle click',
      0xf0f0f0, ' to\npan the camera'
    }, -0.52, 0.5, 0, 0.1, -math.pi/2, 0,1,0)
  pass:text({
      0xf0f0f0, 'Hold down ',
      0xf06000, 'left+middle',
      0xf0f0f0, '\nto pan up and down'
    }, 0, 0.5, -0.52, 0.1, math.pi, 0,1,0)
  pass:setWireframe(true)
  pass:setColor(1, 1, 1, 0.1)
  pass:cube(0, 0.5, 0, 1.05,  0, 0,1,0, 'line')
  pass:torus(0, 1.28, 0, 0.75, 0.3, math.pi/2, 1,0,0, 14, 7)
end

cam.integrate()     -- a shortcut for quick and dirty activation of orbit camera
-- for a 'proper' integration into user's project, you would forward the callbacks yourself:

--[[
function lovr.draw(pass)
  cam.setCamera(pass)      -- first action, before drawing the scene
end

function lovr.resize(width, height)
  cam.resize(width, height)
end


function lovr.mousemoved(x, y, dx, dy)
  cam.mousemoved(x, y, dx, dy)
end


function lovr.wheelmoved(dx, dy)
  cam.wheelmoved(dx, dy)
end
--]]
