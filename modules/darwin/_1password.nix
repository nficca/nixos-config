{
  config,
  lib,
  ...
}:

{
  options.myModules._1password.enable = lib.mkEnableOption "1Password GUI app via homebrew cask";

  # macOS GUI apps don't integrate well when installed via nixpkgs (Launchpad,
  # Dock, Spotlight), so 1Password is delivered as a homebrew cask.
  config = lib.mkIf config.myModules._1password.enable {
    homebrew.casks = [ "1password" ];
  };
}
