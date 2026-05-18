{
  config,
  lib,
  ...
}:

{
  options.myModules.tmux.enable = lib.mkEnableOption "tmux terminal multiplexer";

  config = lib.mkIf config.myModules.tmux.enable {
    programs.tmux = {
      enable = true;
      terminal = "xterm-256color";
    };
  };
}
