function set_poshcontext() {
  export POSH_LOGNAME=$(logname 2>/dev/null || echo "$LOGNAME")
}