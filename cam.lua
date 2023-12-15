local m = {}

m.fov = math.pi / 2
m.near_plane = 0.01

m.upvector = Vec3(0, 1, 0)
m.position = Vec3(0, 3, 4)
m.center = Vec3(0, 0, 0)

m.view_matrix = Mat4():target(m.position, m.center, m.upvector)
m.proj_matrix = Mat4():perspective(m.fov, 1, m.near_plane, 0)

m.zoom_speed = 0.2
m.orbit_speed = 1.0
m.pan_speed = 1.0

-- in spherical coordinates
m.azimuth = 0
m.radius = m.position:distance(m.center)
m.polar = math.acos((m.position.y - m.center.y) / m.radius)


function m.setCamera(pass)
  pass:setViewPose(1, m.view_matrix)
  pass:setProjection(1, m.proj_matrix)
end


function m.nudge(delta_azimuth, delta_polar, delta_radius)
  delta_azimuth = delta_azimuth or 0
  delta_polar = delta_polar or 0
  delta_radius  = delta_radius or 0
  m.azimuth = m.azimuth + delta_azimuth
  m.polar = math.max(0.1, math.min(math.pi - 0.1, m.polar + delta_polar))
  m.radius = math.max(0.1, m.radius + delta_radius)
  m.position.x = m.center.x + m.radius * math.sin(m.polar) * math.sin(m.azimuth)
  m.position.y = m.center.y + m.radius * math.cos(m.polar)
  m.position.z = m.center.z + m.radius * math.sin(m.polar) * math.cos(m.azimuth)
  m.view_matrix:target(m.position, m.center, m.upvector)
end


function m.resize(width, height)
  local aspect = width / height
  m.proj_matrix = Mat4():perspective(m.fov, aspect, m.near_plane, 0)
end
m.resize(lovr.system.getWindowDimensions())


function m.mousemoved(x, y, dx, dy)
  if lovr.system.isMouseDown(1) then
    m.nudge(m.orbit_speed * 0.004 * -dx, m.orbit_speed * 0.004 * -dy, 0)
  elseif  lovr.system.isMouseDown(3) then
    local view = mat4(m.view_matrix):invert()
    local camera_right   = vec3(view[1], view[5], view[9])
    local camera_forward = vec3(view[2],       0, view[10]):normalize()
    m.center:add(camera_right   * (m.pan_speed * 0.01 * -dx))
    m.center:add(camera_forward * (m.pan_speed * 0.01 * dy))
    m.nudge()
  end
end


function m.wheelmoved(dx, dy)
  m.nudge(0, 0, -dy * m.zoom_speed)
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