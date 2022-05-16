#!test/bats/bin/bats
# shellcheck disable=SC2239,SC1091
#############################################################################
# Unit tests for ekko
#----------------------------------------------------------------------------

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  source "$DIR/../bin/ekko.sh"
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
  assert_output "$(echo -e $'\e[1m\e[36mHello\e[22m\e[36m world\e[0m')"
  run ekko msg1 Hello world
  assert_output "$(echo -e $'\e[1m\e[36mHello\e[22m\e[36m world\e[0m')"
  run ekko msg2 Hello world
  assert_output "$(echo -e $'\e[1m\e[94mHello\e[22m\e[94m world\e[0m')"
  run ekko msg3 Hello world
  assert_output "$(echo -e $'\e[1m\e[95mHello\e[22m\e[95m world\e[0m')"
  run ekko error Hello world
  assert_output "$(echo -e $'\e[1m\e[31mHello\e[22m\e[31m world\e[0m')"
  run ekko warn Hello world
  assert_output "$(echo -e $'\e[1m\e[33mHello\e[22m\e[33m world\e[0m')"
  run ekko ok Hello world
  assert_output "$(echo -e $'\e[1m\e[32mHello\e[22m\e[32m world\e[0m')"
  run ekko bold Hello world
  assert_output "$(echo -e $'\e[1mHello\e[22m world\e[0m')"
  run ekko b Hello world
  assert_output "$(echo -e $'\e[1mHello\e[22m world\e[0m')"
}

@test "Echo a simple message with quoted bold" {
  run ekko msg "Hey there" world
  assert_output "$(echo -e $'\e[1m\e[36mHey there\e[22m\e[36m world\e[0m')"
  run ekko msg1 "Hey there" world
  assert_output "$(echo -e $'\e[1m\e[36mHey there\e[22m\e[36m world\e[0m')"
  run ekko msg2 "Hey there" world
  assert_output "$(echo -e $'\e[1m\e[94mHey there\e[22m\e[94m world\e[0m')"
  run ekko msg3 "Hey there" world
  assert_output "$(echo -e $'\e[1m\e[95mHey there\e[22m\e[95m world\e[0m')"
  run ekko error "Hey there" world
  assert_output "$(echo -e $'\e[1m\e[31mHey there\e[22m\e[31m world\e[0m')"
  run ekko warn "Hey there" world
  assert_output "$(echo -e $'\e[1m\e[33mHey there\e[22m\e[33m world\e[0m')"
  run ekko ok "Hey there" world
  assert_output "$(echo -e $'\e[1m\e[32mHey there\e[22m\e[32m world\e[0m')"
  run ekko bold "Hey there" world
  assert_output "$(echo -e $'\e[1mHey there\e[22m world\e[0m')"
  run ekko b "Hey there" world
  assert_output "$(echo -e $'\e[1mHey there\e[22m world\e[0m')"
}

@test "Echo a simple message with no bold" {
  run ekko msg "" Hello world
  assert_output "$(echo -e $'\e[1m\e[36m\e[22m\e[36mHello world\e[0m')"
  run ekko msg1 "" Hello world
  assert_output "$(echo -e $'\e[1m\e[36m\e[22m\e[36mHello world\e[0m')"
  run ekko msg2 "" Hello world
  assert_output "$(echo -e $'\e[1m\e[94m\e[22m\e[94mHello world\e[0m')"
  run ekko msg3 "" Hello world
  assert_output "$(echo -e $'\e[1m\e[95m\e[22m\e[95mHello world\e[0m')"
  run ekko error "" Hello world
  assert_output "$(echo -e $'\e[1m\e[31m\e[22m\e[31mHello world\e[0m')"
  run ekko warn "" Hello world
  assert_output "$(echo -e $'\e[1m\e[33m\e[22m\e[33mHello world\e[0m')"
  run ekko ok "" Hello world
  assert_output "$(echo -e $'\e[1m\e[32m\e[22m\e[32mHello world\e[0m')"
  run ekko bold "" Hello world
  assert_output "$(echo -e $'\e[1m\e[22mHello world\e[0m')"
  run ekko b "" Hello world
  assert_output "$(echo -e $'\e[1m\e[22mHello world\e[0m')"
}

@test "Echo a simple message with only bold" {
  run ekko msg "Hello world"
  assert_output "$(echo -e $'\e[1m\e[36mHello world\e[0m')"
  run ekko msg1 "Hello world"
  assert_output "$(echo -e $'\e[1m\e[36mHello world\e[0m')"
  run ekko msg2 "Hello world"
  assert_output "$(echo -e $'\e[1m\e[94mHello world\e[0m')"
  run ekko msg3 "Hello world"
  assert_output "$(echo -e $'\e[1m\e[95mHello world\e[0m')"
  run ekko error "Hello world"
  assert_output "$(echo -e $'\e[1m\e[31mHello world\e[0m')"
  run ekko warn "Hello world"
  assert_output "$(echo -e $'\e[1m\e[33mHello world\e[0m')"
  run ekko ok "Hello world"
  assert_output "$(echo -e $'\e[1m\e[32mHello world\e[0m')"
  run ekko bold "Hello world"
  assert_output "$(echo -e $'\e[1mHello world\e[0m')"
  run ekko b "Hello world"
  assert_output "$(echo -e $'\e[1mHello world\e[0m')"
}

