# nixos-config

## Mullvad kill-switch gotcha

If outbound traffic is dead from this machine — including raw IPs like
`1.1.1.1`, surviving `iptables -F`, reboots, and even NixOS generation
rollback — suspect the Mullvad daemon's lockdown mode before anything else.

**Fingerprint:**
- `ping 1.1.1.1` returns `Operation not permitted` from this host's own IP
- Every connection fails "after 0 ms"
- The block survives reboots because `mullvad-daemon` reapplies its nftables
  rules on every start

**Diagnose:**

```
mullvad lockdown-mode get
mullvad status
```

If lockdown is `on` and status is `Disconnected`, that's the cause.

**Fix:**

```
mullvad lockdown-mode set off
mullvad disconnect
```

Fallback if the CLI is unreachable: `sudo systemctl stop mullvad-daemon`.

There is no NixOS option for `lockdown-mode`; it lives in
`/etc/mullvad-vpn/settings.json` and is daemon-managed. Keep it off
imperatively; verify after any `mullvad-vpn` package bump.

## saml2aws session-persistence gotcha

The FOSSA EKS login (`aws-login`, wrapping `saml2aws login ... --browser-type
firefox` under `steam-run`) drives a Playwright Firefox, not your real profile.
It avoids re-entering Google email/password/OTP on every 4-hour AWS credential
refresh by persisting the browser session to `~/.aws/saml2aws/storageState.json`
and reloading it on the next run.

**Fingerprint:**
- Every `saml2aws login` forces a full Google re-auth, even minutes after a
  successful one, instead of refreshing silently
- saml2aws logs `Error saving storage state` (easy to miss in its output)

**Cause:** saml2aws writes `storageState.json` but never creates the
`~/.aws/saml2aws/` directory, and Playwright's `StorageState()` write fails
silently when the parent is missing. With no directory the session is discarded
every run and each login starts cold.

**Diagnose:**

```
ls -la ~/.aws/saml2aws/storageState.json
```

**Fix:** ensure the directory exists. The `aws-login` wrapper runs
`mkdir -p ~/.aws/saml2aws` on every invocation, so this stays fixed as long as
you log in via `aws-login`; the trap only resurfaces on a fresh machine or if
the directory gets removed.
