# Nic's Personal Nix System Config

This repository contains my personal [nix](https://nixos.org/learn/) system config, where I define modules that declaratively configure my NixOS and macOS based systems.

To do this, I am using the experimental Nix feature, [`flakes`](https://nixos.wiki/wiki/Flakes). This allows me to create a single entrypoint into my entire configuration, regardless of platform, version-pinned input dependencies: [flake.nix](./flake.nix).

## flake.nix
This is the entrypoint to the configuration. There are two primary components: `inputs` and `outputs`.

Inputs are essentially other flakes that we depend on. Some of these flakes are:
- `nixpkgs` - the actual repository containing the full collection of nix packages
- `nix-darwin` - a collection of modules than can declaratively configure macOS
- `home-manager` - a collection of modules that can declaritively configure user (non-global) packages and dotfiles
- and others

The outputs are generated as a function of the inputs. The two most important outputs at the time of writing this are:
- `nixosConfigurations` - this defines the NixOS system
- `darwinConfigurations` - this defines the macOS system

Both of these outputs include several of other modules that together declaratively configure their corresponding system.

## Usage

> [!WARNING]
> At the time of writing this, I have yet to actually try building a fresh system from these configurations. It's important to note that these instructions are currently a from-memory reconstruction of the steps needed to get up and running with these configs.

### NixOS

1. Make sure your `hostname` is `desktop` and user is `nic`.
2. Clone this repo to `~/dev/nficca/nixos-config`.
3. Add a symlink: `sudo ln -s ~/dev/nficca/nixos-config /etc/nixos`
4. `sudo nixos-rebuild switch`

### MacOS

1. Make sure your `hostname` matches what's defined in [flake.nix](./flake.nix) under `darwinConfigurations.<hostname>`, and that your user is `nic`.
2. Ensure you satisfy the [`nix-darwin` prerequisites](https://github.com/nix-darwin/nix-darwin?tab=readme-ov-file#prerequisites).
3. Clone this repo to `~/dev/nficca/nixos-config`.
4. Run `sudo nix run nix-darwin/master#darwin-rebuild -- switch`.
5. Then you should be safe to run `sudo darwin-rebuild switch`.

> [!NOTE]
> Please submit a pull-request to amend these steps with any necessary corrections should they be identified while following the steps.


