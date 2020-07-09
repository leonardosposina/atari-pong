Ball = Class {}

-- Constructor
function Ball:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  -- Ball velocity and direction.
  self.dx = 0
  self.dy = math.random(-35, 35) * 5
end

-- Update Ball on x-axis and y-axis.
function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

-- Reset Ball to the start position.
function Ball:reset(dx)
  self.x = VIRTUAL_WIDTH / 2 - 2
  self.y = VIRTUAL_HEIGHT / 2 - 2
  self.dx = dx
  self.dy = math.random(-35, 35) * 5
end

-- Detect collisions with paddles.
function Ball:collides(box)
  -- Ball is to the left of the box or Ball is to the right of the box.
  if self.x + self.width < box.x or self.x > box.x + box.width then
    return false
  end
  -- Ball is above the box or Ball is under the box.
  if self.y + self.height < box.y or self.y > box.y + box.height then
    return false
  end
  -- If equal, it is a collision!
  return true
end

-- Deflect Ball on x-axis.
function Ball:deflectX(x)
  self.dx = -self.dx
  self.x = x
end

-- Deflect Ball on y-axis.
function Ball:deflectY(y)
  self.dy = -self.dy
  self.y = y
end

-- Render Ball into the screen.
function Ball:render()
  love.graphics.rectangle("fill", self.x, self.y, self.width , self.height) 
end