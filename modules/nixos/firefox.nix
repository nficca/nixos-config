# Per-user Firefox via Home Manager with two declarative profiles (default
# and work) and an optional niri-aware link handler. Extensions and browsing
# data come from Firefox Sync rather than this module, so a fresh machine only
# needs a Sync sign-in per profile.
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
      # Open links in whichever profile you used last: ask niri for the most
      # recently focused Firefox window and reuse the `-P` it was launched with.
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
    enable = lib.mkEnableOption "Firefox via Home Manager with declarative default and work profiles";

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
            # Store profiles under the XDG path (Home Manager's 26.05 default,
            # set explicitly to silence the pre-26.05 deprecation warning).
            # Firefox uses ~/.mozilla/firefox instead whenever that directory
            # exists and shadows these profiles, so if it ever reappears, delete
            # it. The real profiles here are untouched.
            configPath = "${config.xdg.configHome}/mozilla/firefox";

            # Declared so Home Manager rewrites profiles.ini on every rebuild.
            # That keeps Firefox's Selectable Profile Service from grouping
            # these profiles behind a startup selector, since it cannot persist
            # its StoreID into a file we regenerate.
            # https://firefox-source-docs.mozilla.org/toolkit/profile/index.html
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

          # Pin the app launcher to the default profile; bare `firefox` is not
          # deterministic with more than one profile. `--name firefox` sets the
          # wayland app-id that the niri window rules key on.
          xdg.desktopEntries.firefox = {
            name = "Firefox";
            exec = "firefox -P default --name firefox %U";
            icon = "firefox";
            type = "Application";
            categories = [
              "Network"
              "WebBrowser"
            ];
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
