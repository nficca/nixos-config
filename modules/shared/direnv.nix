{
  config,
  lib,
  username,
  mkRepoSymlink,
  ...
}:

let
  cfg = config.myModules.direnv;
in
{
  options.myModules.direnv.enable = lib.mkEnableOption "direnv with config";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        programs.direnv.enable = true;

        # nix-direnv caches the evaluated dev shell in .direnv/ and pins a GC
        # root, so `use flake` neither re-evaluates on every cd nor gets swept
        # by nix-collect-garbage.
        programs.direnv.nix-direnv.enable = true;

        # Symlink only direnv.toml, not the whole config dir: nix-direnv has
        # home-manager place lib/hm-nix-direnv.sh under ~/.config/direnv, which
        # it cannot do when that dir is itself an out-of-store symlink.
        xdg.configFile."direnv/direnv.toml".source =
          mkRepoSymlink config "dotfiles/direnv/direnv.toml";

        # direnv stdlib hook that loads a project's gitignored flake dev-shell.
        xdg.configFile."direnv/lib/zz-flake-env.sh".source =
          mkRepoSymlink config "dotfiles/direnv/lib/zz-flake-env.sh";
      };
  };
}
