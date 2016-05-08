luake = require("luake")

console = luake.newConsole()

function love.load()
  console:print("Hello World!")
end

function love.update(dt)
  console:update(dt)
end

function love.draw()
  console:draw()
end

function love.textinput(text)
  console:textinput(text)
end

function love.keypressed(key)
  console:keypressed(key)
end
