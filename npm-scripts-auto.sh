#!/bin/zsh

# Autoload the chpwd hook
autoload -U add-zsh-hook

# Associative array to track dynamically created commands
typeset -A _npm_script_cmds

# Function to detect package.json scripts and create commands
npm_scripts_update() {
  # Clear previous functions
  for cmd in "${(@k)_npm_script_cmds}"; do
    unfunction "$cmd" 2>/dev/null
    unalias "$cmd" 2>/dev/null
    unset "_npm_script_cmds[$cmd]"
  done

  # Check for package.json in the current directory
  if [[ -f package.json ]]; then
    local scripts
    # Parse scripts using jq
    scripts=("${(@f)$(jq -r '.scripts | keys[]' package.json 2>/dev/null)}")

    # Dynamically create functions
    for script in $scripts; do
      eval "
      function $script() {
        npm run $script "\$@"
      }"
      _npm_script_cmds[$script]=1
    done

     # Display loaded scripts
    if [[ ${#scripts[@]} -gt 0 ]]; then
      echo "⚡ npm scripts loaded: ${(j:, :)scripts}"
      echo
    fi
  fi
}

# Hook to trigger when changing directories
add-zsh-hook chpwd npm_scripts_update

# Trigger on shell startup
npm_scripts_update
