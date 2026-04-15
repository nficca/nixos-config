# URL handler that opens links in the most recently focused Firefox profile.
# Queries niri for the last-focused Firefox window, reads /proc/<pid>/cmdline
# to determine which profile it belongs to, then routes the URL there.
{ pkgs, ... }:

let
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
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "firefox-profile-handler.desktop";
    "x-scheme-handler/https" = "firefox-profile-handler.desktop";
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
}
