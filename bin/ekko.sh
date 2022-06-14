#!/usr/bin/env bash
#############################################################################
# Helpful script for echoing with colour in bash.
#
# msg: cyan
# msg2: light blue
# msg3: light magenta
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
  ekko banner_msg "Basic colour formatting"
  ekko msg ekko msg MyComponent is starting
  ekko msg2 ekko msg2 MyComponent is starting
  ekko msg3 ekko msg3 MyComponent is starting
  ekko error ekko error MyComponent aborted
  ekko warn ekko warn MyComponent is running out of space
  ekko ok ekko ok MyComponent is successful
  ekko bold ekko bold MyComponent is starting
  ekko b ekko b MyComponent is starting
  ekko banner_b ekko banner_b Prefix with "$(ekko msg3 banner_)" to fill dashes
  ekko comment_b ekko comment_b Prefix with "$(ekko msg3 comment_)" "to add comments"
  ekko comment_b_45 ekko comment_b_45 And suffix with "$(ekko msg3 _NN)" "to align comments at col NN"
  ekko

  ekko banner_msg "Environment, keys and values"
  ekko comment_b $'ekko export MY_ENV_VARIABLE \\"a value\\"' "Only echoed, not executed"
  ekko export MY_ENV_VARIABLE \"a value\"
  ekko comment_b $'ekko export PWD' "Echos current value in env"
  ekko export PWD
  ekko b ekko $'kv_12 name ekko'
  ekko kv_12 name ekko
  ekko kv_12 column 12
  ekko b ekko $'kv_45 name ekko'
  ekko kv_45 name ekko
  ekko kv_45 column 45
  ekko b ekko $'kv name ekko'
  ekko kv name ekko
  ekko kv column 30 "(default)"
  ekko

  ekko banner_msg "Execution"
  ekko comment_b $'ekko no-exec ls -d "$HOME"/Do*' "Print only"
  ekko no-exec ls -d "$HOME"/Do*
  ekko comment_b $'ekko exec ls -d "$HOME"/Do*' "Execute and timing"
  ekko exec ls -d "$HOME"/Do*
  ekko export EKKO_LAST_EXEC_TIME
  ekko

  ekko banner_msg "Notifications"
  ekko b "ekko" $'popup Splines have been reticulated'
  ekko b "ekko" $'remind $((5 * 60)) Five minute break is finished'
  ekko b "ekko" $'remind 5min Five minute break is finished'
  ekko
  ekko warn $'see ekko_help_examples for examples on using in functions'
}

function ekko_help_examples() {
  ekko banner_msg "Reading arguments"
  ekko ok $'  # Read the arguments from the command line'
  ekko b "" $'  local __x1=$1 && shift
  local __x2=$1 && shift
  local __x3=${__x3:-$1} && shift
  local __x4=$1 && shift # optional
  [ -z "$__x4" ] && __x4=X4Value'
  ekko b $'  ekko env_not_null __x1 "X1Value" \
      && ekko env_not_null __x2 "X2Value" \
      && ekko env_not_null __x3 "X3Value" \
      || return $?'
  ekko ok $'  # At this point, the argument testing succeeded.'
  ekko

  ekko banner_msg "Handling errors"
  ekko b "" $'function works() { true || { ekko error ERROR && return 1; }; ekko ok OK; }'
  ekko b "" $'function broke() { false || { ekko error ERROR && return 1; }; ekko ok OK; }'
  ekko
}

# Removes colour information from the incoming text
function ekko_uncolour() {
  # https://stackoverflow.com/a/18000433/1437593
  sed -r 's/\x1B\[(;?[0-9]{1,3})+[mGK]//g'
}

# Prints out the sixteen standard colours as the foreground.
function ekko_help_standard_foreground_sampler() {
  local __codes=(30 31 32 33 34 35 36 37
    90 91 92 93 94 95 96 97)
  local __names=(Black Red Green Yellow Blue Magenta Cyan "L gray"
    "D gray" "L red" "L green" "L yellow" "L blue" "L Magen" "L cyan" "White")
  for i in "${!__codes[@]}"; do
    echo -en "\e[${__codes[$i]}m\\\e[${__codes[$i]}m ${__names[$i]}"
    if ((i % 4 == 3)); then
      echo
    else
      echo -n $'\t'
    fi
  done
}

# Prints out help about using basic colours
function ekko_help_ansi() {
  echo -en $'\e[0m'
  ekko banner_msg $'References'
  ekko kv_6 ref https://misc.flogisoft.com/bash/tip_colors_and_formatting

  echo -e $'\e[0m'
  ekko banner_msg $'echo -e "\\\\e[39m Default"'
  ekko_help_standard_foreground_sampler

  echo -e $'\e[0m'
  ekko banner_msg $'echo -e "\\\\e[1m Bold"'
  echo -en $'\e[1m'
  ekko_help_standard_foreground_sampler

  echo -e $'\e[0m'
  ekko banner_msg $'echo -e "\\\\e[2m Dim"'
  echo -en $'\e[2m'
  ekko_help_standard_foreground_sampler

  echo -e $'\e[0m'
  ekko banner_msg $'echo -e "\\\\e[0m Reset"'
  ekko kv_24 'echo -e "\e[41m"' '\e[41mSet red backround (+10 to any colour above)'
  ekko kv_24 'echo -e "\e[1m"' '\e[1mBold'
  ekko kv_24 'echo -e "\e[2m"' '\e[2mDim'
  ekko kv_24 'echo -e "\e[4m"' '\e[4mUnderline'
  ekko kv_24 'echo -e "\e[5m"' '\e[5mBlink'
  ekko kv_24 'echo -e "\e[7m"' '\e[7mInvert background'
  ekko kv_24 'echo -e "\e[8m"' '\e[8mHIDD3N\e[0m (hidden but copyable)'
  ekko kv_24 'echo -e "\e[24m"' 'Turn off dim (+20 to any colour above)'
  ekko kv_24 'echo -e "\e[5;1;100;33m"' '\e[5;1;100;33mCombining attributes'
  ekko kv_24 'ekko_help_ansi256' 'For more information about 256 colour attributes'
}

