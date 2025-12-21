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
  local flake_output_key

  case "$(uname)" in
    Darwin)
      cmd="darwin-rebuild"
      flake_output_key="darwinConfigurations"
      hostname=$(scutil --get LocalHostName)
      ;;
    Linux)
      cmd="nixos-rebuild"
      flake_output_key="nixosConfigurations"
      hostname=$(hostname)
      ;;
    *)
      echo "Unsupported OS"
      exit 1
      ;;
  esac

  local derivation_path="${flake_output_key}.${hostname}.config.system.build.toplevel"

  echo "Rebuilding nix-system"
  echo "  hostname: ${hostname}"
  echo "  rebuild command: ${cmd} ${subcommand}"

  # Do the system rebuild.
  sudo ${cmd} ${subcommand}

  # Use nix store diff-closures to show package changes
  # See: https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-store-diff-closures
  nix store diff-closures \
    ".?ref=${last_commit}#${derivation_path}" \
    ".?ref=HEAD#${derivation_path}"
}

# Run main function
main "$@"
