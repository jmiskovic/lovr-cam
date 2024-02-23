local m = {}

m.fov = math.pi / 2
m.near_plane = 0.01

m.upvector = Vec3(0, 1, 0)
m.position = Vec3(0, 3, 4)
m.center = Vec3(0, 0, 0)

m.zoom_speed = 1.0
m.orbit_speed = 1.0
m.pan_speed = 1.0

m.azimuth = math.pi / 2
m.radius = m.position:distance(m.center)
m.polar = math.acos((m.position.y - m.center.y) / m.radius)

-- angles are measured from the up vector
m.polar_upper = 0.1
m.polar_lower = math.pi - m.polar_upper

m.radius_lower = 0.1

-- these are read-only; overwriten in nudge() and resize()
m.pose = Mat4():target(m.position, m.center, m.upvector)
m.projection = Mat4():perspective(m.fov, 1, m.near_plane, 0)

-- should be called on top of lovr.draw()
function m.setCamera(pass)
  pass:setViewPose(1, m.pose)
  pass:setProjection(1, m.projection)
end


-- make relative changes to camera position
function m.nudge(delta_azimuth, delta_polar, delta_radius)
  delta_azimuth = delta_azimuth or 0
  delta_polar = delta_polar or 0
  delta_radius  = delta_radius or 0
  m.azimuth = m.azimuth + delta_azimuth
  m.polar = math.max(m.polar_upper, math.min(m.polar_lower, m.polar + delta_polar))
  m.radius = math.max(m.radius_lower, m.radius + delta_radius)
  m.position.x = m.center.x + m.radius * math.sin(m.polar) * math.cos(m.azimuth)
  m.position.y = m.center.y + m.radius * math.cos(m.polar)
  m.position.z = m.center.z + m.radius * math.sin(m.polar) * math.sin(m.azimuth)
  m.pose:target(m.position, m.center, m.upvector)
end


-- should be called from lovr.resize()
function m.resize(width, height)
  local aspect = width / height
  m.projection = Mat4():perspective(m.fov, aspect, m.near_plane, 0)
end
m.resize(lovr.system.getWindowDimensions())


-- should be called from lovr.mousemoved()
function m.mousemoved(x, y, dx, dy)
  if  lovr.system.isMouseDown(3) then
    if lovr.system.isMouseDown(1) then
      m.center.y = m.center.y + m.pan_speed * 0.01 * dy
    else
      local view = mat4(m.pose):invert()
      local camera_right   = vec3(view[1], view[5], view[9])
      local camera_forward = vec3(view[2],       0, view[10]):normalize()
      m.center:add(camera_right   * (m.pan_speed * 0.005 * -dx))
      m.center:add(camera_forward * (m.pan_speed * 0.005 * dy))
    end
    m.nudge()
  elseif lovr.system.isMouseDown(1) then
    m.nudge(m.orbit_speed * 0.0025 * dx, m.orbit_speed * 0.0025 * -dy, 0)
  end
end


-- should be called from lovr.wheelmoved()
function m.wheelmoved(dx, dy)
  m.nudge(0, 0, -dy * m.zoom_speed * 0.12)
end


-- quick way to start using camera module - just call this function
function m.integrate()
  local stub_fn = function() end
  local existing_cb = {
    draw = lovr.draw or stub_fn,
    resize = lovr.resize or stub_fn,
    mousemoved = lovr.mousemoved or stub_fn,
    wheelmoved = lovr.wheelmoved or stub_fn,
  }
  local function wrap(callback)
    return function(...)
      m[callback](...)
      existing_cb[callback](...)
    end
  end
  lovr.mousemoved = wrap('mousemoved')
  lovr.wheelmoved = wrap('wheelmoved')
  lovr.resize = wrap('resize')
  lovr.draw = function(pass)
    m.setCamera(pass)
    existing_cb.draw(pass)
  end
end

return m