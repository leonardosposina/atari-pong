--[[
  
PPPPPPPPPPPPPPPPP        OOOOOOOOO     NNNNNNNN        NNNNNNNN        GGGGGGGGGGGGG 
P::::::::::::::::P     OO:::::::::OO   N:::::::N       N::::::N     GGG::::::::::::G
P::::::PPPPPP:::::P  OO:::::::::::::OO N::::::::N      N::::::N   GG:::::::::::::::G
PP:::::P     P:::::PO:::::::OOO:::::::ON:::::::::N     N::::::N  G:::::GGGGGGGG::::G
  P::::P     P:::::PO::::::O   O::::::ON::::::::::N    N::::::N G:::::G       GGGGGG
  P::::P     P:::::PO:::::O     O:::::ON:::::::::::N   N::::::NG:::::G              
  P::::PPPPPP:::::P O:::::O     O:::::ON:::::::N::::N  N::::::NG:::::G              
  P:::::::::::::PP  O:::::O     O:::::ON::::::N N::::N N::::::NG:::::G    GGGGGGGGGG
  P::::PPPPPPPPP    O:::::O     O:::::ON::::::N  N::::N:::::::NG:::::G    G::::::::G
  P::::P            O:::::O     O:::::ON::::::N   N:::::::::::NG:::::G    GGGGG::::G
  P::::P            O:::::O     O:::::ON::::::N    N::::::::::NG:::::G        G::::G
  P::::P            O::::::O   O::::::ON::::::N     N:::::::::N G:::::G       G::::G
PP::::::PP          O:::::::OOO:::::::ON::::::N      N::::::::N  G:::::GGGGGGGG::::G   
P::::::::P           OO:::::::::::::OO N::::::N       N:::::::N   GG:::::::::::::::G
P::::::::P             OO:::::::::OO   N::::::N        N::::::N     GGG::::::GGG:::G
PPPPPPPPPP               OOOOOOOOO     NNNNNNNN         NNNNNNN        GGGGGG   GGGG

  ]]

-- Lightweight object orientation from https://github.com/vrld/hump
Class = require 'class'
-- Push Library for LÖVE from https://github.com/Ulydev/push
push = require 'push'
-- Classes
require 'Ball'
require 'Paddle'

