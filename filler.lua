local map = [[
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

local smallmap = [[
##
##

##
##
]]

local funmap = [[
###
###
###

###
#x#
###

###
###
###
]]

local thickmap = [[
#xx
xxx
xxx

##x
##x
xxx

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

dir = {
  north = 1,
  east = 2,
  south = 3,
  west = 4,
  up = 5,
  down = 6,
}

function make_cardinal_mover()
  local facing_now = dir.north

  function right()
    turtle.turnRight()
    facing_now = facing_now + 1
    if facing_now > 4 then facing_now = 1 end
  end

  function turn_towards(direction)
    while facing_now ~= direction do
      right()
    end
  end

  return {
    turn_towards = turn_towards,
    facing_now = facing_now
  }
end

function dig_move(cardinal_mover, direction)
  if direction <= 4 and direction >= 1 then
    cardinal_mover.turn_towards(direction)
    turtle.dig()
    turtle.forward()
  elseif direction == dir.down then
    turtle.digDown()
    turtle.down()
  elseif direction == dir.up then
    turtle.digUp()
    turtle.up()
  else
    error('not a direction', direction)
  end
end

function new_pos(old_pos, to_move)
  local n_pos = {
    x = old_pos.x,
    y = old_pos.y,
    z = old_pos.z
  }

  if to_move == dir.up then 
    n_pos.y = n_pos.y - 1
  elseif to_move == dir.down then
    n_pos.y = n_pos.y + 1
  elseif to_move == dir.north then
    n_pos.z = n_pos.z - 1
  elseif to_move == dir.east then
    n_pos.x = n_pos.x + 1
  elseif to_move == dir.south then
    n_pos.z = n_pos.z + 1
  elseif to_move == dir.west then
    n_pos.x = n_pos.x - 1
  else
    error('not a direction:', to_move)
  end

  return n_pos
end

function node_type(block, n_pos)
  return block[n_pos.y] 
    and block[n_pos.y][n_pos.z]
    and block[n_pos.y][n_pos.z][n_pos.x]
end

function do_node(block, n_pos, replacement)
  block[n_pos.y][n_pos.z][n_pos.x] = replacement
end

function print_dir(di)
  for k, v in pairs(dir) do
    if v == di then
      print(k)
      return;
    end
  end
end

function flood_fill_3d(block, target, replacement)
  local mover = make_cardinal_mover()
  local start_pos = { x = 1, y = 1, z = 1}

  function should_fill(n_pos)
    local typ = node_type(block, n_pos) 
    return typ ~= nil and typ == target and target ~= replacement
  end

  function loop(n_pos)
    do_node(block, n_pos, replacement)

    for i = 1, 6 do
      local p = new_pos(n_pos, i)

      if should_fill(p) then
        print_dir(i)
        dig_move(mover, i)
        loop(p)
      end
    end
  end

  loop(start_pos)
end

return {
  make_cardinal_mover = make_cardinal_mover,
  dig_move = dig_move,
  parse_block = parse_block,
  flood_fill_3d = flood_fill_3d,
  ff = function(b) flood_fill_3d(b, '#', 'x') end,
  smallmap = parse_block(smallmap),
  funmap = parse_block(funmap),
  thickmap = parse_block(thickmap)
}
