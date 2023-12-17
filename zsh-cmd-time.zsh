_zsh_cmd_time_preexec() {
  unset ZSH_CMD_TIME_SECONDS
  unset ZSH_CMD_TIME_DECORATE
  # Check excluded
  if [ -n "$ZSH_CMD_TIME_EXCLUDE" ]; then
    for i ($ZSH_CMD_TIME_EXCLUDE) do;
      if [ "`echo $1 | grep -c $i`" -gt 0 ]; then
        # echo "\"$i\" in exclude list match command: $1"
        return
      fi
    done
  fi
  _zsh_cmd_time_start_at=`date +"%s.%N"`
  # echo ">>> $1 start at $_zsh_cmd_time_start_at"
}

_zsh_cmd_time_precmd() {
  local end_at=`date +"%s.%N"`
  if [ -z $_zsh_cmd_time_start_at ]; then
    unset ZSH_CMD_TIME_SECONDS
    unset ZSH_CMD_TIME_DECORATE
    return
  fi
  local used=`awk "BEGIN {print $end_at - $_zsh_cmd_time_start_at}"`
  unset _zsh_cmd_time_start_at
  local used_us=`echo $used | cut -d '.' -f 2`
  local used_ss=`echo $used | cut -d '.' -f 1`
  local used_s=`expr $used_ss % 60`
  local used_m=`expr $used_ss % 3600 / 60`
  local used_h=`expr $used_ss / 3600`
  ZSH_CMD_TIME_COLOR=$ZSH_CMD_TIME_HL
  local i=0
  if [ -n "$ZSH_CMD_TIME_RANGE" ]; then
    for r in "${ZSH_CMD_TIME_RANGE[@]}"; do
      i=`expr $i + 1`
      if [ `awk "BEGIN {print $used < $r}"` -eq 1 ] || [ `awk "BEGIN {print $r < 0}"` -eq 1 ]; then
        ZSH_CMD_TIME_COLOR=${ZSH_CMD_TIME_RANGE_HL[$i]}
        break
      fi
    done
  fi
  ZSH_CMD_TIME_SECONDS=used
  if [ -n "$ZSH_CMD_TIME_COLOR" ]; then
    local str=''
    local len=1
    if [ "$used_h" -gt 0 ]; then
      str+=`printf "%d:" $used_h`
    fi
    if [ -n "$str" ]; then
      len=2
    fi
    if [ "$used_m" -gt 0 ]; then
      str+=`printf "%0*d:" $len $used_m`
    fi
    if [ -n "$str" ]; then
      len=2
    fi
    str+=`printf "%0*d.%s" $len $used_s $used_us`
    ZSH_CMD_TIME_DECORATE=`print -P "%F{$ZSH_CMD_TIME_COLOR}$str%f"`
  fi
  # echo "<<< $? end at $end_at, time used: $ZSH_CMD_TIME_SECONDS, $ZSH_CMD_TIME_DECORATE($ZSH_CMD_TIME_COLOR)"
  zsh_cmd_time
}

zsh_cmd_time() {
  if ! ${ZSH_CMD_TIME_PRINT:-true}; then
    return
  fi
  if [ -n "$ZSH_CMD_TIME_DECORATE" ]; then
    print -P "%F{$ZSH_CMD_TIME_COLOR}cmd-time: %f$ZSH_CMD_TIME_DECORATE"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _zsh_cmd_time_preexec 2> /dev/null || {
  print -r -- >&2 'zsh-command-time: failed loading add-zsh-hook.'
}
add-zsh-hook precmd _zsh_cmd_time_precmd 2> /dev/null

