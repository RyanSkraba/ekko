#!test/bats/bin/bats
# shellcheck disable=SC2239,SC1091
#############################################################################
# Unit tests for ekko
#----------------------------------------------------------------------------

__reset=$'\e[0m'     # Reset to default
__b=$'\e[1m'         # Bold intensity
__boff=$'\e[22m'     # Normal intensity, bold off
__msg1=$'\e[36m'     # Message colours
__msg2=$'\e[94m'
__msg3=$'\e[95m'
__error=$'\e[31m'
__warn=$'\e[33m'
__ok=$'\e[32m'
__exec_bg=$'\e[100m' # Command background colour
__k=$'\e[95m'        # Keys and values
__v=$'\e[39m'
__c=$'\e[90m'        # Comments


setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  source "$DIR/../bin/ekko.sh"

  # Tests the Reading arguments command from the help script
  eval "function ekko_help_reading_arguments_example() {
    $(ekko_help_examples | ekko_uncolour | sed -n -r -e '/^Reading arguments -----/,/^$/p' | sed $'1d')
    echo :\$__x1: :\$__x2: :\$__x3: :\$__x4: :\$__x5:
  }"

  # Tests the Handling errors command from the help script
  eval "function ekko_help_handling_errors_example() {
    $(ekko_help_examples | ekko_uncolour | sed -n -r -e '/^Handling errors -----/,/^$/p' | sed $'1d')
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
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset}")"
  run ekko msg1 Hello world
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset}")"
  run ekko msg2 Hello world
  assert_output "$(echo -e "${__b}${__msg2}Hello${__boff}${__msg2} world${__reset}")"
  run ekko msg3 Hello world
  assert_output "$(echo -e "${__b}${__msg3}Hello${__boff}${__msg3} world${__reset}")"
  run ekko error Hello world
  assert_output "$(echo -e "${__b}${__error}Hello${__boff}${__error} world${__reset}")"
  run ekko warn Hello world
  assert_output "$(echo -e "${__b}${__warn}Hello${__boff}${__warn} world${__reset}")"
  run ekko ok Hello world
  assert_output "$(echo -e "${__b}${__ok}Hello${__boff}${__ok} world${__reset}")"
  run ekko bold Hello world
  assert_output "$(echo -e "${__b}Hello${__boff} world${__reset}")"
  run ekko b Hello world
  assert_output "$(echo -e "${__b}Hello${__boff} world${__reset}")"
}

@test "Echo a simple message with quoted bold" {
  run ekko msg "Hey there" world
  assert_output "$(echo -e "${__b}${__msg1}Hey there${__boff}${__msg1} world${__reset}")"
  run ekko msg1 "Hey there" world
  assert_output "$(echo -e "${__b}${__msg1}Hey there${__boff}${__msg1} world${__reset}")"
  run ekko msg2 "Hey there" world
  assert_output "$(echo -e "${__b}${__msg2}Hey there${__boff}${__msg2} world${__reset}")"
  run ekko msg3 "Hey there" world
  assert_output "$(echo -e "${__b}${__msg3}Hey there${__boff}${__msg3} world${__reset}")"
  run ekko error "Hey there" world
  assert_output "$(echo -e "${__b}${__error}Hey there${__boff}${__error} world${__reset}")"
  run ekko warn "Hey there" world
  assert_output "$(echo -e "${__b}${__warn}Hey there${__boff}${__warn} world${__reset}")"
  run ekko ok "Hey there" world
  assert_output "$(echo -e "${__b}${__ok}Hey there${__boff}${__ok} world${__reset}")"
  run ekko bold "Hey there" world
  assert_output "$(echo -e "${__b}Hey there${__boff} world${__reset}")"
  run ekko b "Hey there" world
  assert_output "$(echo -e "${__b}Hey there${__boff} world${__reset}")"
}

