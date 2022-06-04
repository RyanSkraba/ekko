#!test/bats/bin/bats
# shellcheck disable=SC2239,SC1091
#############################################################################
# Unit tests for ekko
#----------------------------------------------------------------------------

__boff=$'\e[22m' # Normal intensity, bold off

setup() {

  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  source "$DIR/../bin/ekko.sh"

  # Tests the Reading arguments command from the help script
  eval "function ekko_help_reading_arguments_example() {
    $(ekko_help_examples | ekko_uncolour | sed -n -r -e '/^Reading arguments -----/,/^$/p' | sed $'1d')
    echo \$__x1 \$__x2 \$__x3 \$__x4 
  }"

  # Tests the Handling errors command from the help script
  eval "function ekko_help_handling_errors_example() {
    $(ekko_help_examples | ekko_uncolour | sed -n -r -e '/^Handling errors -----/,/^$/p' | sed $'1d')
    echo \$__x1 \$__x2 \$__x3 \$__x4 
  }"
}

# Echos a simple, colourful script to the terminal (line by line only)
function ekko_script_help() {
  ekko banner_msg $'# Hello'
  ekko b "echo" Hello
  ekko b "" echo World
  ekko error "" ls /no-exist
  ekko b "" echo SKIPPED
}

# Executes the script line by line
function ekko_script_go() {
  while IFS= read -r __cmd; do
    ekko msg "$__cmd"
    if ekko exec "$__cmd"; then
       ekko ok Success
    else
       local __code=$?
       ekko error Error \( $__code \)
       return $__code
    fi
  done <<<"$(ekko_script_help | ekko_uncolour)"
}

@test "Echo a string without any colour" {
  run ekko Hello world
  assert_output "Hello world"
}

