#!/usr/bin/env bash
#############################################################################
# Helpful script for echoing with colour in bash.
#
# msg: cyan
# error: red
# warn: yellow
# ok: green
# kv: purple (key) and white (value)
#
# The following snippet aliases ekko to echo when this script isn't sourced:
#
# type -t ekko > /dev/null || alias ekko=echo
#
#----------------------------------------------------------------------------

# When `ekko exec` is used, sets the start time (unix epoch in ms), the wall
# time (in ms) and the last command run.

export EKKO_LAST_EXEC_START=0
export EKKO_LAST_EXEC_TIME=0
export EKKO_LAST_EXEC_CMD=0
export EKKO_LAST_EXEC_CODE=0

#----------------------------------------------------------------------------
# Help for the functions in this script.
function ekko_help() {
  ekko banner_msg "In colour with the first word highlighted."
  ekko msg ekko msg MyComponent is starting
  ekko error ekko error MyComponent aborted
  ekko warn ekko warn MyComponent is running out of space
  ekko ok ekko ok MyComponent is successful
  ekko bold ekko bold MyComponent is starting
  ekko b ekko b MyComponent is starting
  ekko banner_b ekko banner_b MyComponent is starting

  echo
  ekko banner_msg "Keys and values."
  ekko b $'ekko export MY_ENV_VARIABLE \\"a value\\"' "# Only echoed, not executed."
  ekko export MY_ENV_VARIABLE \"a value\"
  ekko b $'ekko export PWD' "# Echos current value in env."
  ekko export PWD
  ekko b ekko $'kv_12 name ekko'
  ekko kv_12 name ekko
  ekko kv_12 column 12
  ekko b ekko $'kv_45 name ekko'
  ekko kv_45 name ekko
  ekko kv_45 column 45
  ekko b ekko $'kv name ekko'
  ekko kv name ekko
  ekko kv column 30

  echo
  ekko banner_msg "Execution."
  ekko b $'ekko no-exec ls -d "$HOME"/Do*' "# Print only."
  ekko no-exec ls -d "$HOME"/Do*
  ekko b $'ekko exec ls -d "$HOME"/Do*' "# Execute and timing."
  ekko exec ls -d "$HOME"/Do*
  ekko export EKKO_LAST_EXEC_TIME

  echo
  ekko banner_msg "Reading arguments"
  ekko ok $'  # Read the arguments from the command line'
  ekko b "" $'  local __first=$1 && shift
  local __second=$1 && shift
  local __third=$1 && shift # optional
  [ -z "$__third" ] && __third=ThirdArgumentDefaultValue'
  ekko b $'  ekko env_not_null __first "FirstArgumentExampleValue" \
      && ekko env_not_null __second "SecondArgumentExampleValue" \
      || return $?'
  ekko ok $'  # At this point, the argument testing succeeded.'
  echo
}

#----------------------------------------------------------------------------
# Called after any `ekko exec` call.
function ekko_exec_after() {
  # # Persist times to a file.
  # echo "$EKKO_LAST_EXEC_CODE;$EKKO_LAST_EXEC_START;$EKKO_LAST_EXEC_TIME;$EKKO_LAST_EXEC_CMD" \
  #     >> ~/.ekko-exec.log
  true
}

