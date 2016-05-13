local utf8 = require("utf8")
tween = require("tween")

local luake = {}

local console = {}
console.x = 0
console.y = 0
console.partial = ""
console.echo = false
console.lines = {}
console.nLines = 10
console.hasFocus = false
console.focusText = "~"
console.text = nil
console.prompt = "]"
console.font = love.graphics.newFont("LiberationMono-Regular.ttf", 12)

console.cursor = "█"
console.isBlinked = true
console.blinkRate = 0.5 --in seconds
console.elapsed = 0

console.input = console.emptyinput
console.bgColor = { 128, 128, 128, 85 }
console.fgColor = { 255, 255, 255 }
console.__index = console

function luake.newConsole()
  local o = {__index = console }
  setmetatable(o, console)
  local y1 = -1 * (1 + o.nLines) * o.font:getHeight()
  o.y = y1
  o.tween = tween.new(1, o, { y = 0 }, 'outBounce')
  return o
end

function console:update(dt)
  --update cursor
  self.elapsed = self.elapsed + dt
  while self.elapsed >= self.blinkRate do
    --loop in case duration passed several times
    self.isBlinked = not self.isBlinked
    self.elapsed = self.elapsed - self.blinkRate
  end

  if self.hasFocus then
    self.tween:update(dt)
  else
    self.tween:update(-dt)
  end
end

function console:lineEntered(line)
  -- Override for line input processing
  print('callback invoked...')
end

function console:print(text)
  local drawable = love.graphics.newText(self.font, text)
  table.insert(self.lines, drawable)
end

function console:keypressed(key)
  -- See https://love2d.org/wiki/utf8 for overview of utf8
  if key == "backspace" then
    local offset = utf8.offset(self.partial, -1)
    if offset then
      self.partial = string.sub(self.partial, 1, offset-1)
    end
  elseif key == 'return' then
    self.lineEntered(self.partial) -- callback for input processing
    self:print(self.partial) -- echo input
    self.partial = ""
  end
  self:resetCursorBlink()
end

function console:resetCursorBlink()
  self.isBlinked = true
  self.elapsed = 0
end

function console:textinput(text)
  -- Toggle focus
  if text == self.focusText then
    --self.tween:reset()
    self.hasFocus = not self.hasFocus
    return
  end

  if not self.hasFocus then
    return
  end
  -- Apply text to *Focused* self
  if string.gmatch(text,"[%w%d \t]") then
    self.partial = self.partial .. text
  end
  self:resetCursorBlink()
end

function console:draw()
  local height = self.font:getHeight()

  --draw console background
  love.graphics.setColor(self.bgColor)
  love.graphics.rectangle('fill', self.x, self.y, love.graphics.getWidth(), (1+self.nLines)*height)

  -- draw prompt, cursor,  and any input
  love.graphics.setColor(self.fgColor)
  local cursor = self.isBlinked and self.cursor or ""
  local input = love.graphics.newText(self.font, self.prompt .. self.partial .. cursor)
  love.graphics.draw(input, self.x, height * self.nLines + self.y)


  local nLines = self.nLines
  local i = #self.lines
  while i > 0 do
    if nLines < 1 then
      break
    end
    love.graphics.draw(self.lines[i], self.x, (nLines-1)*height + self.y)
    i = i - 1
    nLines = nLines - 1
  end
end

return luake
