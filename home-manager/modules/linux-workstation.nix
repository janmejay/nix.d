{ config, pkgs, lib, ... }:
let
  cfg = config.linux.workstation;

  warpd = pkgs.callPackage ../../pkgs/warpd {};
  hackery = pkgs.callPackage ../../pkgs/hackery {};
  find-cursor = pkgs.callPackage ../../pkgs/find-cursor {};
in
{
  options.linux.workstation = {
    enable = lib.mkEnableOption "GUI/desktop linux workstation packages";
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".Xdefaults".source = ../../dots/Xdefaults;
    };

    home.packages = with pkgs; [
      # local (custom) v
      warpd
      hackery
      copyq
      find-cursor

      # public v
      sysstat
      timg
      xorg.xkill
      tcpdump
      vscode-fhs
      (jetbrains.plugins.addPlugins jetbrains.idea [ "github-copilot" ])
      squid
      xautolock
      i3lock
      zoom-us
      pavucontrol
      wireplumber
      networkmanagerapplet
      xclip
      xfce.xfce4-screenshooter
      xfce.thunar
      nomacs # image viewer
      firefox
      google-chrome
      tmux
      gimp
      feh
      ffmpeg
      vlc
      openjdk
      nodejs
      neovim
      tree
      eza
      fd
    ];
  };
}
