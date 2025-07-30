{ common, pkgs, ... }:

{
  home.username = common.username;

  # Install packages
  home.packages = with pkgs; [
    claude-code # Agentic AI assistant
    jless # JSON viewer
  ];

  # Ensure homebrew is available in the PATH but at the end.
  # We prefer the binaries provided by nix over homebrew.
  programs.zsh.initContent = ''
    # Remove Homebrew from PATH and re-add it to the end.
    # This ensures that Homebrew binaries are available but do not override
    # the binaries provided by nixpkgs.
    export PATH="$(echo "$PATH" | tr ':' '\n' | grep -v '^/opt/homebrew/bin$' | grep -v '^/opt/homebrew/sbin$' | paste -sd ':' -)"
    export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
  '';
}
