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
  pass:setWireframe(true)
  pass:setColor(1, 1, 1, 0.1)
  pass:monkey(0, 1.5, 0, 1.05, -math.pi * 0.1, 1, 0, 0)
  pass:cube(0, 0.5, 0, 1.05, 0, 0,1,0, 'line')
end

require'cam'.integrate()