map = [[
#####
#xxx#
#xxx#
#####

#####
#xxxx
#xxx#
#####

#####
#xxx#
#xxx#
#####
]]

function print_block(block)
  for i, level in pairs(b) do
    print('level:')
    for k, row in pairs(level) do
      for l, col in pairs(row) do
        io.write(col)
      end
      print('')
    end
  end
end

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

dir = {
  up = 1,
  down = 2,
  north = 3,
  east = 4,
  south = 5,
  west = 6,
}

function move(old_pos, to_move)
  local n_pos = {
    x = old_pos.x,
    y = old_pos.y,
    z = old_pos.z
  }

  if to_move == dir.up then 
    n_pos.y = n_pos.y + 1
  elseif to_move == dir.down then
    n_pos.y = n_pos.y - 1
  elseif to_move == dir.north then
    n_pos.z = n_pos.z + 1
  elseif to_move == dir.east then
    n_pos.x = n_pos.x - 1
  elseif to_move == dir.south then
    n_pos.z = n_pos.z - 1
  elseif to_move == dir.west then
    n_pos.x = n_pos.x + 1
  else
    error('not a direction:', to_move)
  end

  return n_pos
end

function node_type(block, n_pos)
  return block[n_pos.y] 
    and block[n_pos.y][n_pos.x]
    and block[n_pos.y][n_pos.x][n_pos.z]
end

function do_node(block, n_pos, replacement)
  block[n_pos.y][n_pos.x][n_pos.z] = replacement
end

function flood_fill_3d(block, n_pos, target, replacement)
  local typ = node_type(block, n_pos) 
  if typ == nill or typ ~= target or target == replacement then return end

  do_node(block, n_pos, replacement)
  for _, d in pairs(dir) do
    local new_p = move(n_pos, d)

    flood_fill_3d(block, new_p, target, replacement)
  end
end

-- b = parse_block(map)
-- start_pos = { x = 1, y = 1, z = 1}
-- 
-- flood_fill_3d(b, start_pos, '#', '.')
-- print_block(b)

turtle.up()
