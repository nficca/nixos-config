# Firefox on Darwin. The browser comes from a homebrew cask; Home Manager owns
# profiles.ini so the default and work profiles are declared the same way as on
# NixOS. Extensions and browsing data come from Firefox Sync rather than this
# module, so a fresh machine only needs a Sync sign-in per profile.
{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.firefox;

  firefoxApp = "/Applications/Firefox.app";

  profiles = {
    "Firefox (Personal)" = "default";
    "Firefox (Work)" = "work";
  };

  # macOS has no .desktop files, so each profile gets a launcher .app bundle.
  # `open -n` is what forces a second Firefox process; without it LaunchServices
  # only activates whichever instance is already running.
  profileApps = pkgs.runCommand "firefox-profile-apps" { } (
    lib.concatStrings (
      lib.mapAttrsToList (
        appName: profile:
        let
          # A /bin/sh shebang rather than writeShellScript keeps the bundle free
          # of store references, so it still works once copied to ~/Applications.
          launcher = pkgs.writeText "launcher" ''
            #!/bin/sh
            exec /usr/bin/open -n -a ${firefoxApp} --args -P ${profile} "$@"
          '';

          infoPlist = pkgs.writeText "Info.plist" ''
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
              <key>CFBundleExecutable</key>
              <string>launcher</string>
              <key>CFBundleIconFile</key>
              <string>firefox</string>
              <key>CFBundleIdentifier</key>
              <string>com.nficca.firefox-${profile}</string>
              <key>CFBundleName</key>
              <string>${appName}</string>
              <key>CFBundlePackageType</key>
              <string>APPL</string>
            </dict>
            </plist>
          '';
        in
        ''
          contents="$out/Applications/${appName}.app/Contents"
          mkdir -p "$contents/MacOS" "$contents/Resources"
          cp ${infoPlist} "$contents/Info.plist"
          install -m555 ${launcher} "$contents/MacOS/launcher"
        ''
      ) profiles
    )
  );
in
{
  options.myModules.firefox.enable = lib.mkEnableOption "Firefox via homebrew cask with declarative default and work profiles";

  config = lib.mkIf cfg.enable {
    homebrew.casks = [ "firefox" ];

    # Takes the Home Manager scope's lib; lib.hm is not on the nix-darwin one.
    home-manager.users.${username} =
      { lib, ... }:
      {
        programs.firefox = {
          enable = true;

          # Firefox comes from the cask; Home Manager only owns the profiles.
          package = null;

          profiles = {
            default = {
              id = 0;
              path = "default";
              isDefault = true;
            };
            work = {
              id = 1;
              path = "work";
            };
          };
        };

        home.activation.firefoxProfileApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p "$HOME/Applications"

          for app in ${profileApps}/Applications/*.app; do
            dest="$HOME/Applications/$(basename "$app")"
            run rm -rf "$dest"
            run cp -R "$app" "$dest"
            run chmod -R u+w "$dest"

            # Borrow the cask's icon; skipped where the cask has not landed yet.
            if [ -f ${firefoxApp}/Contents/Resources/firefox.icns ]; then
              run cp ${firefoxApp}/Contents/Resources/firefox.icns \
                "$dest/Contents/Resources/firefox.icns"
            fi
          done
        '';
      };
  };
}
