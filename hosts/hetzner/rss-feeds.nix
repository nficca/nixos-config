{ pkgs, rss-to-epub, ... }:

let
  libraryPath = "/var/lib/calibre-web/library";

  rss-to-epub-pkg = rss-to-epub.packages.${pkgs.system}.default;

  # RSS feeds to fetch. Add new feeds by appending URLs.
  feeds = [
    "https://seanfennessey.substack.com/feed"
  ];

  syncScript = pkgs.writeShellApplication {
    name = "rss-feeds-sync";
    runtimeInputs = [
      rss-to-epub-pkg
      pkgs.calibre
      pkgs.jq
    ];
    text = ''
      LIBRARY="${libraryPath}"
      STATE_DIR="/var/lib/rss-feeds"
      BOOK_IDS_FILE="$STATE_DIR/book-ids.json"
      WORK_DIR="$(mktemp -d)"

      mkdir -p "$STATE_DIR"
      if [ ! -f "$BOOK_IDS_FILE" ]; then
        echo '{}' > "$BOOK_IDS_FILE"
      fi

      cleanup() { rm -rf "$WORK_DIR"; }
      trap cleanup EXIT

      FEEDS=(
        ${builtins.concatStringsSep "\n        " (map (f: ''"${f}"'') feeds)}
      )

      for FEED_URL in "''${FEEDS[@]}"; do
        # Derive a slug from the URL for naming
        SLUG=$(echo "$FEED_URL" | sed 's|https\?://||' | sed 's|/.*||' | tr '.' '-')
        EPUB_FILE="$WORK_DIR/$SLUG.epub"

        echo "Processing feed: $FEED_URL ($SLUG)"

        if ! rss-to-epub "$FEED_URL" -o "$EPUB_FILE"; then
          echo "WARNING: Failed to generate EPUB for $FEED_URL, skipping"
          continue
        fi

        # Look up existing Calibre book ID for this feed
        BOOK_ID=$(jq -r --arg slug "$SLUG" '.[$slug] // ""' "$BOOK_IDS_FILE")

        if [ -z "$BOOK_ID" ]; then
          # First time: add new book to Calibre
          OUTPUT=$(calibredb add --library-path="$LIBRARY" "$EPUB_FILE" 2>&1) || true
          NEW_ID=$(echo "$OUTPUT" | grep -o 'Added book ids: [0-9]*' | grep -o '[0-9]*')
          if [ -n "$NEW_ID" ]; then
            jq --arg slug "$SLUG" --arg id "$NEW_ID" \
              '.[$slug] = ($id | tonumber)' "$BOOK_IDS_FILE" > "$WORK_DIR/tmp-ids.json"
            mv "$WORK_DIR/tmp-ids.json" "$BOOK_IDS_FILE"
            echo "Added new book: $SLUG (ID: $NEW_ID)"
          else
            echo "WARNING: Failed to add $SLUG to library"
            echo "calibredb output: $OUTPUT"
          fi
        else
          # Update existing book with new EPUB
          if calibredb add_format --library-path="$LIBRARY" "$BOOK_ID" "$EPUB_FILE" 2>&1; then
            echo "Updated book: $SLUG (ID: $BOOK_ID)"
          else
            echo "WARNING: Failed to update $SLUG (ID: $BOOK_ID)"
          fi
        fi
      done

      echo "Feed sync complete"
    '';
  };
in
{
  systemd.services.rss-feeds = {
    description = "Fetch RSS feeds and sync EPUBs to Calibre library";
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
      ExecStart = "${syncScript}/bin/rss-feeds-sync";
      StateDirectory = "rss-feeds";
      PrivateTmp = true;
      ProtectHome = true;
      NoNewPrivileges = true;
      ReadWritePaths = [
        libraryPath
        "/var/lib/rss-feeds"
      ];
    };
  };

  systemd.timers.rss-feeds = {
    description = "Run RSS feed sync every hour";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "5min";
      Persistent = true;
    };
  };
}
