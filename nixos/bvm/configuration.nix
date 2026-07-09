{ config, modulesPath, pkgs, lib, inputs, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  networking.hostName = "bvm";

  # lima-init adds the guest user imperatively at boot; nixos-rebuild must not
  # clobber it, so mutableUsers must stay true.
  users.mutableUsers = true;
  services.lima.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = (with pkgs; [
    git
    curl
    wget
    zsh
    gnumake
    gcc
    pkg-config
  ]) ++ [
    # home-manager CLI, matching the flake's home-manager input (not the nixpkgs
    # copy) so its version aligns with homeConfigurations."lima@bvm".
    # `nixos-rebuild` only installs the tool; you run `home-manager switch` yourself.
    inputs.home-manager.packages.${pkgs.system}.home-manager
  ];

  # Boot/root layout must match the nixos-lima image (do not change).
  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  fileSystems."/boot" = {
    device = lib.mkForce "/dev/vda1";
    fsType = "vfat";
  };
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
    # Fastest build I/O: /nix + native clones live here (virtio-blk under vz).
    # noatime/nodiratime cut metadata writes; periodic fstrim replaces continuous
    # `discard` (which adds latency to every unlink) — see services.fstrim below.
    options = [ "noatime" "nodiratime" ];
  };
  services.fstrim.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "24.05";
}
