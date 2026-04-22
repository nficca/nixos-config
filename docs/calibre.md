# Calibre-Web + Kobo Sync

RSS feeds are automatically converted to EPUBs and delivered to a Kobo e-reader via Calibre-Web's Kobo sync API. This runs on the Hetzner box.

## How it works

1. A systemd timer fires hourly
2. For each RSS feed in the config, `rss-to-epub` fetches the feed, cleans article HTML with Readability, and builds an EPUB with Pandoc (one book per feed, articles as chapters)
3. The EPUB is added to (or updated in) the Calibre library via `calibredb`
4. Calibre-Web serves the library and exposes the Kobo sync API
5. The Kobo pulls new/updated books over wifi automatically

## Setting up a new host

### 1. DNS

Add a CNAME (or A) record pointing your chosen subdomain to the host. ACME needs this to issue a TLS certificate.

Example: `calibre.nicficca.com` CNAME to `nicficca.com`

### 2. NixOS config

Import `calibre-web.nix` and `rss-feeds.nix` in your host's `configuration.nix`:

```nix
imports = [
  ./calibre-web.nix
  ./rss-feeds.nix
];
```

Make sure `flake.nix` includes the `rss-to-epub` input and passes it via `specialArgs`.

Update the nginx `server_name` in `calibre-web.nix` if using a different subdomain.

### 3. Deploy

Build and deploy. On first boot:

- `calibre-library-init` creates an empty Calibre library (with a placeholder book you should delete later)
- `calibre-web` starts and becomes accessible at your subdomain
- `rss-feeds.timer` begins firing hourly

### 4. Calibre-Web first login

Go to `https://<your-subdomain>`. Default credentials: `admin` / `admin123`.

Change the admin password immediately.

### 5. Enable Kobo sync

In the admin panel:

1. Admin > Edit Basic Configuration > Feature Configuration
2. Check **Enable Kobo sync**
3. Check **Proxy unknown requests to Kobo Store** (preserves access to the official Kobo store)
4. Save

### 6. Create a user

1. Admin > Add New User
2. Enable **Allow Downloads** (required for Kobo sync to work)
3. Save
4. Log in as the new user
5. Go to your profile; copy the **Kobo Sync Token** URL

### 7. Configure the Kobo

1. Connect the Kobo to your computer via USB
2. Mount the device
3. Edit `.kobo/Kobo/Kobo eReader.conf`
4. In the `[OneStoreServices]` section, set:

```ini
api_endpoint=https://<your-subdomain>/kobo/<your-sync-token>
```

5. Unmount and disconnect
6. On the Kobo, connect to wifi and sync

### 8. Delete the placeholder book

The library init service creates an empty "Unknown" book to initialize the database. Delete it from the Calibre-Web UI after your first real book syncs.

## Adding feeds

Add URLs to the `feeds` list in `rss-feeds.nix` and rebuild:

```nix
feeds = [
  "https://another.example.com/feed"
];
```

Substack feeds follow the pattern `https://<name>.substack.com/feed`. Any valid RSS or Atom feed URL will work.

## Troubleshooting

### Sync fails with no obvious error

Check the nginx logs, not just calibre-web logs:

```
journalctl -u nginx --since '5 minutes ago'
```

The calibre-web logs will say "Kobo library sync request received" even when nginx is rejecting the response. The nginx logs show the actual error.

### "upstream sent too big header"

The Kobo sync response is large. The `proxy_buffer_size` and `proxy_buffers` settings in the nginx config handle this. If you see this error, those buffer settings are missing or too small.

### Books don't appear on Kobo after syncing

In Calibre-Web admin, check:

- The user has **Allow Downloads** enabled
- **Enable Kobo sync** is checked under Feature Configuration
- Try clicking **Force full Kobo sync** on the user's edit page

### URLs contain wrong port (e.g. :8083)

The `config_external_port` setting in calibre-web's database controls this. It's set to 443 declaratively via `ExecStartPre` in `calibre-web.nix`. If URLs still show the wrong port, restart calibre-web:

```
sudo systemctl restart calibre-web
```