@test "Echo a simple message with no bold" {
  run ekko msg "" Hello world
  assert_output "$(echo -e "${__b}${__msg1}${__boff}${__msg1}Hello world${__reset}")"
  run ekko msg1 "" Hello world
  assert_output "$(echo -e "${__b}${__msg1}${__boff}${__msg1}Hello world${__reset}")"
  run ekko msg2 "" Hello world
  assert_output "$(echo -e "${__b}${__msg2}${__boff}${__msg2}Hello world${__reset}")"
  run ekko msg3 "" Hello world
  assert_output "$(echo -e "${__b}${__msg3}${__boff}${__msg3}Hello world${__reset}")"
  run ekko error "" Hello world
  assert_output "$(echo -e "${__b}${__error}${__boff}${__error}Hello world${__reset}")"
  run ekko warn "" Hello world
  assert_output "$(echo -e "${__b}${__warn}${__boff}${__warn}Hello world${__reset}")"
  run ekko ok "" Hello world
  assert_output "$(echo -e "${__b}${__ok}${__boff}${__ok}Hello world${__reset}")"
  run ekko bold "" Hello world
  assert_output "$(echo -e "${__b}${__boff}Hello world${__reset}")"
  run ekko b "" Hello world
  assert_output "$(echo -e "${__b}${__boff}Hello world${__reset}")"
}

@test "Echo a simple message with only bold" {
  run ekko msg "Hello world"
  assert_output "$(echo -e "${__b}${__msg1}Hello world${__reset}")"
  run ekko msg1 "Hello world"
  assert_output "$(echo -e "${__b}${__msg1}Hello world${__reset}")"
  run ekko msg2 "Hello world"
  assert_output "$(echo -e "${__b}${__msg2}Hello world${__reset}")"
  run ekko msg3 "Hello world"
  assert_output "$(echo -e "${__b}${__msg3}Hello world${__reset}")"
  run ekko error "Hello world"
  assert_output "$(echo -e "${__b}${__error}Hello world${__reset}")"
  run ekko warn "Hello world"
  assert_output "$(echo -e "${__b}${__warn}Hello world${__reset}")"
  run ekko ok "Hello world"
  assert_output "$(echo -e "${__b}${__ok}Hello world${__reset}")"
  run ekko bold "Hello world"
  assert_output "$(echo -e "${__b}Hello world${__reset}")"
  run ekko b "Hello world"
  assert_output "$(echo -e "${__b}Hello world${__reset}")"
}

@test "Execute a command with quotes" {
  run ekko exec echo XX1
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "${__exec_bg}echo XX1${__reset}")"
  assert_line --index 1 XX1
  assert_line --index 2 --partial 'echo XX1'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo XX1....$'

  run ekko exec echo \"XX2\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "${__exec_bg}echo \"XX2\"${__reset}")"
  assert_line --index 1 XX2
  assert_line --index 2 --partial 'echo "XX2"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "XX2"....$'

  run ekko exec echo \\\"XX3\\\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "${__exec_bg}echo \\\"XX3\\\"${__reset}")"
  assert_line --index 1 $'"XX3"'
  assert_line --index 2 --partial 'echo "XX3"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "XX3"....$'

  run ekko exec echo "\\\"XX4\\\""
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "${__exec_bg}echo \\\"XX4\\\"${__reset}")"
  assert_line --index 1 $'"XX4"'
  assert_line --index 2 --partial 'echo "XX4"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "XX4"....$'
}

@test "Execute a command with quotes and spaces" {
  run ekko exec echo X X1
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "${__exec_bg}echo X X1${__reset}")"
  assert_line --index 1 "X X1"
  assert_line --index 2 --partial 'echo X X1'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo X X1....$'

  run ekko exec echo \"X X2\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "${__exec_bg}echo \"X X2\"${__reset}")"
  assert_line --index 1 "X X2"
  assert_line --index 2 --partial 'echo "X X2"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "X X2"....$'

  run ekko exec echo \\\"X X3\\\"
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "${__exec_bg}echo \\\"X X3\\\"${__reset}")"
  assert_line --index 1 '"X X3"'
  assert_line --index 2 --partial 'echo "X X3"'
  assert_line --index 2 --regexp $'^..95mTIME: ..39m[0-9]+ \([0-9:\.]+\) echo "X X3"....$'

  run ekko exec echo "\\\"X  X4\\\""
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "${__exec_bg}echo \\\"X  X4\\\"${__reset}")"
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
  assert_output "$(echo -e "${__b}${__msg1}Hello world${__boff}${__msg1} -------------${__reset}")"
  run ekko banner_msg "Hello" world
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world -------------${__reset}")"
  run ekko banner_msg "" Hello world
  assert_output "$(echo -e "${__b}${__msg1}${__boff}${__msg1}Hello world -------------${__reset}")"
  run ekko banner_msg ""
  assert_output "$(echo -e "${__b}${__msg1}${__boff}${__msg1}-------------------------${__reset}")"
}