@test "Echo a simple message with all the colours" {
  run ekko msg Hello world
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m")"
  run ekko msg1 Hello world
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m")"
  run ekko msg2 Hello world
  assert_output "$(echo -e "\e[1m\e[94mHello${__boff}\e[94m world\e[0m")"
  run ekko msg3 Hello world
  assert_output "$(echo -e "\e[1m\e[95mHello${__boff}\e[95m world\e[0m")"
  run ekko error Hello world
  assert_output "$(echo -e "\e[1m\e[31mHello${__boff}\e[31m world\e[0m")"
  run ekko warn Hello world
  assert_output "$(echo -e "\e[1m\e[33mHello${__boff}\e[33m world\e[0m")"
  run ekko ok Hello world
  assert_output "$(echo -e "\e[1m\e[32mHello${__boff}\e[32m world\e[0m")"
  run ekko bold Hello world
  assert_output "$(echo -e "\e[1mHello${__boff} world\e[0m")"
  run ekko b Hello world
  assert_output "$(echo -e "\e[1mHello${__boff} world\e[0m")"
}

@test "Echo a simple message with quoted bold" {
  run ekko msg "Hey there" world
  assert_output "$(echo -e "\e[1m\e[36mHey there${__boff}\e[36m world\e[0m")"
  run ekko msg1 "Hey there" world
  assert_output "$(echo -e "\e[1m\e[36mHey there${__boff}\e[36m world\e[0m")"
  run ekko msg2 "Hey there" world
  assert_output "$(echo -e "\e[1m\e[94mHey there${__boff}\e[94m world\e[0m")"
  run ekko msg3 "Hey there" world
  assert_output "$(echo -e "\e[1m\e[95mHey there${__boff}\e[95m world\e[0m")"
  run ekko error "Hey there" world
  assert_output "$(echo -e "\e[1m\e[31mHey there${__boff}\e[31m world\e[0m")"
  run ekko warn "Hey there" world
  assert_output "$(echo -e "\e[1m\e[33mHey there${__boff}\e[33m world\e[0m")"
  run ekko ok "Hey there" world
  assert_output "$(echo -e "\e[1m\e[32mHey there${__boff}\e[32m world\e[0m")"
  run ekko bold "Hey there" world
  assert_output "$(echo -e "\e[1mHey there${__boff} world\e[0m")"
  run ekko b "Hey there" world
  assert_output "$(echo -e "\e[1mHey there${__boff} world\e[0m")"
}

@test "Echo a simple message with no bold" {
  run ekko msg "" Hello world
  assert_output "$(echo -e "\e[1m\e[36m${__boff}\e[36mHello world\e[0m")"
  run ekko msg1 "" Hello world
  assert_output "$(echo -e "\e[1m\e[36m${__boff}\e[36mHello world\e[0m")"
  run ekko msg2 "" Hello world
  assert_output "$(echo -e "\e[1m\e[94m${__boff}\e[94mHello world\e[0m")"
  run ekko msg3 "" Hello world
  assert_output "$(echo -e "\e[1m\e[95m${__boff}\e[95mHello world\e[0m")"
  run ekko error "" Hello world
  assert_output "$(echo -e "\e[1m\e[31m${__boff}\e[31mHello world\e[0m")"
  run ekko warn "" Hello world
  assert_output "$(echo -e "\e[1m\e[33m${__boff}\e[33mHello world\e[0m")"
  run ekko ok "" Hello world
  assert_output "$(echo -e "\e[1m\e[32m${__boff}\e[32mHello world\e[0m")"
  run ekko bold "" Hello world
  assert_output "$(echo -e "\e[1m${__boff}Hello world\e[0m")"
  run ekko b "" Hello world
  assert_output "$(echo -e "\e[1m${__boff}Hello world\e[0m")"
}

@test "Echo a simple message with only bold" {
  run ekko msg "Hello world"
  assert_output "$(echo -e "\e[1m\e[36mHello world\e[0m")"
  run ekko msg1 "Hello world"
  assert_output "$(echo -e "\e[1m\e[36mHello world\e[0m")"
  run ekko msg2 "Hello world"
  assert_output "$(echo -e "\e[1m\e[94mHello world\e[0m")"
  run ekko msg3 "Hello world"
  assert_output "$(echo -e "\e[1m\e[95mHello world\e[0m")"
  run ekko error "Hello world"
  assert_output "$(echo -e "\e[1m\e[31mHello world\e[0m")"
  run ekko warn "Hello world"
  assert_output "$(echo -e "\e[1m\e[33mHello world\e[0m")"
  run ekko ok "Hello world"
  assert_output "$(echo -e "\e[1m\e[32mHello world\e[0m")"
  run ekko bold "Hello world"
  assert_output "$(echo -e "\e[1mHello world\e[0m")"
  run ekko b "Hello world"
  assert_output "$(echo -e "\e[1mHello world\e[0m")"
}

@test "Execute a command with quotes" {
  run ekko exec echo XX1
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "\e[100mecho XX1\e[0m")"
  assert_line --index 1 XX1
  assert_line --index 2 --partial 'echo XX1'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo XX1....$'

  run ekko exec echo \"XX2\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "\e[100mecho \"XX2\"\e[0m")"
  assert_line --index 1 XX2
  assert_line --index 2 --partial 'echo "XX2"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "XX2"....$'

  run ekko exec echo \\\"XX3\\\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "\e[100mecho \\\"XX3\\\"\e[0m")"
  assert_line --index 1 $'"XX3"'
  assert_line --index 2 --partial 'echo "XX3"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "XX3"....$'

  run ekko exec echo "\\\"XX4\\\""
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "\e[100mecho \\\"XX4\\\"\e[0m")"
  assert_line --index 1 $'"XX4"'
  assert_line --index 2 --partial 'echo "XX4"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "XX4"....$'
}

@test "Execute a command with quotes and spaces" {
  run ekko exec echo X X1
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "\e[100mecho X X1\e[0m")"
  assert_line --index 1 "X X1"
  assert_line --index 2 --partial 'echo X X1'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo X X1....$'

  run ekko exec echo \"X X2\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "\e[100mecho \"X X2\"\e[0m")"
  assert_line --index 1 "X X2"
  assert_line --index 2 --partial 'echo "X X2"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "X X2"....$'

  run ekko exec echo \\\"X X3\\\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "\e[100mecho \\\"X X3\\\"\e[0m")"
  assert_line --index 1 '"X X3"'
  assert_line --index 2 --partial 'echo "X X3"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "X X3"....$'

  run ekko exec echo "\\\"X  X4\\\""
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "\e[100mecho \\\"X  X4\\\"\e[0m")"
  assert_line --index 1 '"X X4"'
  assert_line --index 2 --partial 'echo "X  X4"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "X  X4"....$'
}

@test "Echo a banner message with different types of bold" {
  # Pretend there are 25 columns
  function tput() { 
    echo 25
  }

  # Different ways of bolding the two words
  run ekko banner_msg "Hello world"
  assert_output "$(echo -e "\e[1m\e[36mHello world${__boff}\e[36m -------------\e[0m")"
  run ekko banner_msg "Hello" world
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world -------------\e[0m")"
  run ekko banner_msg "" Hello world
  assert_output "$(echo -e "\e[1m\e[36m${__boff}\e[36mHello world -------------\e[0m")"
  run ekko banner_msg ""
  assert_output "$(echo -e "\e[1m\e[36m${__boff}\e[36m-------------------------\e[0m")"
}

@test "Echo a banner message with all the colours" {
  # Pretend there are 25 columns
  function tput() { 
    echo 25
  }

  run ekko banner_msg1 "Hello" world
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world -------------\e[0m")"
  run ekko banner_msg2 "Hello" world
  assert_output "$(echo -e "\e[1m\e[94mHello${__boff}\e[94m world -------------\e[0m")"
  run ekko banner_msg3 "Hello" world
  assert_output "$(echo -e "\e[1m\e[95mHello${__boff}\e[95m world -------------\e[0m")"
  run ekko banner_error "Hello" world
  assert_output "$(echo -e "\e[1m\e[31mHello${__boff}\e[31m world -------------\e[0m")"
  run ekko banner_warn "Hello" world
  assert_output "$(echo -e "\e[1m\e[33mHello${__boff}\e[33m world -------------\e[0m")"
  run ekko banner_ok "Hello" world
  assert_output "$(echo -e "\e[1m\e[32mHello${__boff}\e[32m world -------------\e[0m")"
  run ekko banner_bold "Hello" world
  assert_output "$(echo -e "\e[1mHello${__boff} world -------------\e[0m")"
  run ekko banner_b "Hello" world
  assert_output "$(echo -e "\e[1mHello${__boff} world -------------\e[0m")"
}

@test "Echo a banner message with a long message" {
  # Pretend there are 25 columns
  function tput() { 
    echo 25
  }

  # A message that overruns its size (TODO)
  run ekko banner_msg "Hello world and all who inhabit it"
  assert_output "$(echo -e "\e[1m\e[36mHello world and all who inhabit it${__boff}\e[36m ----------\e[0m")"
}

@test "Echo keys and values" {
  run ekko kv Hello kv
  assert_output "$(echo -e "\e[95m                         Hello: \e[39mkv\e[0m")"
  run ekko kv_0 Hello kv_0
  assert_output "$(echo -e "\e[95mHello: \e[39mkv_0\e[0m")"
  run ekko kv_1 Hello kv_1
  assert_output "$(echo -e "\e[95mHello: \e[39mkv_1\e[0m")"
  run ekko kv_2 Hello kv_2
  assert_output "$(echo -e "\e[95mHello: \e[39mkv_2\e[0m")"
  # TODO: Why does 5 have a space?
  run ekko kv_6 Hello kv_5
  assert_output "$(echo -e "\e[95m Hello: \e[39mkv_5\e[0m")"
  run ekko kv_6 Hello kv_6
  assert_output "$(echo -e "\e[95m Hello: \e[39mkv_6\e[0m")"
  run ekko kv_7 Hello kv_7
  assert_output "$(echo -e "\e[95m  Hello: \e[39mkv_7\e[0m")"
}

@test "Echo test comments" {
  run ekko comment Hello comment
  assert_output "$(echo -e "\e[1m\e[90m# Hello comment\e[0m")"
  run ekko \# Hello \#
  assert_output "$(echo -e "\e[1m\e[90m# Hello #\e[0m")"
}

@test "Echo test comments on formatted messages" {
  run ekko comment_msg Hello world COMMENT
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m \e[1m\e[90m# COMMENT\e[0m")"
  run ekko \#_msg Hello world \#_msg
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m \e[1m\e[90m# #_msg\e[0m")"
  
  # Ignore the column parameter when it's smaller than the formatted message
  run ekko \#_msg_0 Hello world \#_msg_0
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m \e[1m\e[90m# #_msg_0\e[0m")"
  run ekko \#_msg_1 Hello world \#_msg_1
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m \e[1m\e[90m# #_msg_1\e[0m")"
  run ekko \#_msg_2 Hello world \#_msg_2
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m \e[1m\e[90m# #_msg_2\e[0m")"
  run ekko \#_msg_12 Hello world \#_msg_12
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m \e[1m\e[90m# #_msg_12\e[0m")"

  # Also ignore when the column parameter is already aligned 
  # (Hello world is 12 characters plus the space)
  run ekko \#_msg_13 Hello world \#_msg_13
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m \e[1m\e[90m# #_msg_13\e[0m")"

  # Start adding spaces when necessary
  run ekko \#_msg_14 Hello world \#_msg_14
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m  \e[1m\e[90m# #_msg_14\e[0m")"
  run ekko \#_msg_25 Hello world \#_msg_25
  assert_output "$(echo -e "\e[1m\e[36mHello${__boff}\e[36m world\e[0m             \e[1m\e[90m# #_msg_25\e[0m")"
}

@test "Check help example'Reading arguments' with missing arguments" {
  run ekko_help_reading_arguments_example
  assert_failure
  assert_output  "$(echo -e "\e[1m\e[31mMissing argument:${__boff}\e[31m <__x1> (e.g. X1Value)\e[0m")"
  run ekko_help_reading_arguments_example 1
  assert_failure
  assert_output  "$(echo -e "\e[1m\e[31mMissing argument:${__boff}\e[31m <__x2> (e.g. X2Value)\e[0m")"
  run ekko_help_reading_arguments_example 1 2
  assert_failure
  assert_output  "$(echo -e "\e[1m\e[31mMissing argument:${__boff}\e[31m <__x3> (e.g. X3Value)\e[0m")"
}

@test "Check help example 'Reading arguments' with external variable" {
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output "1 2 3 4"
  __x3=99
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output "1 2 99 4"
  __x3=
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output "1 2 3 4"
  unset __x3
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output "1 2 3 4"
}

@test "Check help example 'Handling errors'" {
  # This declares the functions
  ekko_help_handling_errors_example
  run works
  assert_output "$(echo -e "\e[1m\e[32mOK\e[0m")"
  run -1 broke
  assert_failure
  assert_output "$(echo -e "\e[1m\e[31mERROR\e[0m")"
}

#----------------------------------------------------------------------------
# Help for the functions in this script.
function test_ekko_exec() {
  ekko exec echo XX1
  ekko exec echo \"XX2\"
  ekko exec echo \\\"XX3\\\"
  ekko exec echo "\\\"XX4\\\""
  ekko exec echo X X1
  ekko exec echo \"X X2\"
  ekko exec echo \\\"X X3\\\"
  ekko exec echo "\\\"X  X4\\\""
  ekko exec $'echo "X  X5"'
  ekko exec $'ekko exec $\'echo "X  X6"\''

  ekko exec $'echo "X  X7" && echo "X  X8"'
  ekko exec $'echo "X  X7" && 
      echo "X  X8"'

  # This fails because it ends with a \
  # ekko exec echo \\"Fails\\"
}
