#!/usr/bin/env bash

#######################################
# Rebuild NixOS/Darwin configuration
# Description:
#   TODO: Add description of what this script does
# Globals:
#   None
# Arguments:
#   None (or document your arguments here)
# Returns:
#   0 on success, non-zero on error
#######################################

# Exit on error, undefined variables, and pipe failures
# -e: Exit immediately if a command exits with a non-zero status
# -u: Treat unset variables as an error
# -o pipefail: Return value of a pipeline is the status of the last command to exit with a non-zero status
set -euo pipefail

# Uncomment for debugging (prints each command before executing)
# set -x

main() {
  local subcommand="${1:-switch}" # default to "switch"
  local last_commit=$(git log --oneline -1 | awk '{print $1}')
  
  local cmd
  local hostname

  case "$(uname)" in
    Darwin)
      cmd="darwin-rebuild"
      hostname=$(scutil --get LocalHostName)
      ;;
    Linux)
      cmd="nixos-rebuild"
      hostname=$(hostname)
      ;;
    *)
      echo "Unsupported OS"
      exit 1
      ;;
  esac

  echo "Hello from rebuild! Your hostname: ${hostname}"
  echo "We will be doing a ${cmd} ${subcommand} and comparing HEAD to ${last_commit}"
}

# Run main function
main "$@"
