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