@test "Echo a banner message with all the colours" {
  # Pretend there are 25 columns
  function tput() { 
    echo 25
  }

  run ekko banner_msg1 "Hello" world
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world -------------${__reset}")"
  run ekko banner_msg2 "Hello" world
  assert_output "$(echo -e "${__b}${__msg2}Hello${__boff}${__msg2} world -------------${__reset}")"
  run ekko banner_msg3 "Hello" world
  assert_output "$(echo -e "${__b}${__msg3}Hello${__boff}${__msg3} world -------------${__reset}")"
  run ekko banner_error "Hello" world
  assert_output "$(echo -e "${__b}${__error}Hello${__boff}${__error} world -------------${__reset}")"
  run ekko banner_warn "Hello" world
  assert_output "$(echo -e "${__b}${__warn}Hello${__boff}${__warn} world -------------${__reset}")"
  run ekko banner_ok "Hello" world
  assert_output "$(echo -e "${__b}${__ok}Hello${__boff}${__ok} world -------------${__reset}")"
  run ekko banner_bold "Hello" world
  assert_output "$(echo -e "${__b}Hello${__boff} world -------------${__reset}")"
  run ekko banner_b "Hello" world
  assert_output "$(echo -e "${__b}Hello${__boff} world -------------${__reset}")"
}

