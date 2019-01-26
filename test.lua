map = [[
###
###
###

###
###
###

###
###
###
]]

function parse_block(map)
  local block = {}
  local level = {}

  for line in map:gmatch('([^\n]*)\n?') do
    if line == '' then
      block[#block + 1] = level
      level = {}
    else
      local chars = {}
      for i = 1, #line do
        chars[#chars + 1] = string.sub(line, i, i)
      end
      level[#level + 1] = chars
    end
  end
  block[#block + 1] = level

  return block
end

b = parse_block(map)
for i, level in pairs(b) do
  print('level:')
  for k, row in pairs(level) do
    for l, col in pairs(row) do
      io.write(col)
    end
    print('')
  end
end
