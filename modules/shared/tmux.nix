{
  config,
  lib,
  username,
  ...
}:

{
  options.myModules.tmux.enable = lib.mkEnableOption "tmux terminal multiplexer";

  config = lib.mkIf config.myModules.tmux.enable {
    home-manager.users.${username} = {
      programs.tmux = {
        enable = true;
        terminal = "xterm-256color";
      };
    };
  };
}
