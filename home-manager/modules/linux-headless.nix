{ config, pkgs, lib, ... }:
let
  cfg = config.linux.headless;
in
{
  options.linux.headless = {
    enable = lib.mkEnableOption "Minimal headless linux CLI/build packages";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      python3
      gcc
      gnumake
      gdb
      lsof
      pstree
      file
      dig
      bc
      graphviz
      rlwrap
      nix-index
      patchelf
      moreutils
      pistol
      bash
      zsh
    ];
  };
}
