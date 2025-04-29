#!/bin/bash

# Configuration - set your preferred package manager (npm, pnpm, or yarn)
PACKAGE_MANAGER=${PACKAGE_MANAGER:-"pnpm"}

# Create an associative array to track dynamically created commands
declare -A _npm_script_cmds

# Function to show interactive script selection
scripts() {
    if [[ ! -f package.json ]]; then
        echo "❌ No package.json found in current directory"
        return 1
    fi

    # Read scripts into an array
    readarray -t scripts < <(jq -r '.scripts | keys[]' package.json 2>/dev/null)
    
    if [[ ${#scripts[@]} -eq 0 ]]; then
        echo "❌ No scripts found in package.json"
        return 1
    fi

    echo "📦 Available ${PACKAGE_MANAGER} scripts:"
    echo "Type script name or number to run."
    echo
    
    PS3=$'\nSelect a script to run: '
    select script in "${scripts[@]}" "Cancel"; do
        case $script in
            "Cancel")
                echo "Operation cancelled"
                return 0
                ;;
            *)
                if [[ -n $script ]]; then
                    echo -e "\nRunning: ${PACKAGE_MANAGER} run $script\n"
                    $PACKAGE_MANAGER run "$script"
                    return 0
                elif [[ " ${scripts[*]} " =~ " $REPLY " ]]; then
                    echo -e "\nRunning: ${PACKAGE_MANAGER} run $REPLY\n"
                    $PACKAGE_MANAGER run "$REPLY"
                    return 0
                else
                    echo "Invalid selection. Please try again."
                fi
                ;;
        esac
    done
}

# Function to generate completions for a command
_generate_npm_script_completion() {
    local cmd=$1
    eval "_${cmd}_completion() {
        local IFS=\$'\n'
        local WORDS=(\$(jq -r '.scripts | keys[]' package.json 2>/dev/null))
        COMPREPLY=(\$(compgen -W \"\${WORDS[*]}\" -- \"\${COMP_WORDS[COMP_CWORD]}\"))
    }"
    complete -F "_${cmd}_completion" "$cmd"
}

# Function to detect package.json scripts and create commands
npm_scripts_update() {
    # Clear previous functions and completions
    for cmd in "${!_npm_script_cmds[@]}"; do
        unset -f "$cmd" 2>/dev/null
        unset "_npm_script_cmds[$cmd]"
        complete -r "$cmd" 2>/dev/null
    done

    # Check for package.json in the current directory
    if [[ -f package.json ]]; then
        # Read scripts into an array
        readarray -t scripts < <(jq -r '.scripts | keys[]' package.json 2>/dev/null)

        # Dynamically create functions and completions
        for script in "${scripts[@]}"; do
            # Skip if script name contains invalid characters
            if [[ $script =~ ^[a-zA-Z0-9_-]+$ ]]; then
                eval "function $script() { $PACKAGE_MANAGER run '$script' \"\$@\"; }"
                _npm_script_cmds[$script]=1
                _generate_npm_script_completion "$script"
            fi
        done

        # Display loaded scripts
        if [[ ${#scripts[@]} -gt 0 ]]; then
            echo "⚡ ${PACKAGE_MANAGER} scripts loaded!"
            echo "💡 Type 'scripts' to view all."
            echo
        fi
    fi
}

# Function to handle directory changes
cd() {
    builtin cd "$@" && npm_scripts_update
}

# Trigger on shell startup
npm_scripts_update
