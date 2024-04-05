local cam = require'cam'

local player_pos = Vec3()
local player_vel = Vec3(0, 0, -0.01)


-- next three functions convert mouse coordinate from screen to the 3D position on the ground plane
local function getWorldFromScreen(pass)
  local w, h = pass:getDimensions()
  local clip_from_screen = mat4(-1, -1, 0):scale(2 / w, 2 / h, 1)
  local view_pose = mat4(pass:getViewPose(1))
  local view_proj = pass:getProjection(1, mat4())
  return view_pose:mul(view_proj:invert()):mul(clip_from_screen)
end


local function getRay(world_from_screen, distance)
  local NEAR_PLANE = 0.01
  distance = distance or 1e3
  local ray = {}
  local x, y = lovr.system.getMousePosition()
  ray.origin = vec3(world_from_screen:mul(x, y, NEAR_PLANE / NEAR_PLANE))
  ray.target = vec3(world_from_screen:mul(x, y, NEAR_PLANE / distance))
  return ray
end


local function mouseOnGround(ray)
  if ray.origin:distance(ray.target) < 1e-2 then
    return vec3(0, 0, 0)
  end
  local ray_direction = (ray.target - ray.origin):normalize()
  -- intersect the ray onto ground plane
  local plane_direction = vec3(0, 1, 0)
  local dot = ray_direction:dot(plane_direction)
  if dot == 0 then
    return vec3(0, 0, 0)
  end
  local ray_length = (-ray.origin):dot(plane_direction) / dot
  local hit_spot = ray.origin + ray_direction * ray_length
  return hit_spot
end


local crumbs = {}
local crumbs_eaten = 0
local crumbs_txt = 'Find\nsome\ncrumbs'
for i = 1, 10 do
  table.insert(crumbs, Vec2(-0.5 + lovr.math.random(), -0.5 + lovr.math.random()):mul(20))
end

function lovr.draw(pass)
  lovr.graphics.setBackgroundColor(0, 0, 0)
  -- player control
  local dt = lovr.timer.getDelta()
  if lovr.system.isMouseDown(2) then
    local world_from_screen = getWorldFromScreen(pass)
    local ray = getRay(world_from_screen)
    local spot = mouseOnGround(ray)
    local mouse_dir = spot - player_pos
    if #mouse_dir > 15 then
      mouse_dir:normalize():mul(15)
    end
    player_vel:add(mouse_dir * dt)
  end
  -- arrows with relative camera
  local arrows_dir = vec3(0, 0, 0)
  if lovr.system.isKeyDown('up') then
    arrows_dir:add(0, 0, -1)
  elseif lovr.system.isKeyDown('down') then
    arrows_dir:add(0, 0, 1)
  end
  if lovr.system.isKeyDown('left') then
    arrows_dir:add(-1, 0, 0)
  elseif lovr.system.isKeyDown('right') then
    arrows_dir:add(1, 0, 0)
  end
  arrows_dir = quat(cam.pose) * arrows_dir
  arrows_dir.y = 0
  player_vel:add(arrows_dir * 7 * dt)
  -- basic euler integration
  player_pos:add(player_vel * dt)
  player_vel:mul(0.95)

  -- basic game loop
  for i, crumb in ipairs(crumbs) do
    if crumb:distance(player_pos.xz) < 0.5 then
      crumbs_eaten = crumbs_eaten + 1
      crumbs_txt = 'Crumbs eaten\n' .. crumbs_eaten
      if crumbs_eaten > 7 then
        crumbs_txt = crumbs_txt .. '\n...are you\nententained\nalready?'
      end
      crumb:set(-0.5 + lovr.math.random(), -0.5 + lovr.math.random()):mul(20)
      lovr.graphics.setBackgroundColor(1, 1, 1)
    end
    pass:setColor(0x40a0ff)
    pass:sphere(crumb.x, 0, crumb.y,  0.2)
  end

  pass:setColor(1,1,1)
  pass:text('Hold right\nmouse button\nto move\ntoward it', -2, 0.05, 0,  0.5, -math.pi/2, 1,0,0)
  pass:text(crumbs_txt, 2, 0.05, 0,  0.5, -math.pi/2, 1,0,0)

  pass:setColor(0x101010)
  pass:plane(0, 0, 0,  20, 20,  -math.pi/2, 1,0,0)
  pass:setColor(0x505050)
  pass:plane(0, 0.01, 0,  20, 20,  -math.pi/2, 1,0,0, 'line', 100, 100)
  pass:setColor(0xD0A010)
  pass:capsule(player_pos, player_pos + vec3(0, 0.4, 0), 0.3)
  local player_azimuth = math.atan2(player_vel.z, player_vel.x)
  pass:setColor(0x804000)
  pass:cone(player_pos, 0.3, 0.6,  -player_azimuth - math.pi/2, 0,1,0)
  cam.center:lerp(player_pos, 0.1)
  d_azimuth = player_azimuth - cam.azimuth + math.pi 
  d_azimuth = (d_azimuth + math.pi) % (2 * math.pi) - math.pi -- wrap angle to -PI to PI range
  cam.nudge(d_azimuth * 0.005)
end

cam.integrate()