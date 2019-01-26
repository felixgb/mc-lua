filler = loadfile('filler.lua')()

function print_block(block)
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
    dig = function() commands[#commands + 1] = 'dig'; return true end
  }
  f()
  assert_commands(expected_commands, commands)
end

function test_turn_south()
  local test = function()
    mover = filler.make_cardinal_mover()
    mover.turn_towards(dir.south)
  end
  local expected = {
    'right',
    'right'
  }

  test_with_turtle(test, expected)
end

function test_turn_north()
  local test = function()
    mover = filler.make_cardinal_mover()
    mover.turn_towards(dir.north)
  end
  local expected = {}
  test_with_turtle(test, expected)
end

function test_dig_move_south()
  local test = function()
    mover = filler.make_cardinal_mover()
    filler.dig_move(mover, dir.south)
  end
  local expected = {
    'right',
    'right',
    'forward'
  }

  test_with_turtle(test, expected)
end

function test_dig_move_dirt()
  local test = function()
    turtle.forward = function() commands[#commands + 1] = 'forward'; return false end
    mover = filler.make_cardinal_mover()
    filler.dig_move(mover, dir.south)
  end
  local expected = {
    'right',
    'right',
    'forward',
    'dig'
  }

  test_with_turtle(test, expected)
end

function test_ff(map, expected)
  local test = function()
    local b = parse_block(map)
    mover = filler.make_cardinal_mover()
    filler.flood_fill_3d(b, '.', 'x')
  end

  test_with_turtle(test, expected)
end

test_turn_north()
test_turn_south()
test_dig_move_south()
test_dig_move_dirt()
test_ff(
[[
...
###
###
]],
{
  'right',
  'forward',
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
  'forward',
  'forward',
  'right',
  'forward',
  'forward'
})