# Prints out the advanced colours
function ekko_help_ansi256() {
  for fgbg in 38 48; do # Foreground / Background
    ekko banner_msg $'echo -e "\\\\e['"$fgbg"';5;COLm Reset"'
    for colour in {0..255}; do # Colors
      printf "\e[${fgbg};5;%sm  %3s  \e[0m" "$colour" "$colour"
      if ((colour % 8 == 7)); then
        echo
      fi
    done
    echo # New line
  done
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
  msg | msg1)
    __ekko_base_hilite_first "\e[1m\e[36m" "\e[22m\e[36m" "$@"
    ;;
  msg2)
    __ekko_base_hilite_first "\e[1m\e[94m" "\e[22m\e[94m" "$@"
    ;;
  msg3)
    __ekko_base_hilite_first "\e[1m\e[95m" "\e[22m\e[95m" "$@"
    ;;
  error)
    __ekko_base_hilite_first "\e[1m\e[31m" "\e[22m\e[31m" "$@"
    ;;
  warn)
    __ekko_base_hilite_first "\e[1m\e[33m" "\e[22m\e[33m" "$@"
    ;;
  ok)
    __ekko_base_hilite_first "\e[1m\e[32m" "\e[22m\e[32m" "$@"
    ;;
  bold | b)
    __ekko_base_hilite_first "\e[1m" "\e[22m" "$@"
    ;;
  banner_msg | banner_msg1)
    __ekko_base_banner msg "$@"
    ;;
  banner_msg2)
    __ekko_base_banner msg2 "$@"
    ;;
  banner_msg3)
    __ekko_base_banner msg3 "$@"
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
    __ekko_base_kv "${__marker#*_}" "\e[95m" "\e[39m" "$@"
    ;;
  '#' | comment)
    __ekko_base_hilite_first "\e[1m\e[90m" "\e[22m\e[90m" "# $*"
    ;;

  '#'_*_[0-9]* | comment_*_[0-9]*)
    # Drop the comment part of the marker, and extract the last argument to use as the comment
    __marker="${__marker#*_}"
    local __args=("$@")
    local __comment=${__args[-1]}
    unset '__args[-1]'

    # Format the message without the comment
    local __formatted_msg
    __formatted_msg=$(ekko "${__marker%_*}" "${__args[@]}")

    # Calculate the padding between the message and comment.
    local __padding_length=${__marker#*_}
    __padding_length=$((__padding_length - $(echo "$__formatted_msg" | ekko_uncolour | wc -c)))
    local __padding=" "
    if [ $__padding_length -gt 1 ]; then
      __padding="$(printf "%-${__padding_length}s" " ")"
    fi

    echo "$__formatted_msg$__padding$(ekko comment "$__comment")"
    ;;

  '#'_* | comment_*)
    ekko "${__marker}_0" "$@"
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
  popup)
    local __msg="$*"
    ekko exec $'notify-send Skort '"'$__msg'"$' &'
    ;;
  remind)
    local __sleep="$1" && shift
    local __msg="$*"
    # If sleep is non numeric, then try to parse it using date.
    if ! [[ $__sleep =~ ^[0-9]+$ ]]; then
      __sleep=$(date +%s -d "1970-01-01 00:00:00GMT $__sleep")
    fi
    ekko exec $'sleep '"$__sleep"$' && notify-send Skort '"'$__msg'"$' &'
    ;;
  exec)
    # Print and execute the specified command, optionally storing the time.
    echo -e "\e[100m$*\e[0m"
    # ms, remove the 3 for nanoseconds
    local __start
    __start=$(date +%s%3N)
    #eval $'bash -c "'"$*"'"'
    bash -c "$*"
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
# A simplified, degraded ANSI-coloured echo that can be used as a fallback.
# For more colours and functionality, install and source ekko.sh from
# https://github.com/RyanSkraba/ekko/

function ekko_simple() {
  local __marker=$1 && shift
  if [ "$__marker" = "exec" ]; then
    echo -e "\e[100m$*\e[0m" && bash -c "$*"
  else
    echo -e "\e[36m$*\e[0m"
  fi
}
[[ "$(type -t ekko)" == 'function' ]] || function ekko() { ekko_simple "$@"; } && export -f ekko

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

  local __length=$(( $(tput cols) - $(echo "$__first" | ekko_uncolour | wc -c) - $(echo "$__rest" | ekko_uncolour | wc -c)))
  [[ -z "$__first" ]] && __length=$((__length + 1))
  [[ -z "$__rest" ]] && __length=$((__length + 1))

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

export -f ekko ekko_uncolour __ekko_base_hilite_first __ekko_base_kv __ekko_base_banner ekko_exec_after
