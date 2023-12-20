# zsh-cmd-time
Output `cmd-time: ?.??????` after command completes,
and export variables for zsh prompt:
*   ZSH_CMD_TIME_SECONDS:   Seconds with decimals, e.g.: `3701.103709`
*   ZSH_CMD_TIME_DECORATE:  Decorated time, e.g.: `1:07:59.103709`, `1:01.0203`, `0:0182545`
*   ZSH_CMD_TIME_COLOR:     Highlight of decorated time.

**Attention: Time is not precise!** for reference only.

## Configuration
You can override defaults in `.zshrc`:
```bash
# Exclude commands, default is: ()
ZSH_CMD_TIME_EXCLUDE=(vim watch less more top my)
# Output time, default is true.
ZSH_CMD_TIME_PRINT=true
# Highlight of decorated time, set to "" for disable output.
ZSH_CMD_TIME_HL="black"
# Range for differ highlight, -1 represents infinity.
ZSH_CMD_TIME_RANGE=(0.2 1.0 3.0 -1)
# Highlight of each range, set to "" for disable output in segment.
ZSH_CMD_TIME_RANGE_HL=("black" "green" "yellow" "red")
```

## Customization
You can customize view of the plugin by redefinition of function `zsh_cmd_time`. 
There is an example:
```bash
zsh_cmd_time() {
  if ! ${ZSH_CMD_TIME_PRINT:-true}; then
    return
  fi
  if [ -n "$ZSH_CMD_TIME_DECORATE" ]; then
    print -P "%F{$ZSH_CMD_TIME_COLOR}cmd-time: %f$ZSH_CMD_TIME_DECORATE"
  fi
}
```