math.randomseed(os.time())

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
  -- Set game title.
  love.window.setTitle("Pong!")
  -- Remove blur from objects on the screen.
  love.graphics.setDefaultFilter("nearest", "nearest")
  -- Screen setup.
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })
  -- Font objects.
  smallFont = love.graphics.newFont("font.TTF", 8)    
  scoreFont = love.graphics.newFont("font.TTF", 40)
  victoryFont = love.graphics.newFont("font.TTF", 24)
  -- Audio objects array.
  sounds = {
    ["paddle_hit"] = love.audio.newSource("paddle_hit.wav", "static"),
    ["point_scored"] = love.audio.newSource("point_scored.wav", "static"),
    ["wall_hit"] = love.audio.newSource("wall_hit.wav", "static")
  }
  -- Game settings.
  game = {
    ["state"] = "start",
    ["playerTurn"] = "",
    ["winner"] = "",
    ["maxScore"] = 10,
    ["coinFlip"] = math.random(2)
  }

  -- Game Ball.
  -- Ball(x, y, width, height)
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
  -- Players paddles.
  -- Paddle(x, y, width, height)
  paddle1 = Paddle("Player 1", 5, 20, 5, 20)
  paddle2 = Paddle("Player 2", VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
  -- Enables AI for the Player 2.
  paddle2:enableAI()

  -- A player is chosen to start the game after "flip a coin".
  if game["coinFlip"] == 1 then
    game["playerTurn"] = paddle1.name
    ball:reset(math.random(100, 150))
  elseif game["coinFlip"] == 2 then
    game["playerTurn"] = paddle2.name
    ball:reset(math.random(-150, -100))
  end
  
end

-- Resizes window dynamically.
function love.resize(w, h)
  push:resize(w, h)
end

-- Normalizing with delta time.
function love.update(dt)
  
  -- Check if game state is 'play'
  if game["state"] == "play" then
    -- Paddles update.
    paddle1:update(dt)
    paddle2:update(dt)
    -- Ball update.
    ball:update(dt)
    
    -- Scores update.
    -- Player 1 score.
    if ball.x > VIRTUAL_WIDTH - ball.width then
      paddle1:scored()
      ball:reset(math.random(-150, -100))
      game["playerTurn"] = paddle2.name
      sounds["point_scored"]:play()
      if paddle1.scores >= game["maxScore"] then
        game["state"] = "victory"
        game["winner"] = paddle1.name
      else
        game["state"] = "serve"
      end
    end
    -- Player 2 score.
    if ball.x < 0 then
      paddle2:scored()
      ball:reset(math.random(100, 150))
      game["playerTurn"] = paddle1.name
      sounds["point_scored"]:play()
      if paddle2.scores >= game["maxScore"] then
        game["state"] = "victory"
        game["winner"] = paddle2.name
      else
        game["state"] = "serve"
      end
    end

    -- Players movements.
    -- Player 1 movements.
    if love.keyboard.isDown('w') then
      paddle1:move(-PADDLE_SPEED)
    elseif love.keyboard.isDown('s') then
      paddle1:move(PADDLE_SPEED)
    else
      paddle1:move(0)
    end
    -- Player 2 movements.
    if love.keyboard.isDown("up") and not paddle2.ai then
      paddle2:move(-PADDLE_SPEED)
    elseif love.keyboard.isDown("down") and not paddle2.ai then
      paddle2:move(PADDLE_SPEED)
    elseif not paddle2.ai then
      paddle2:move(0)
    end
    -- Artificial Inteligence movements.
    if paddle2.ai then
      -- Paddle:trackBall(ball, paddleSpeed)
      paddle2:trackBall(ball, PADDLE_SPEED) 
    end

    -- Ball collisions.
    -- Detect collisions with paddles.
    if ball:collides(paddle1) then
      -- Deflect ball to the right.
      ball:deflectX(paddle1.x + paddle1.width)
      sounds["paddle_hit"]:play()
    end
    if ball:collides(paddle2) then
      -- Deflect ball to the left.
      ball:deflectX(paddle2.x - ball.width)
      sounds["paddle_hit"]:play()
    end
    -- Detect collisions with top and bottom borders.
    if ball.y <= 0 then
      -- Deflect the ball down.
      ball:deflectY(0)
      sounds["wall_hit"]:play()
    end
    if ball.y + ball.height >= VIRTUAL_HEIGHT then
      -- Deflect the ball up.
      ball:deflectY(VIRTUAL_HEIGHT - ball.height)
      sounds["wall_hit"]:play()
    end
  end

end

-- Function to capture keyboard events.
function love.keypressed(key)
  -- Game states.
  if key == "enter" or key == "return" then
    if game["state"] == "start" then
      game["state"] = "serve"
    elseif game["state"] == "serve" then 
      game["state"] = "play"
    elseif game["state"] == "victory" then
      paddle1:scoresReset()
      paddle2:scoresReset()
      game["state"] = "start"
    end
  -- Toggle Artificial Inteligence state.
  elseif key == 'p' then
    paddle2:toggleAIState()
  -- Exit game.
  elseif key == "escape" then
    love.event.quit()
  end

end

-- Function to draw objects into the screen.
function love.draw()

  push:apply("start")
  
  --Clear the screen with a specified color.
  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
  -- Print messages.
  love.graphics.setFont(smallFont)
  if game["state"] == "start" then
    love.graphics.printf("Welcome to Pong!", 0 , 20, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press 'Enter' to Play!",0, 32, VIRTUAL_WIDTH, "center")
  elseif game["state"] == "serve" then
    love.graphics.printf(game["playerTurn"] .."'s turn!", 0 , 20, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press 'Enter' to Serve!", 0 , 32, VIRTUAL_WIDTH, "center")
  elseif game["state"] == "victory" then
    love.graphics.setFont(victoryFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.printf(game["winner"] .." wins!", 0 , 10, VIRTUAL_WIDTH, "center")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(smallFont)
    love.graphics.printf("Press 'Enter' to Serve!", 0 , 42, VIRTUAL_WIDTH, "center")
  end
  
  -- Render players scores.
  renderPlayersScores()
  -- Render players names.
  renderPlayersNames()
  -- Render Paddles.
  paddle1:render()
  paddle2:render()
  -- Render Ball.
  ball:render()
  
  push:apply("end")
  
end

-- Helper funcion to render players scores.
function renderPlayersScores()
  love.graphics.setFont(scoreFont)
  love.graphics.print(paddle1.scores, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 4)
  love.graphics.print(paddle2.scores, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 4)
end

-- Helper funcion to render Players names.
function renderPlayersNames()
  love.graphics.setColor(0.5, 0.5, 1, 1)
  love.graphics.setFont(smallFont)
  love.graphics.print(paddle1:getPlayerName(), 50, 20)
  love.graphics.print(paddle2:getPlayerName(), VIRTUAL_WIDTH - 85, 20)
  love.graphics.setColor(1, 1, 1, 1)
end