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
    # Take niri from the compositor's own package: `niri msg` and the running
    # compositor have to agree on the IPC schema.
    runtimeInputs = [
      pkgs.jq
      config.programs.niri.package
    ];
    text = ''
      # Open links in whichever profile you used last: ask niri for the most
      # recently focused Firefox window and reuse the `-P` it was launched with.
      URL="''${1:-}"
      FIREFOX_ARGS=()

      # Replace a stale inherited NIRI_SOCKET with the live one. The variable
      # comes from the process that opened the link, which may predate the
      # current niri session; without this the query below fails and the link
      # lands in the default profile no matter which one was focused.
      if [ ! -S "''${NIRI_SOCKET:-}" ]; then
        NIRI_SOCKET=$(find "/run/user/$(id -u)" -maxdepth 1 -type s -name 'niri.*.sock' 2>/dev/null | head -n1)
        export NIRI_SOCKET
      fi

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

      # With no `-P`, firefox opens the default profile, so a failed lookup is
      # invisible. Log it (`journalctl --user`).
      if [ ''${#FIREFOX_ARGS[@]} -eq 0 ]; then
        echo "firefox-profile-handler: could not determine the last-focused profile, using default" >&2
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
      a handler that opens links and local HTML files in the most recently
      focused Firefox profile.
      Requires niri as the compositor (uses `niri msg` to query window focus).
    '';
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home-manager.users.${username} =
        { ... }:
        {
          programs.firefox = {
            enable = true;
            # Keep profiles at the legacy ~/.mozilla/firefox path. Firefox's crash
            # reporter and telemetry write under ~/.mozilla/firefox unconditionally
            # (and 1Password's native-messaging host lives in ~/.mozilla), so that
            # directory keeps reappearing. If the profiles live anywhere else, the
            # resurrected legacy root shadows them and Firefox shows the profile
            # selector instead of the default profile. Co-locating the profiles here
            # makes that impossible. An explicit configPath also silences Home
            # Manager's 26.05 default-path-change warning.
            configPath = ".mozilla/firefox";

            # Declare the default and work profiles; Home Manager owns profiles.ini.
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
          # wayland app-id that the niri window rules key on. This entry shadows
          # the one shipped in the firefox package, so it has to repeat that
          # entry's mime types or Firefox stops counting as a handler for web
          # content and drops out of every "open with" list.
          xdg.desktopEntries.firefox = {
            name = "Firefox";
            exec = "firefox -P default --name firefox %U";
            icon = "firefox";
            type = "Application";
            categories = [
              "Network"
              "WebBrowser"
            ];
            mimeType = [
              "text/html"
              "text/xml"
              "application/xhtml+xml"
              "application/vnd.mozilla.xul+xml"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
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
            "text/html" = "firefox-profile-handler.desktop";
            "application/xhtml+xml" = "firefox-profile-handler.desktop";
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
            "text/html"
            "application/xhtml+xml"
          ];
        };
      };
    })
  ];
}