@test "Execute a command with quotes" {
  run ekko exec echo XX1
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e $'\e[100mecho XX1\e[0m')"
  assert_line --index 1 XX1
  assert_line --index 2 --partial 'echo XX1'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo XX1....$'

  run ekko exec echo \"XX2\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e $'\e[100mecho "XX2"\e[0m')"
  assert_line --index 1 XX2
  assert_line --index 2 --partial 'echo "XX2"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "XX2"....$'

  run ekko exec echo \\\"XX3\\\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e $'\e[100mecho \\"XX3\\"\e[0m')"
  assert_line --index 1 $'"XX3"'
  assert_line --index 2 --partial 'echo "XX3"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "XX3"....$'

  run ekko exec echo "\\\"XX4\\\""
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e $'\e[100mecho \\"XX4\\"\e[0m')"
  assert_line --index 1 $'"XX4"'
  assert_line --index 2 --partial 'echo "XX4"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "XX4"....$'
}

@test "Execute a command with quotes and spaces" {
  run ekko exec echo X X1
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e $'\e[100mecho X X1\e[0m')"
  assert_line --index 1 "X X1"
  assert_line --index 2 --partial 'echo X X1'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo X X1....$'

  run ekko exec echo \"X X2\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e $'\e[100mecho "X X2"\e[0m')"
  assert_line --index 1 "X X2"
  assert_line --index 2 --partial 'echo "X X2"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "X X2"....$'

  run ekko exec echo \\\"X X3\\\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e $'\e[100mecho \\"X X3\\"\e[0m')"
  assert_line --index 1 $'"X X3"'
  assert_line --index 2 --partial 'echo "X X3"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "X X3"....$'

  run ekko exec echo "\\\"X  X4\\\""
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e $'\e[100mecho \\"X  X4\\"\e[0m')"
  assert_line --index 1 $'"X X4"'
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
  assert_output "$(echo -e $'\e[1m\e[36mHello world\e[22m\e[36m -------------\e[0m')"
  run ekko banner_msg "Hello" world
  assert_output "$(echo -e $'\e[1m\e[36mHello\e[22m\e[36m world -------------\e[0m')"
  run ekko banner_msg "" Hello world
  assert_output "$(echo -e $'\e[1m\e[36m\e[22m\e[36mHello world -------------\e[0m')"
  run ekko banner_msg ""
  assert_output "$(echo -e $'\e[1m\e[36m\e[22m\e[36m-------------------------\e[0m')"
}

@test "Echo a banner message with all the colours" {
  # Pretend there are 25 columns
  function tput() { 
    echo 25
  }

  run ekko banner_msg1 "Hello" world
  assert_output "$(echo -e $'\e[1m\e[36mHello\e[22m\e[36m world -------------\e[0m')"
  run ekko banner_msg2 "Hello" world
  assert_output "$(echo -e $'\e[1m\e[94mHello\e[22m\e[94m world -------------\e[0m')"
  run ekko banner_msg3 "Hello" world
  assert_output "$(echo -e $'\e[1m\e[95mHello\e[22m\e[95m world -------------\e[0m')"
  run ekko banner_error "Hello" world
  assert_output "$(echo -e $'\e[1m\e[31mHello\e[22m\e[31m world -------------\e[0m')"
  run ekko banner_warn "Hello" world
  assert_output "$(echo -e $'\e[1m\e[33mHello\e[22m\e[33m world -------------\e[0m')"
  run ekko banner_ok "Hello" world
  assert_output "$(echo -e $'\e[1m\e[32mHello\e[22m\e[32m world -------------\e[0m')"
  run ekko banner_bold "Hello" world
  assert_output "$(echo -e $'\e[1mHello\e[22m world -------------\e[0m')"
  run ekko banner_b "Hello" world
  assert_output "$(echo -e $'\e[1mHello\e[22m world -------------\e[0m')"
}

@test "Echo a banner message with a long message" {
  # Pretend there are 25 columns
  function tput() { 
    echo 25
  }

  # A message that overruns its size (TODO)
  run ekko banner_msg "Hello world and all who inhabit it"
  assert_output "$(echo -e $'\e[1m\e[36mHello world and all who inhabit it\e[22m\e[36m ----------\e[0m')"
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