#----------------------------------------------------------------------------
# Prints out pretty messages.  See ekko_help for usage.
function ekko() {
  local __all="$*"
  local __marker=$1 && shift
  case $__marker in
  msg)
    __ekko_base_hilite_first "\e[1m\e[36m" "\e[22m" "$@"
    ;;
  error)
    __ekko_base_hilite_first "\e[1m\e[31m" "\e[22m" "$@"
    ;;
  warn)
    __ekko_base_hilite_first "\e[1m\e[33m" "\e[22m" "$@"
    ;;
  ok)
    __ekko_base_hilite_first "\e[1m\e[32m" "\e[22m" "$@"
    ;;
  bold | b)
    __ekko_base_hilite_first "\e[1m" "\e[22m" "$@"
    ;;
  banner_msg)
    __ekko_base_banner msg "$@"
    ;;
  banner_error)
    __ekko_base_banner error "$@"
    ;;
  banner_warn)
    __ekko_base_banner warn "$@"
    ;;
  banner_ok)
    __ekko_base_banner ok "$@"
    ;;
  banner_b | banner_bold)
    __ekko_base_banner b "$@"
    ;;
  kv)
    __ekko_base_kv 30 "\e[95m" "\e[39m" "$@"
    ;;
  kv_*)
    __ekko_base_kv "${__marker:3}" "\e[95m" "\e[39m" "$@"
    ;;
  env_not_null)
    local __var="$1" && shift
    local __var_ex="$1" && shift
    local __var_value
    __var_value=$(eval echo \$"$__var")
    [ -z "$__var_value" ] && ekko error "Missing argument:" "<$__var> (e.g. $__var_ex)" && return 1
    return 0
    ;;
  export)
    local __env_var="$1" && shift
    local __env_val="$*"
    [ -z "$__env_val" ] && __env_val=$(eval echo \$"$__env_var")
    echo -e "\e[37mexport \e[1m\e[95m${__env_var}\e[22m\e[37m=\e[1m\e[36m${__env_val}\e[0m"
    ;;
  exec)
    # Print and execute the specified command, optionally storing the time.
    echo -e "\e[100m$*\e[0m"
    # ms, remove the 3 for nanoseconds
    local __start
    __start=$(date +%s%3N)
    eval $'bash -c "'"$*"'"'
    local __return=$?
    local __time
    __time=$(($(date +%s%3N) - __start))
    local __formatted=
    printf -v __formatted "%02d:%02d:%02d.%03d" $((__time / 3600000)) $(((__time / 60000) % 60000)) $(((__time % 60000) / 1000)) $((__time % 1000))
    ekko kv_4 TIME $__time \($__formatted\) "$@"
    export EKKO_LAST_EXEC_START=$__start
    export EKKO_LAST_EXEC_TIME=$__time
    export EKKO_LAST_EXEC_CMD=$*
    export EKKO_LAST_EXEC_CODE=$__return
    ekko_exec_after
    return $__return
    ;;
  no-exec)
    # Like exec but without actually executing.
    echo -e "\e[100m$*\e[0m"
    EKKO_LAST_EXEC_START=$(date +%s%3N)
    export EKKO_LAST_EXEC_START
    export EKKO_LAST_EXEC_TIME=0
    export EKKO_LAST_EXEC_CMD=$*
    export EKKO_LAST_EXEC_CODE=0
    ;;
  *)
    echo "$__all"
    ;;
  esac
}

#----------------------------------------------------------------------------
# Helper functions

function __ekko_base_hilite_first() {
  local __first_code=$1 && shift
  local __rest_code=$1 && shift
  local __first=$1 && shift
  local __rest="$*"
  if [[ -z "$__first" && -n "$__rest" ]]; then
    echo -e "${__first_code}${__rest_code}${__rest}\e[0m"
  elif [[ -z "$__rest" ]]; then
    echo -e "${__first_code}${__first}\e[0m"
  else
    echo -e "${__first_code}$__first${__rest_code}" "${__rest}\e[0m"
  fi
}

function __ekko_base_kv() {
  local __width=$1 && shift
  local __key_code=$1 && shift
  local __value_code=$1 && shift
  local __rest=$1 && shift
  # If the key is "", then just indent to the values.
  [ -z "$__rest" ] &&
    printf "${__key_code}%*s  ${__value_code}$*\e[0m\n" "$__width" "$__rest" ||
    printf "${__key_code}%*s: ${__value_code}$*\e[0m\n" "$__width" "$__rest"
}

function __ekko_base_banner() {
  local __marker=$1 && shift
  local __first=$1 && shift
  local __rest="$*"

  local __length=$(($(tput cols) - ${#__first} - ${#__rest}))
  [[ -n "$__first" ]] && __length=$((__length - 1))
  [[ -n "$__rest" ]] && __length=$((__length - 1))

  local __line
  __line=$(printf "%${__length}s" | tr ' ' '-')

  if [[ -z $__first && -n $__first ]]; then
    ekko "$__marker" "" "$__rest $__line"
  elif [[ -z $__rest ]]; then
    ekko "$__marker" "$__first" "$__line"
  else
    ekko "$__marker" "$__first" "$__rest $__line"
  fi
}

export -f ekko __ekko_base_hilite_first __ekko_base_kv __ekko_base_banner ekko_exec_after
