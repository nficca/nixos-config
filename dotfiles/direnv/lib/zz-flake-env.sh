# Sourced by direnv on every activated directory (it auto-loads lib/*.sh). Loads
# a project's gitignored .direnv/.flake-env so the `use flake` line is never
# committed, even in repos that track their own .env/.envrc. The zz- prefix runs
# this after nix-direnv's hm-nix-direnv.sh so `use flake` is defined when called.
#
# find_up, not a plain relative test, so the shell still loads when direnv is
# first entered from a subdirectory (there $PWD is the subdir, not the root).
if flake_env=$(find_up .direnv/.flake-env); then
  source_env "$flake_env"
fi
