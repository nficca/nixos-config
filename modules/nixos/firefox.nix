{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.firefox;

  firefox-profile-handler = pkgs.writeShellApplication {
    name = "firefox-profile-handler";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      URL="''${1:-}"
      FIREFOX_ARGS=()

      if LAST_PID=$(niri msg -j windows 2>/dev/null \
        | jq -r '
            [.[] | select(.app_id == "firefox")]
            | sort_by(.focus_timestamp.secs, .focus_timestamp.nanos)
            | last
            | .pid // empty
          ' 2>/dev/null); then
        if [ -n "$LAST_PID" ] && [ -f "/proc/$LAST_PID/cmdline" ]; then
          PROFILE=$(tr '\0' '\n' < "/proc/$LAST_PID/cmdline" | { grep -A1 '^-P$' || true; } | tail -n1)
          if [ -n "$PROFILE" ] && [ "$PROFILE" != "-P" ]; then
            FIREFOX_ARGS+=(-P "$PROFILE")
          fi
        fi
      fi

      [ -n "$URL" ] && FIREFOX_ARGS+=("$URL")
      exec firefox "''${FIREFOX_ARGS[@]}"
    '';
  };
in
{
  options.myModules.firefox = {
    enable = lib.mkEnableOption "Firefox browser via nixpkgs with a work-profile launcher";

    profileHandler.enable = lib.mkEnableOption ''
      a URL handler that opens links in the most recently focused Firefox profile.
      Requires niri as the compositor (uses `niri msg` to query window focus).
    '';
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home-manager.users.${username} =
        { config, ... }:
        {
          programs.firefox = {
            enable = true;
            # Adopt the stateVersion 26.05 default ahead of the bump. Profile
            # data was moved from ~/.mozilla/firefox to this path by hand;
            # Firefox (147+) reads the XDG path when ~/.mozilla/firefox is
            # absent, regardless of the wrapper's MOZ_LEGACY_PROFILES=1.
            configPath = "${config.xdg.configHome}/mozilla/firefox";
          };

          xdg.desktopEntries.firefox-work = {
            name = "Firefox (Work)";
            exec = "firefox -P work";
            icon = "firefox";
            type = "Application";
            categories = [
              "Network"
              "WebBrowser"
            ];
          };
        };
    })

    (lib.mkIf cfg.profileHandler.enable {
      home-manager.users.${username} = {
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "x-scheme-handler/http" = "firefox-profile-handler.desktop";
            "x-scheme-handler/https" = "firefox-profile-handler.desktop";
          };
        };

        xdg.desktopEntries.firefox-profile-handler = {
          name = "Firefox Profile Handler";
          exec = "${firefox-profile-handler}/bin/firefox-profile-handler %u";
          type = "Application";
          noDisplay = true;
          mimeType = [
            "x-scheme-handler/http"
            "x-scheme-handler/https"
          ];
        };
      };
    })
  ];
}
