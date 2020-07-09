Paddle = Class {}

-- Constructor
function Paddle:init(name, x, y, width, height)
  self.name = name
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.dy = 0
  self.scores = 0
  self.ai = false
end

-- Paddle movement on y-axis.
function Paddle:move(dy)
  self.dy = dy
end

-- Update Paddle on y-axis.
function Paddle:update(dt)
  if self.dy < 0 then
    self.y = math.max(0, self.y + self.dy * dt)
  elseif self.dy > 0 then
    self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
  end
end

-- Register Paddle score.
function Paddle:scored()
  self.scores = self.scores + 1
end

-- Reset Paddle scores.
function Paddle:scoresReset()
  self.scores = 0
end

-- Enable AI on the Paddle.
function Paddle:enableAI()
  self.ai = true
end

-- Toggle Paddle AI state.
function Paddle:toggleAIState() 
  self.ai = not self.ai
end

-- Return the player name.
function Paddle:getPlayerName()
  if self.ai then
    return "Computer"
  else
    return self.name
  end
end

-- Paddle AI to track the ball on the screen.
function Paddle:trackBall(ball, paddleSpeed)
  -- If the ball is under the paddle.
  if ball.y + ball.height >= self.y + self.height then
    self.dy = paddleSpeed
  -- If the ball is above the paddle.
  elseif ball.y <= self.y then
    self.dy = -paddleSpeed
  else
    self.dy = 0
  end
end

-- Render Paddle into the screen.
function Paddle:render()
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end