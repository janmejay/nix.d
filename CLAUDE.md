# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal multi-machine Nix configuration repository managing NixOS systems, macOS (nix-darwin), and home-manager user environments across multiple machines using Nix Flakes.

## Common Commands

### System Rebuild

```bash
# NixOS (Linux)
sudo nixos-rebuild switch --flake .#<host>

# macOS (nix-darwin)
sudo darwin-rebuild switch --flake .#<machine>

# Home-manager (user environment)
home-manager switch --flake .#janmejay@<hostname>
```

Hosts: `jnix`, `lenovo`, `dell`, `obsl` (NixOS) | `jpl`, `js1` (Darwin)

### Update Dependencies

```bash
nix flake update
nix flake check
```

### Development Shells

```bash
nix develop .#<shell-name>
```

Available shells: `amm` (Scala), `linux` (kernel dev), `c` (C/C++), `fdb` (FoundationDB), `plot` (Python data science), `ob` (Obesrvo work), `s1` (SentinelOne work)

### Garbage Collection

```bash
./trim-generations.sh 2 0 home-manager  # Keep 2 generations
sudo nix-collect-garbage -d
```

## Architecture

```
flake.nix              # Main entry point defining all outputs
├── nixos/             # NixOS system configurations per machine
├── darwin/            # macOS (nix-darwin) system configs
├── home-manager/      # User-level configurations
│   ├── modules/       # Modular configs (shared.nix, nixvim.nix, linux.nix, osx.nix)
│   └── addons/        # Optional add-ons (zscalar.nix)
├── dots/              # Dotfiles (tmux, warpd, karabiner, aerospace, etc.)
├── pkgs/              # Custom package definitions (warpd, copyq, find-cursor, hackery)
├── modules/           # Shared modules (shells.nix for dev shells)
└── secrets/           # SOPS-encrypted secrets (age encryption)
```

## Key Files

- `flake.nix` - Defines nixosConfigurations, darwinConfigurations, homeConfigurations, and devShells
- `home-manager/modules/shared.nix` - Shared user config (git, shell, packages)
- `home-manager/modules/nixvim.nix` - Neovim configuration with LSP, Telescope, Treesitter, Copilot
- `darwin/base.nix` - macOS system configuration
- `nixos/common-configuration.nix` - Shared NixOS settings
- `modules/shells.nix` - Development shell definitions

## External Dependencies

- `dev_utils` - Fetched from janmejay's dev_utils repo, provides shell configs, jq helpers, and custom scripts
- Custom packages in `pkgs/` are built from external sources (warpd fork, copyq, find-cursor)

## Secrets

Uses SOPS with age encryption. Configuration in `.sops.yaml`, secrets in `secrets/` directory.

## Machine Variants

- **js1** (work Mac): Includes ZScaler VPN support and SentinelOne-specific configs
- **jpl** (personal Mac): Standard personal configuration
- **obsl** (Linux): Observability workstation with pan-jail network isolation

## Code Style

Use comments sparingly. Comments should explain "why", not "what" - the code itself should communicate what it does.
