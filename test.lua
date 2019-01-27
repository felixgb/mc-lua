filler = loadfile('filler.lua')()

local function print_block(block)
  for i, level in pairs(block) do
    print('level:')
    for k, row in pairs(level) do
      for l, col in pairs(row) do
        io.write(col)
      end
      print('')
    end
  end
end

function assert_commands(expected, actual)
  local len = #expected > #actual and #expected or #actual
  for i, v in pairs(expected) do
    if v ~= actual[i] then
      print('\27[31mCommand mismatch:')
      print('index', 'expect', 'actual')
      for i = 1, len do
        print(i, expected[i], actual[i])
      end
      assert(false)
    end
  end
end

function test_with_turtle(f, expected_commands)
  commands = {}
  turtle = {
    turnRight = function() commands[#commands + 1] = 'right'; return true end,
    forward = function() commands[#commands + 1] = 'forward'; return true end,
    dig = function() commands[#commands + 1] = 'dig'; return true end,
    digDown = function() commands[#commands + 1] = 'digDown'; return true end,
    digUp = function() commands[#commands + 1] = 'digUp'; return true end,
    down = function() commands[#commands + 1] = 'down'; return true end,
    up = function() commands[#commands + 1] = 'up'; return true end
  }
  f()
  assert_commands(expected_commands, commands)
end

function test_turn_south()
  local start_pos = { x = 1, y = 1, z = 1}
  local test = function()
    mover = filler.make_cardinal_mover(start_pos)
    mover.turn_towards(dir.south)
  end
  local expected = {
    'right',
    'right'
  }

  test_with_turtle(test, expected)
end

function test_360()
  local start_pos = { x = 1, y = 1, z = 1}
  local test = function()
    mover = filler.make_cardinal_mover(start_pos)
    mover.turn_towards(dir.east)
    mover.turn_towards(dir.north)
    assert(mover.facing_now == dir.north)
  end
  local expected = {
    'right',
    'right',
    'right',
    'right'
  }

  test_with_turtle(test, expected)
end

function test_turn_north()
  local start_pos = { x = 1, y = 1, z = 1}
  local test = function()
    mover = filler.make_cardinal_mover(start_pos)
    mover.turn_towards(dir.north)
  end
  local expected = {}
  test_with_turtle(test, expected)
end

function test_dig_move_south()
  local start_pos = { x = 1, y = 1, z = 1}
  local test = function()
    mover = filler.make_cardinal_mover(start_pos)
    filler.dig_move(mover, dir.south)
  end
  local expected = {
    'right',
    'right',
    'dig',
    'forward'
  }

  test_with_turtle(test, expected)
end

function test_ff(map, expected)
  local start_pos = { x = 1, y = 1, z = 1}
  local test = function()
    local b = parse_block(map)
    mover = filler.make_cardinal_mover(start_pos)
    print_block(filler.flood_fill_3d(b, '.', 'x'))
  end

  test_with_turtle(test, expected)
end

function test_adj_move()
  local map = [[
.#...
...##
#..##
..###
..###
]]
  local expected_map = [[
x#xxx
xxx##
#xx##
xx###
xx###
]]
  local start_pos = { x = 1, y = 1, z = 1}
  local test = function()
    local b = parse_block(map)
    mover = filler.make_cardinal_mover(start_pos)
    filler.flood_fill_3d(b, '.', 'x')
  end

  test_with_turtle(test, {})
end

-- test_ff([[
-- ...
-- ]], {
--   'right',
--   'dig',
--   'forward',
--   'right',
--   'right',
--   'dig',
--   'forward',
-- })
test_adj_move()
test_360()
test_turn_north()
test_turn_south()
test_dig_move_south()
test_ff(
[[
...
###
###
]],
{
  'right',
  'dig',
  'forward',
  'dig',
  'forward'
})

test_ff(
[[
...
##.
##.
]],
{
  'right',
  'dig',
  'forward',
  'dig',
  'forward',
  'right',
  'dig',
  'forward',
  'dig',
  'forward'
})

test_ff(
[[
..
..
]],
{
  'right',
  'dig',
  'forward',
  'right',
  'dig',
  'forward',
  'right',
  'dig',
  'forward'
})

test_ff(
[[
..
..

..
..
]],
{
  'right',
  'dig',
  'forward',
  'right',
  'dig',
  'forward',
  'right',
  'dig',
  'forward',
  'digDown',
  'down',
  'right',
  'dig',
  'forward',
  'right',
  'dig',
  'forward',
  'right',
  'dig',
  'forward'
})
