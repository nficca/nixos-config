# Nic's Personal Nix System Config

This repository contains my personal [nix](https://nixos.org/learn/) system
config, where I define modules that declaratively configure my NixOS and macOS
based systems.

To do this, I am using the experimental Nix feature,
[`flakes`](https://nixos.wiki/wiki/Flakes). This allows me to create a single
entrypoint into my entire configuration, regardless of platform, version-pinned
input dependencies: [flake.nix](./flake.nix).

## flake.nix

This is the entrypoint to the configuration. There are two primary components:
`inputs` and `outputs`.

Inputs are essentially other flakes that we depend on. Some of these flakes are:
- `nixpkgs` - the actual repository containing the full collection of nix
packages
- `nix-darwin` - a collection of modules than can declaratively configure macOS
- `home-manager` - a collection of modules that can declaritively configure user
(non-global) packages and dotfiles
- `dev-flakes` - a private repository containing project-specific development
flakes
- and others

The outputs are generated as a function of the inputs. The two most important
outputs at the time of writing this are:
- `nixosConfigurations` - this defines the NixOS system
- `darwinConfigurations` - this defines the macOS system

Both of these outputs include several of other modules that together
declaratively configure their corresponding system.

## Usage

There are derivations for both NixOS and Darwin (macOS) systems.

> [!WARNING]
> This is not a configuration meant for generic use. **If you are not me, then
> this won't work**. If you like this config, I suggest you pick out the
> specific parts you like and adapt them for your own config.

### NixOS

If you're starting fresh, you'll want to go through the [official
guide](https://nixos.wiki/wiki/NixOS_Installation_Guide). However, once you get
to the part where you generate a NixOS config, you can instead do the following:

1. Clone this repo to `/home/nic/dev/nficca/nixos-config`.
2. Run `nixos-install --flake
   '/home/nic/dev/nficca/nixos_config/flake.nix#<hostname>' --override-input
   dev-flakes path:/home/nic/dev/nficca/nixos-config/.empty`

Where `hostname` is either one of the existing `nixosConfigurations` (see
[./flake.nix](./flake.nix)), or a new one that you add. The `--override-input`
flag allows the build to succeed even without SSH access to the private
`dev-flakes` repository.

3. Create a symlink. Remove the existing `/etc/nixos`, and then: `sudo ln -s
   ~/dev/nficca/nixos-config`.
4. Update the flake to use the real dev-flakes: `nix flake update dev-flakes`.
5. Now you should be all set and can rebuild when desired: `nixos-rebuild
   switch`

### MacOS

1. Add your hostname (`scutil --get LocalHostName`) as another entry to
   `darwinConfigurations` in [flake.nix](./flake.nix) if not already present.
2. Ensure you satisfy the [`nix-darwin`
   prerequisites](https://github.com/nix-darwin/nix-darwin?tab=readme-ov-file#prerequisites).
3. Clone this repo to `~/dev/nficca/nixos-config`.
4. Run `sudo ln -s ~/dev/nficca/nixos-config /etc/nix-darwin`
5. Run the initial build with the empty dev-flakes fallback:

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dev/nficca/nixos-config --override-input dev-flakes path:./.empty
```

The `--override-input` flag allows the build to succeed even without SSH access
to the private `dev-flakes` repository.

6. Once that's done, you can update the flake to use the real dev-flakes:

```bash
cd ~/dev/nficca/nixos-config
nix flake update dev-flakes
sudo darwin-rebuild switch
```

## NH

NH is "a modern helper utility that aims to consolidate and reimplement some of
the commands and interfaces from various tools within the Nix/NixOS ecosystem."

This configuration installs `nh`, which is often nicer to work with than nix
commands directly. See [the usage section of the `nh`
README](http://github.com/nix-community/nh?tab=readme-ov-file#usage) for more
details.

A notable example is the helper for rebuilds:
```sh
# On NixOS
nh os switch . --ask

# On Darwin
nh darwin switch . --ask
```
This will build the current system flake, show the package differences, and
prompt to the user before switching to it.

## Wireguard

If you want to connect to a VPN via Wireguard, I've found that the easiest way
to set this up is to do this is the following, assuming you already have the
config file for the Wireguard interface:

1. Copy the config file somewhere on the machine. I like:  `/etc/wireguard`:
```sh
sudo mkdir -p /etc/wireguard
sudo chmod 700 /etc/wireguard
sudo cp my-interface.conf /etc/wireguard/my-interface.conf
sudo chmod 600 /etc/wireguard/my-interface.conf
```
2. Then make sure `networkmanager` and `wireguard` are enabled in the relevant
   host's `configuration.nix`:
```nix
networking.networkmanager.enable = true;
networking.wireguard.enable = true;
```
3. After doing a `sudo nixos-rebuild switch`, you can run the following import
   the interface:
```sh
sudo nmcli connection import type wireguard file /etc/wireguard/my-interface.conf
```

You should now be connected to the interface, and can disconnect and reconnect
via the network manager interface or CLI.

## Troubleshooting

### Permission denied for dev-flakes

If you encounter an error indicating that you don't have access to
ssh://git@github.com/nficca/nixos-flakes.git, it could be one of a few issues.
First, if you aren't me, then this isn't gonna work for you at all. Remove or
comment out the dev-flakes input. If you _are_ me and you know that you have
your git credentials sorted (i.e. you can clone that repo just fine), then you
might need to let nix prefetch the flake by itself first. You can do that like
so:

```sh
nix flake prefetch git+ssh://git@github.com/nficca/nixos-flakes.git
```

