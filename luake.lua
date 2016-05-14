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

console.tweenIsComplete = true
console.tween = nil

function luake.newConsole()
  local o = {__index = console }
  setmetatable(o, console)
  o.y = -1 * (1 + o.nLines) * o.font:getHeight()
  return o
end

function console:getDimensions()
  local width = love.graphics.getWidth()
  local height = (1 + self.nLines) * self.font:getHeight()
  return width, height
end

function console:update(dt)
  --update cursor
  self.elapsed = self.elapsed + dt
  while self.elapsed >= self.blinkRate do
    --loop in case duration passed several times
    self.isBlinked = not self.isBlinked
    self.elapsed = self.elapsed - self.blinkRate
  end

  if self.tween then self.tweenIsComplete = self.tween:update(dt) end
end

function console:lineEntered(line)
  -- Override for line input processing
  print('callback invoked...')
end

function console:print(text)
  local drawable = love.graphics.newText(self.font, self.prompt .. text)
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
    self:toggleFocus()
    return
  end

  if not self.hasFocus then return end

  -- Apply text to *Focused* self
  if string.gmatch(text,"[%w%d \t]") then
    self.partial = self.partial .. text
  end
  self:resetCursorBlink()
end

function console:toggleFocus()
  self.hasFocus = not self.hasFocus
  if self.hasFocus then
    self.tween = tween.new(1, self, { y = 0 }, 'inBounce')
  else
    local _, y1 = self:getDimensions()
    self.tween = tween.new(1, self, { y = -y1 }, 'outExpo')
  end
end

function console:draw()
  -- skip drawing if rollup animation complete and console has lost focus
  if not self.hasFocus and self.tweenIsComplete then return end

  local height = self.font:getHeight()
  local w, h = console:getDimensions()

  --draw console background
  love.graphics.setColor(self.bgColor)
  love.graphics.rectangle('fill', self.x, self.y, w, h )

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
