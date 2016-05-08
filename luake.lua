local utf8 = require("utf8")
tween = require("tween")

local luake = {}

local console = {}
console.x = 0
console.y = 0
console.partial = ""
console.echo = false
console.lines = {}
console.nlines = 10
console.hasFocus = false
console.focustext = "~"
console.text = nil
console.prompt = "]"
console.font = love.graphics.getFont()
console.emptyinput = love.graphics.newText(console.font, console.prompt)
console.input = console.emptyinput
console.bgcolor = { 128, 128, 128 }
console.fgcolor = { 0, 0, 0 }
console.__index = console

function luake.newConsole()
  local o = {__index = console }
  setmetatable(o, console)
  local y1 = -1 * (1 + o.nlines) * o.font:getHeight()
  o.y = y1
  o.tweenDown = tween.new(1, o, { y = 0 }, 'outBounce')
  return o
end

function console:update(dt)
  if self.hasFocus then
    self.tweenDown:update(dt)
  end
end

function console:lineentered(line)
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
      self.input = love.graphics.newText(self.font, self.prompt .. self.partial)
    end
  elseif key == 'return' then
    self.lineentered(self.partial) -- callback for input processing
    self:print(self.partial) -- echo input
    self.partial = ""
    self.input = self.emptyinput
  end
end

function console:textinput(text)
  -- Toggle focus
  if text == self.focustext then
    self.tweenDown:reset()
    self.hasFocus = not self.hasFocus
    return
  end

  if not self.hasFocus then
    return
  end
  -- Apply text to *Focused* self
  if string.gmatch(text,"[%w%d \t]") then
    self.partial = self.partial .. text
    self.input = love.graphics.newText(self.font, self.prompt .. self.partial)
  end
end

function console:draw()
  local height = self.font:getHeight()

  --draw console background
  love.graphics.setColor(self.bgcolor)
  love.graphics.rectangle('fill', self.x, self.y, love.graphics.getWidth(), (1+self.nlines)*height)

  -- draw prompt and any input
  love.graphics.setColor(self.fgcolor)
  if self.input then
    love.graphics.draw(self.input, self.x, height * self.nlines + self.y)
  end

  local nlines = self.nlines
  local i = #self.lines
  while i > 0 do
    if nlines < 1 then
      break
    end
    love.graphics.draw(self.lines[i], self.x, (nlines-1)*height + self.y)
    i = i - 1
    nlines = nlines - 1
  end
end

return luake
