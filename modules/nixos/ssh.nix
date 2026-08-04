{
  config,
  lib,
  username,
  ...
}:

let
  cfg = config.myModules.ssh;
in
{
  options.myModules.ssh = {
    enable = lib.mkEnableOption "OpenSSH daemon with the 1Password-managed authorized key and full terminfo";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open port 22 on all interfaces. Disable on hosts reachable only over a trusted interface such as a tailnet.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;
    services.openssh.openFirewall = cfg.openFirewall;

    # Key-only auth. Both options are required: with UsePAM on, PAM still offers
    # a password prompt over keyboard-interactive when only PasswordAuthentication
    # is disabled, so the account password stays reachable over the network.
    # See: https://www.baeldung.com/linux/ssh-login-passwordauthentication-setting
    services.openssh.settings.PasswordAuthentication = false;
    services.openssh.settings.KbdInteractiveAuthentication = false;

    # One key per device rather than one shared key, so a lost device is revoked
    # by deleting its line here instead of rotating everywhere.
    users.users.${username}.openssh.authorizedKeys.keys = [
      # Available via 1Password SSH agent (desktop).
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgFb4IhrRpB7RLRqgsi9rfVGklEg62FUAtPj+V4Ib+B 1Password agent (Mac)"
      # Available in Termius (mobile).
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbRrqbg/HkXEUQiNt+nJAadTLu5akQWcw5dM+LJbfGz Termius (iPhone)"
    ];

    # Install terminfo entries for all packaged terminal emulators so SSH
    # sessions from any client render correctly, even when that client's
    # terminal emulator isn't installed on this host.
    environment.enableAllTerminfo = true;
  };
}
