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
- and others

The outputs are generated as a function of the inputs. The two most important
outputs at the time of writing this are:
- `nixosConfigurations` - this defines the NixOS system
- `darwinConfigurations` - this defines the macOS system

Both of these outputs include several of other modules that together
declaratively configure their corresponding system.

## Usage

> [!WARNING]
> At the time of writing this, I have yet to actually try building a fresh
> system from these configurations. It's important to note that these
> instructions are currently a from-memory reconstruction of the steps needed to
> get up and running with these configs.

### NixOS

If you're starting fresh, you'll want to go through the [official
guide](https://nixos.wiki/wiki/NixOS_Installation_Guide). However, once you get
to the part where you generate a NixOS config, you can instead do the following:

1. Clone this repo to `/home/nic/dev/nficca/nixos-config`.
2. Run `nixos-install --flake
   '/home/nic/dev/nficca/nixos_config/flake.nix#<hostname>'`

Where `hostname` is either one of the existing `nixosConfigurations` (see
[./flake.nix](./flake.nix)), or a new one that you add. This should install the
configuration. Once that's done, restart and you should be booted right into
NixOS proper.

After that, you might want to create a symlink. Remove the existing `/etc/nixos`
(make a backup first), and then do `sudo ln -s ~/dev/nficca/nixos-config
/etc/nixos`.

### MacOS

1. Add your hostname (`scutil --get LocalHostName`) as another entry to
   `darwinConfigurations` in [flake.nix](./flake.nix) if not already present.
2. Ensure you satisfy the [`nix-darwin`
   prerequisites](https://github.com/nix-darwin/nix-darwin?tab=readme-ov-file#prerequisites).
3. Clone this repo to `~/dev/nficca/nixos-config`.
4. Run `sudo ln -s ~/dev/nficca/nixos-config /etc/nix-darwin`
4. Run `sudo nix run nix-darwin/master#darwin-rebuild -- switch`.
5. Then you should be safe to run `sudo darwin-rebuild switch`.

> [!NOTE]
> Please submit a pull-request to amend these steps with any necessary
> corrections should they be identified while following the steps.

