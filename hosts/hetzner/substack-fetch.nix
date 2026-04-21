{ pkgs, ... }:

let
  libraryPath = "/var/lib/calibre-web/library";

  # Substack RSS feeds to fetch. Add new feeds by appending URLs.
  # Feed URLs follow the pattern: https://<name>.substack.com/feed
  feeds = [
    "https://seanfennessey.substack.com/feed"
  ];

  fetchScript = pkgs.writeShellApplication {
    name = "substack-fetch";
    runtimeInputs = with pkgs; [
      curl
      xmlstarlet
      calibre
    ];
    text = ''
      LIBRARY="${libraryPath}"
      STATE_DIR="/var/lib/substack-fetch"
      FETCHED_FILE="$STATE_DIR/fetched.txt"
      WORK_DIR="$(mktemp -d)"

      mkdir -p "$STATE_DIR"
      touch "$FETCHED_FILE"

      cleanup() { rm -rf "$WORK_DIR"; }
      trap cleanup EXIT

      FEEDS=(
        ${builtins.concatStringsSep "\n        " (map (f: ''"${f}"'') feeds)}
      )

      for FEED_URL in "''${FEEDS[@]}"; do
        echo "Fetching feed: $FEED_URL"

        FEED_FILE="$WORK_DIR/feed.xml"
        if ! curl -sSfL --max-time 30 -o "$FEED_FILE" "$FEED_URL"; then
          echo "WARNING: Failed to fetch $FEED_URL, skipping"
          continue
        fi

        ITEM_COUNT=$(xmlstarlet sel -t -v "count(//item)" "$FEED_FILE" 2>/dev/null || echo "0")

        if [ "$ITEM_COUNT" -eq 0 ]; then
          echo "No items found in feed, skipping"
          continue
        fi

        for i in $(seq 1 "$ITEM_COUNT"); do
          GUID=$(xmlstarlet sel -t -v "//item[$i]/guid" "$FEED_FILE" 2>/dev/null || echo "")

          if [ -z "$GUID" ]; then
            continue
          fi

          if grep -qFx "$GUID" "$FETCHED_FILE" 2>/dev/null; then
            continue
          fi

          TITLE=$(xmlstarlet sel -t -v "//item[$i]/title" "$FEED_FILE" 2>/dev/null || echo "Untitled")
          AUTHOR=$(xmlstarlet sel \
            -N dc="http://purl.org/dc/elements/1.1/" \
            -t -v "//item[$i]/dc:creator" "$FEED_FILE" 2>/dev/null || echo "Unknown")

          echo "Processing: $TITLE"

          # Prefer content:encoded from RSS (clean article HTML) over
          # downloading the full page which includes site boilerplate.
          xmlstarlet sel \
            -N content="http://purl.org/rss/1.0/modules/content/" \
            -t -v "//item[$i]/content:encoded" "$FEED_FILE" \
            > "$WORK_DIR/content.html" 2>/dev/null || true

          HTML_FILE="$WORK_DIR/post.html"
          if [ -s "$WORK_DIR/content.html" ]; then
            {
              echo '<!DOCTYPE html><html><head><meta charset="utf-8"></head><body>'
              cat "$WORK_DIR/content.html"
              echo '</body></html>'
            } > "$HTML_FILE"
          else
            # Fall back to downloading the full page
            LINK=$(xmlstarlet sel -t -v "//item[$i]/link" "$FEED_FILE" 2>/dev/null || echo "")
            if [ -z "$LINK" ] || ! curl -sSfL --max-time 60 -o "$HTML_FILE" "$LINK"; then
              echo "WARNING: Failed to get content for '$TITLE', skipping"
              continue
            fi
          fi

          SAFE_TITLE=$(echo "$TITLE" | tr -cd '[:alnum:] ._-' | head -c 200)
          EPUB_FILE="$WORK_DIR/''${SAFE_TITLE}.epub"

          if ! ebook-convert "$HTML_FILE" "$EPUB_FILE" \
            --title "$TITLE" \
            --authors "$AUTHOR" \
            --tags "substack,newsletter" \
            --publisher "Substack" \
            --no-default-epub-cover 2>&1; then
            echo "WARNING: Failed to convert '$TITLE', skipping"
            continue
          fi

          if calibredb add --library-path="$LIBRARY" "$EPUB_FILE" 2>&1; then
            echo "$GUID" >> "$FETCHED_FILE"
            echo "Added: $TITLE"
          else
            echo "WARNING: Failed to add '$TITLE' to library"
          fi

          rm -f "$HTML_FILE" "$EPUB_FILE" "$WORK_DIR/content.html"
        done
      done

      echo "Fetch complete"
    '';
  };
in
{
  systemd.services.substack-fetch = {
    description = "Fetch new Substack posts and add to Calibre library";
    after = [
      "network-online.target"
      "calibre-library-init.service"
    ];
    wants = [ "network-online.target" ];
    environment.QT_QPA_PLATFORM = "offscreen";
    serviceConfig = {
      Type = "oneshot";
      User = "calibre-web";
      Group = "calibre-web";
      ExecStart = "${fetchScript}/bin/substack-fetch";
      StateDirectory = "substack-fetch";
      PrivateTmp = true;
      ProtectHome = true;
      NoNewPrivileges = true;
      ReadWritePaths = [
        libraryPath
        "/var/lib/substack-fetch"
      ];
    };
  };

  systemd.timers.substack-fetch = {
    description = "Run Substack fetch every hour";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "5min";
      Persistent = true;
    };
  };
}