@test "Echo a banner message with a long message" {
  # Pretend there are 25 columns
  function tput() { 
    echo 25
  }

  # No text at all gives it as a bold line
  run ekko banner_msg
  assert_output "$(echo -e "${__b}${__msg1}-------------------------${__reset}")"

  # An empty text is a plain line
  run ekko banner_msg ""
  assert_output "$(echo -e "${__b}${__msg1}${__boff}${__msg1}-------------------------${__reset}")"
  # TODO
  # run ekko banner_msg "" ""

  # Three less than the number of columns
  run ekko banner_msg "abcdefghijklmnopqrstuv"
  assert_output "$(echo -e "${__b}${__msg1}abcdefghijklmnopqrstuv${__boff}${__msg1} --${__reset}")"

  # Two less than the number of columns
  run ekko banner_msg "abcdefghijklmnopqrstuvw"
  assert_output "$(echo -e "${__b}${__msg1}abcdefghijklmnopqrstuvw${__boff}${__msg1} -${__reset}")"

  # One less than the number of columns
  run ekko banner_msg "abcdefghijklmnopqrstuvwx"
  assert_equal ${#lines[@]} 2
  assert_line --index 0 "$(echo -e "${__b}${__msg1}abcdefghijklmnopqrstuvwx${__reset}")"
  assert_line --index 1 "$(echo -e "${__b}${__msg1}${__boff}${__msg1}-------------------------${__reset}")"

  # The exact number of columns
  run ekko banner_msg "abcdefghijklmnopqrstuvwxy"
  assert_equal ${#lines[@]} 2
  assert_line --index 0 "$(echo -e "${__b}${__msg1}abcdefghijklmnopqrstuvwxy${__reset}")"
  assert_line --index 1 "$(echo -e "${__b}${__msg1}${__boff}${__msg1}-------------------------${__reset}")"

  # One more than the number of columns
  run ekko banner_msg "abcdefghijklmnopqrstuvwxyz"
  assert_equal ${#lines[@]} 2
  assert_line --index 0 "$(echo -e "${__b}${__msg1}abcdefghijklmnopqrstuvwxyz${__reset}")"
  assert_line --index 1 "$(echo -e "${__b}${__msg1}${__boff}${__msg1}-------------------------${__reset}")"
}

@test "Echo exports" {
  export EKKO_VAR1=var1
  run ekko export EKKO_VAR1
  assert_output "$(echo -e "${__reset}export ${__b}${__k}EKKO_VAR1${__reset}=${__b}${__msg1}var1${__reset}")"
  run ekko export EKKO_VAR1 ""
  assert_output "$(echo -e "${__reset}export ${__b}${__k}EKKO_VAR1${__reset}=${__b}${__msg1}var1${__reset}")"
  run ekko export EKKO_VAR1 "VAR1"
  assert_output "$(echo -e "${__reset}export ${__b}${__k}EKKO_VAR1${__reset}=${__b}${__msg1}VAR1${__reset}")"
}

@test "Echo export lists" {
  export EKKO_VAR1=var1
  export EKKO_VAR2="var2 var3"
  run ekko exports EKKO_VAR1
  assert_output "$(echo -e "${__reset}export ${__b}${__k}EKKO_VAR1${__reset}=${__b}${__msg1}var1${__reset}")"
  run ekko exports EKKO_VAR1 EKKO_VAR2
  assert_equal ${#lines[@]} 2
  assert_line --index 0 "$(echo -e "${__reset}export ${__b}${__k}EKKO_VAR1${__reset}=${__b}${__msg1}var1${__reset}")"
  # TODO: Quotes?
  assert_line --index 1 "$(echo -e "${__reset}export ${__b}${__k}EKKO_VAR2${__reset}=${__b}${__msg1}var2 var3${__reset}")"
}

@test "Echo keys and values" {
  run ekko kv Hello kv
  assert_output "$(echo -e "${__k}                         Hello: ${__v}kv${__reset}")"
  run ekko kv_0 Hello kv_0
  assert_output "$(echo -e "${__k}Hello: ${__v}kv_0${__reset}")"
  run ekko kv_1 Hello kv_1
  assert_output "$(echo -e "${__k}Hello: ${__v}kv_1${__reset}")"
  run ekko kv_2 Hello kv_2
  assert_output "$(echo -e "${__k}Hello: ${__v}kv_2${__reset}")"
  run ekko kv_5 Hello kv_5
  assert_output "$(echo -e "${__k}Hello: ${__v}kv_5${__reset}")"
  run ekko kv_6 Hello kv_6
  assert_output "$(echo -e "${__k} Hello: ${__v}kv_6${__reset}")"
  run ekko kv_7 Hello kv_7
  assert_output "$(echo -e "${__k}  Hello: ${__v}kv_7${__reset}")"
  run ekko kv " " kv
  assert_output "$(echo -e "${__k}                              : ${__v}kv${__reset}")"
  run ekko kv "" kv
  assert_output "$(echo -e "${__k}                                ${__v}kv${__reset}")"
}

@test "Echo keys and values lists" {
  run ekko kvs Hello kvs
  assert_output "$(echo -e "${__k}Hello: ${__v}kvs${__reset}")"
  run ekko kvs Hello kvs "How are" you
  assert_equal ${#lines[@]} 2
  assert_line --index 0 "$(echo -e "${__k}  Hello: ${__v}kvs${__reset}")"
  assert_line --index 1 "$(echo -e "${__k}How are: ${__v}you${__reset}")"
  run ekko kvs Hello kvs "How are" you today
  assert_equal ${#lines[@]} 3
  assert_line --index 0 "$(echo -e "${__k}  Hello: ${__v}kvs${__reset}")"
  assert_line --index 1 "$(echo -e "${__k}How are: ${__v}you${__reset}")"
  assert_line --index 2 "$(echo -e "${__k}  today: ${__v}${__reset}")"
  run ekko kvs a b c
  assert_equal ${#lines[@]} 2
  assert_line --index 0 "$(echo -e "${__k}    a: ${__v}b${__reset}")"
  assert_line --index 1 "$(echo -e "${__k}    c: ${__v}${__reset}")"
  run ekko kvs a b "" c
  assert_equal ${#lines[@]} 2
  assert_line --index 0 "$(echo -e "${__k}    a: ${__v}b${__reset}")"
  assert_line --index 1 "$(echo -e "${__k}       ${__v}c${__reset}")"
}

@test "Echo test comments" {
  run ekko comment Hello comment
  assert_output "$(echo -e "${__b}${__c}# Hello comment${__reset}")"
  run ekko \# Hello \#
  assert_output "$(echo -e "${__b}${__c}# Hello #${__reset}")"
}

@test "Echo test comments on formatted messages" {
  run ekko comment_msg Hello world COMMENT
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset} ${__b}${__c}# COMMENT${__reset}")"
  run ekko \#_msg Hello world \#_msg
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset} ${__b}${__c}# #_msg${__reset}")"
  
  # Ignore the column parameter when it's smaller than the formatted message
  run ekko \#_msg_0 Hello world \#_msg_0
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset} ${__b}${__c}# #_msg_0${__reset}")"
  run ekko \#_msg_1 Hello world \#_msg_1
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset} ${__b}${__c}# #_msg_1${__reset}")"
  run ekko \#_msg_2 Hello world \#_msg_2
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset} ${__b}${__c}# #_msg_2${__reset}")"
  run ekko \#_msg_12 Hello world \#_msg_12
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset} ${__b}${__c}# #_msg_12${__reset}")"

  # Also ignore when the column parameter is already aligned 
  # (Hello world is 12 characters plus the space)
  run ekko \#_msg_13 Hello world \#_msg_13
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset} ${__b}${__c}# #_msg_13${__reset}")"

  # Start adding spaces when necessary
  run ekko \#_msg_14 Hello world \#_msg_14
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset}  ${__b}${__c}# #_msg_14${__reset}")"
  run ekko \#_msg_25 Hello world \#_msg_25
  assert_output "$(echo -e "${__b}${__msg1}Hello${__boff}${__msg1} world${__reset}             ${__b}${__c}# #_msg_25${__reset}")"
}

