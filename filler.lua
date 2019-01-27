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
x####
#####
#####
#####
#####

xx###
xx###
#####
#####
#####

xxx##
xxx##
xxx##
#####
#####

xxxx#
xxxx#
xxxx#
xxxx#
#####

xxxxx
xxxxx
xxxxx
xxxxx
xxxxx
]]

function Queue(t)
  local first = 0
  local last = 0
  local q = {}

  function enqueue(v)
    q[last] = v
    last = last + 1
  end

  for _, v in pairs(t) do enqueue(v) end

  return {
    is_empty = function() return first == last end,
    enqueue = enqueue,
    dequeue = function()
      local v = q[first]
      first = first + 1
      return v
    end
  }
end

function Set(t, hash_fun)
  local s = {}
  for _, v in pairs(t) do s[hash_fun(v)] = true end

  function show()
    for k, v in pairs(s) do print(k, v) end
  end

  return {
    show = show,
    contains = function(v) return s[hash_fun(v)] end,
    remove = function(v) s[hash_fun(v)] = nil end,
    add = function(v) s[hash_fun(v)] = true end,
    is_empty = function()
      local count = 0
      for k, v in pairs(s) do
        count = count + 1
      end
      return count == 0
    end,
    all = s
  }
end

function pos_to_string(p)
  return tostring(p.x) .. '|' .. tostring(p.y) .. '|' .. tostring(p.z)
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
  north = 1,
  east = 2,
  south = 3,
  west = 4,
  up = 5,
  down = 6,
}

function make_cardinal_mover(position)
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
    facing_now = facing_now,
    position = position
  }
end

function dig_move(cardinal_mover, direction)
  if direction <= 4 and direction >= 1 then
    cardinal_mover.turn_towards(direction)
    turtle.dig()
    assert(turtle.forward())
  elseif direction == dir.down then
    turtle.digDown()
    assert(turtle.down())
  elseif direction == dir.up then
    turtle.digUp()
    assert(turtle.up())
  else
    error('not a direction', direction)
  end
  cardinal_mover.position = new_pos(cardinal_mover.position, direction)
end

function adj_nodes(pos)
  local nodes = {}
  for i = 1, 6 do
    nodes[i] = new_pos(pos, i)
  end

  return nodes
end

function are_adjacent(p1, p2)
  return adj_nodes(p1).contains(p2)
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

function print_dir(di)
  for k, v in pairs(dir) do
    if v == di then
      print(k)
      return;
    end
  end
end

function print_block(block, c_pos)
  for i, level in pairs(block) do
    print('level:')
    for k, row in pairs(level) do
      for l, col in pairs(row) do
        if i == c_pos.y and k == c_pos.z and l == c_pos.x then
          io.write('%')
        else
          io.write(col)
        end
      end
      print('')
    end
  end
  print('')
end

function num_entries(table)
  local count = 0
  for k, v in pairs(table) do
    count = count + 1
  end
  return count
end

function first_that(table, pred)
  for k, v in pairs(table) do
    if pred(v) then
      return k, v
    end
  end
end

function valid_moves(pos, pred)
  local moves = {}
  for dir, node in pairs(adj_nodes(pos)) do
    if pred(node) then moves[dir] = node end
  end
  return moves
end

function flood_fill_3d(block, target, replacement)
  if target == replacement then
    error('target cannot be the same as replacement') 
  end

  local start_pos = { x = 1, y = 1, z = 1}
  local mover = make_cardinal_mover(start_pos)
  local todo = Set({}, pos_to_string)

  function should_fill(n_pos)
    local typ = node_type(block, n_pos) 
    return typ ~= nil and typ == target
  end

  function is_filled(n_pos)
    local typ = node_type(block, n_pos) 
    return typ ~= nil and typ == replacement
  end

  function mark_node(pos)
    block[pos.y][pos.z][pos.x] = replacement
  end

  function pair(a, b) return { a, b } end
  function unpair(p) return p[1], p[2] end

  function find_path(start_pos, end_poss)
    local q = Queue({ pair(start_pos, { nil }) })
    local visited = Set({}, pos_to_string)

    function pred(v)
      return is_filled(v) or end_poss.contains(v)
    end

    while not q.is_empty() do
      local vertex, path = unpair(q.dequeue())
      visited.add(vertex)

      for dir, adj in pairs(valid_moves(vertex, pred)) do
        if end_poss.contains(adj) then
          return path
        elseif not visited.contains(adj) then
          visited.add(adj)
          local new_path = append(path, dir)
          q.enqueue(pair(adj, new_path))
        end
      end
    end
  end
  
  function append(ls, e)
    local out = {}
    for i = 0, #ls do
      out[i] = ls[i]
    end
    out[#ls + 1] = e
    return out
  end

  function walk(n_pos, from_dir)
    mark_node(n_pos)

    if from_dir then
      dig_move(mover, from_dir)
      todo.remove(n_pos)
    end

    print_block(block, mover.position)
    io.read()
    for k, v in pairs(adj_nodes(n_pos)) do
      if should_fill(v) then todo.add(v) end
    end

    local dir, node = first_that(adj_nodes(n_pos), should_fill)

    if node then
      walk(node, dir)
    else
      if not todo.is_empty() then
        local path = find_path(mover.position, todo)
        for _, dir in pairs(path) do
          dig_move(mover, dir)
        end
        walk(mover.position, nil)
      end
    end

  end

  walk(start_pos)
  return block
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
