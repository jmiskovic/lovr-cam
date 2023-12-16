local cam = require'cam'

cam.polar_lower = math.pi / 2
cam.polar_upper = 0.3

function lovr.update(dt)
  cam.nudge(
    dt * .2,
    0.002  * math.sin(lovr.timer.getTime() * 2),
    0.03 * math.sin(lovr.timer.getTime()))
end

function lovr.draw(pass)
  pass:setColor(0x75507b)
  pass:box(0, 0.5, 0, 1)
  pass:setColor(0xFFC332)
  pass:monkey(0, 1.5, 0, 1, -math.pi * 0.1, 1, 0, 0)
  local tiles = 8
  for x = -tiles, tiles, 2 do
    for z = -tiles, tiles, 2 do
      local shade = math.exp(-0.05 * (x^2 + z^2))
      pass:setColor(shade * 0.5, shade * 0.8, shade * 0.7)
      pass:box(x, -0.1, z, 1.8, 0.2, 1.8)
    end
  end
  pass:setColor(1,1,1)
  pass:text({
      0xf0f0f0, 'Use ',
      0xf06000, 'left click',
      0xf0f0f0, ' to\norbit the camera'
    }, 0, 0.5, 0.52, 0.12)
  pass:text({
      0xf0f0f0, 'Use ',
      0xf06000, 'wheel',
      0xf0f0f0, ' to\nzoom in and out'
    }, 0.52, 0.5, 0, 0.12, math.pi/2, 0,1,0)
  pass:text({
      0xf0f0f0, 'Use ',
      0xf06000, 'middle click',
      0xf0f0f0, ' to\npan the camera'
    }, -0.52, 0.5, 0, 0.12, -math.pi/2, 0,1,0)
  pass:setWireframe(true)
  pass:setColor(1, 1, 1, 0.1)
  pass:monkey(0, 1.5, 0, 1.05, -math.pi * 0.1, 1, 0, 0)
  pass:cube(0, 0.5, 0, 1.05, 0, 0,1,0, 'line')
end

cam.integrate()