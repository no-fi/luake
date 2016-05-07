local utf8 = require("utf8")
local console = {}

console.partial = ""
console.echo = false
console.lines = {}
console.hasFocus = true
console.focustext = "~"
console.text = nil
console.prompt = ']'
console.font = love.graphics.getFont()
console.emptyinput = love.graphics.newText(console.font, console.prompt)
console.input = console.emptyinput
console.nlines = 10
console.bgcolor = { 128, 128, 128 }
console.fgcolor = { 0, 0, 0 }

function console.lineentered(line)
  -- Override for line input processing
  print('callback invoked...')
end

function console.print(text)
  local drawable = love.graphics.newText(console.font, text)
  table.insert(console.lines, drawable)
end

function console.keypressed(key)
  -- See https://love2d.org/wiki/utf8 for overview of utf8
  if key == "backspace" then
    local offset = utf8.offset(console.partial, -1)
    if offset then
      console.partial = string.sub(console.partial, 1, offset-1)
      console.input = love.graphics.newText(console.font, console.prompt .. console.partial)
    end
  elseif key == 'return' then
    console.lineentered(console.partial) -- callback for input processing
    console.print(console.partial)
    console.partial = ""
    console.input = console.emptyinput
  end
end

function console.textinput(text)
  -- Toggle focus
  if text == console.focustext then
    console.hasFocus = not console.hasFocus
    return
  end

  if not console.hasFocus then
    return
  end
  -- Apply text to *Focused* console
  if string.gmatch(text,"[%w%d \t]") then
    console.partial = console.partial .. text
    console.input = love.graphics.newText(console.font, console.prompt .. console.partial)
  end
end

function console.draw()
  if not console.hasFocus then
    return
  end

  local height = console.font:getHeight()

  --draw console background
  love.graphics.setColor(console.bgcolor)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), (1+console.nlines)*height)

  -- draw prompt and any input
  love.graphics.setColor(console.fgcolor)
  if console.input then
    love.graphics.draw(console.input, 0, height * console.nlines)
  end

  local nlines = console.nlines
  local i = #console.lines
  while i > 0 do
    if nlines < 1 then
      break
    end
    love.graphics.draw(console.lines[i], 0, (nlines-1)*height)
    i = i - 1
    nlines = nlines - 1
  end
end

return console
