{
  config,
  lib,
  pkgs,
  username,
  # mkRepoSymlink,
  ...
}:

let
  cfg = config.myModules.opencode;

  # Turns the vault item into one `export NAME=value` per field, so declaring a
  # variable there is the whole job. Anything that goes wrong, a missing token, no
  # network, no such item, resolves to an empty string: the variables stay unset
  # and the launch carries on.
  exportAgentEnvironment = ''
    eval "$(op item get Environment --vault Agent --format json 2>/dev/null \
      | jq -r '.fields[] | select(.value and .label != "notesPlain") | "export \(.label)=\(.value|@sh)"' 2>/dev/null)"
  '';
in
{
  options.myModules.opencode.enable = lib.mkEnableOption "Open-source AI coding agent for the terminal";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        # I have a 1Password service account I give agents access to so they can
        # use the `op` CLI to easily access any thing in the Agent vault.
        home.packages = [
          (pkgs.symlinkJoin {
            name = "opencode";
            paths = [ pkgs.opencode ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/opencode \
                --set OP_BIOMETRIC_UNLOCK_ENABLED false \
                --prefix PATH : ${
                  lib.makeBinPath [
                    pkgs._1password-cli
                    pkgs.jq
                  ]
                } \
                --run 'export OP_SERVICE_ACCOUNT_TOKEN="$(cat ~/.config/1password/agent-token 2>/dev/null)"' \
                --run ${lib.escapeShellArg exportAgentEnvironment}
            '';
          })
        ];

        # home.file.".claude/CLAUDE.md".source = mkRepoSymlink config "dotfiles/claude/CLAUDE.md";
        # home.file.".claude/settings.json".source = mkRepoSymlink config "dotfiles/claude/settings.json";
        # home.file.".claude/statusline.sh".source = mkRepoSymlink config "dotfiles/claude/statusline.sh";
      };
  };
}
