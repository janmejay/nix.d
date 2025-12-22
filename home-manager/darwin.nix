{ config, pkgs, inputs, nixvim, ... }:
{
  home.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;

  imports = [ ./modules  ];
  
  osx.enable = true;
  nixvim.enable = true;
}
