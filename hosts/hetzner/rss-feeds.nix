{ config, pkgs, rss-to-epub, ... }:

let
  cfg = config.services.calibre-web;
  dataDir =
    if builtins.substring 0 1 cfg.dataDir == "/" then cfg.dataDir else "/var/lib/${cfg.dataDir}";
  libraryPath = "${dataDir}/library";

  rss-to-epub-pkg = rss-to-epub.packages.${pkgs.system}.default;

  # RSS feeds to fetch. Add new feeds by appending URLs.
  # Substack feeds: https://<name>.substack.com/feed
  # Any valid RSS or Atom feed URL will work.
  feeds = [
    "https://seanfennessey.substack.com/feed"
  ];

  syncScript = pkgs.writeShellApplication {
    name = "rss-feeds-sync";
    runtimeInputs = [
      rss-to-epub-pkg
      pkgs.calibre
      pkgs.jq
      pkgs.sqlite
    ];
    text = ''
      LIBRARY="${libraryPath}"
      APP_DB="${dataDir}/app.db"
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

        # We track feed slug -> Calibre book ID in a JSON file so that
        # subsequent runs replace the EPUB (via add_format) instead of
        # creating duplicate books (via add). This preserves any metadata
        # edits or reading state in Calibre-Web.
        BOOK_ID=$(jq -r --arg slug "$SLUG" '.[$slug] // ""' "$BOOK_IDS_FILE")

        if [ -z "$BOOK_ID" ]; then
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
            # Remove any existing KEPUB so calibre-web's kepubify
            # reconverts from the fresh EPUB on next Kobo sync.
            calibredb remove_format --library-path="$LIBRARY" "$BOOK_ID" KEPUB 2>/dev/null || true
            # Clear Kobo sync state so calibre-web re-delivers the book.
            sqlite3 "$APP_DB" "DELETE FROM kobo_synced_books WHERE book_id = $BOOK_ID;"
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
    # Calibre's CLI tools link against Qt, which tries to connect to a
    # display server on startup. This tells Qt there's no screen.
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
        dataDir
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