@test "Check help example 'Reading arguments' missing mandatory arguments" {
  run ekko_help_reading_arguments_example
  assert_failure
  assert_output  "$(echo -e "${__b}${__error}Missing argument:${__boff}${__error} <__x1> (e.g. X1Value)${__reset}")"
  run ekko_help_reading_arguments_example 1
  assert_failure
  assert_output  "$(echo -e "${__b}${__error}Missing argument:${__boff}${__error} <__x2> (e.g. X2Value)${__reset}")"
  run ekko_help_reading_arguments_example 1 2
  assert_failure
  assert_output  "$(echo -e "${__b}${__error}Missing argument:${__boff}${__error} <__x3> (e.g. X3Value)${__reset}")"
}

@test "Check help example 'Reading arguments' optional arguments" {
  run ekko_help_reading_arguments_example 1 2 3
  assert_output ":1: :2: :3: :X4Value: :X5Value:"
  run ekko_help_reading_arguments_example 1 2 3 ""
  assert_output ":1: :2: :3: :: :X5Value:"
  run ekko_help_reading_arguments_example 1 2 3 "" ""
  assert_output ":1: :2: :3: :: ::"
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output ":1: :2: :3: :4: :X5Value:"
  run ekko_help_reading_arguments_example 1 2 3 4 5
  assert_output ":1: :2: :3: :4: :5:"

  __x5=99
  run ekko_help_reading_arguments_example 1 2 3
  assert_output ":1: :2: :3: :X4Value: :99:"
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output ":1: :2: :3: :4: :99:"
  run ekko_help_reading_arguments_example 1 2 3 4 5
  assert_output ":1: :2: :3: :4: :99:"

  __x5=
  run ekko_help_reading_arguments_example 1 2 3
  assert_output ":1: :2: :3: :X4Value: ::"
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output ":1: :2: :3: :4: ::"
  run ekko_help_reading_arguments_example 1 2 3 4 5
  assert_output ":1: :2: :3: :4: ::"

  unset __x5
  run ekko_help_reading_arguments_example 1 2 3 4
}

@test "Check help example 'Reading arguments' with external variable" {
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output ":1: :2: :3: :4: :X5Value:"
  __x3=99
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output ":1: :2: :99: :4: :X5Value:"
  __x3=
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output ":1: :2: :3: :4: :X5Value:"
  unset __x3
  run ekko_help_reading_arguments_example 1 2 3 4
  assert_output ":1: :2: :3: :4: :X5Value:"
}

@test "Check help example 'Handling errors'" {
  # This declares the functions
  ekko_help_handling_errors_example
  run works
  assert_output "$(echo -e "${__b}${__ok}OK${__reset}")"
  run -1 broke
  assert_failure
  assert_output "$(echo -e "${__b}${__error}ERROR${__reset}")"
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
