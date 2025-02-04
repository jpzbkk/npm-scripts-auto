#!/bin/zsh

# Configuration - set your preferred package manager (npm, pnpm, or yarn)
PACKAGE_MANAGER=${PACKAGE_MANAGER:-"pnpm"}

# Autoload the chpwd hook
autoload -U add-zsh-hook

# Associative array to track dynamically created commands
typeset -A _npm_script_cmds

# Function to show interactive script selection
scripts() {
    if [[ ! -f package.json ]]; then
        echo "❌ No package.json found in current directory"
        return 1
    fi

    local scripts
    scripts=("${(@f)$(jq -r '.scripts | keys[]' package.json 2>/dev/null)}")
    
    if [[ ${#scripts[@]} -eq 0 ]]; then
        echo "❌ No scripts found in package.json"
        return 1
    fi

    echo "📦 Available ${PACKAGE_MANAGER} scripts:"
    echo "Type script name or number to run. \n"
    
    PS3=$'\nSelect a script to run: '
    select script in "${scripts[@]}" "Cancel"; do
        case $script in
            "Cancel")
                echo "Operation cancelled"
                return 0
                ;;
            *)
                if [[ -n $script ]]; then
                    echo "\nRunning: ${PACKAGE_MANAGER} run $script\n"
                    $PACKAGE_MANAGER run $script
                    return 0
                fi
                ;;
        esac
    done
}

# Function to generate completions for a command
_generate_npm_script_completion() {
    local cmd=$1
    eval "_${cmd}_completion() {
        local -a commands
        commands=(\$(jq -r '.scripts | keys[]' package.json 2>/dev/null))
        _describe 'command' commands
    }"
    compdef "_${cmd}_completion" "$cmd"
}

# Function to detect package.json scripts and create commands
npm_scripts_update() {
    # Clear previous functions and completions
    for cmd in "${(@k)_npm_script_cmds}"; do
        unfunction "$cmd" 2>/dev/null
        unset "_npm_script_cmds[$cmd]"
        unfunction "_${cmd}_completion" 2>/dev/null
    done

    # Check for package.json in the current directory
    if [[ -f package.json ]]; then
        local scripts
        scripts=("${(@f)$(jq -r '.scripts | keys[]' package.json 2>/dev/null)}")

        # Dynamically create functions and completions
        for script in $scripts; do
            # Create the function
            eval "function $script() { $PACKAGE_MANAGER run $script \$@ }"
            _npm_script_cmds[$script]=1
            _generate_npm_script_completion "$script"
        done

        # Display loaded scripts
        if [[ ${#scripts[@]} -gt 0 ]]; then
            echo "⚡ ${PACKAGE_MANAGER} scripts loaded! \n💡 Type 'scripts' to view all."
            echo
        fi
    fi
}

# Hook to trigger when changing directories
add-zsh-hook chpwd npm_scripts_update

# Trigger on shell startup
npm_scripts_update
