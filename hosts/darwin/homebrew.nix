# This module is intended to configure homebrew on nix-darwin systems.
#
# See the relevant options:
# https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-homebrew.enable
#
# It should be noted that this module should be included as a nix-darwin module.
# While configuring homebrew is its intended purpose, it is effectively a normal
# nix-darwin module and can configure any nix-darwin options.

{ globals, ... }:

{
  homebrew = {
    enable = true;
    user = globals.username;
    casks = [
      "google-chrome" # Web browser
      "discord" # Group chat and VoIP application
    ];
  };
}
