{
  config,
  lib,
  username,
  ...
}:

{
  options.myModules.server.enable = lib.mkEnableOption "Headless server access: SSH daemon, authorized key, and full terminfo";

  config = lib.mkIf config.myModules.server.enable {
    services.openssh.enable = true;

    users.users.${username}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgFb4IhrRpB7RLRqgsi9rfVGklEg62FUAtPj+V4Ib+B"
    ];

    # Install terminfo entries for all packaged terminal emulators so SSH
    # sessions from any client render correctly. A headless host normally
    # wouldn't pull in these entries since no terminal emulators are installed.
    environment.enableAllTerminfo = true;
  };
}
