{ config, pkgs, lib, ... }:
let
  cfg = config.osx;
in
{
  options.osx = {
    enable = lib.mkEnableOption "Pull osx specific config / pkgs";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ 
      choose-gui
    ];

    home.file = {
      ".config/karabiner/assets/complex_modifications/cmd_ctrl.json".source = ../../dots/karabiner/complex_modifications/cmd_ctrl.json;
      ".config/aerospace/aerospace.toml".source = ../../dots/aerospace.toml;
      ".config/ghostty/config".source = ../../dots/ghostty/config;
    };

    # Keep `programs.zsh` enabled (in shared.nix) so home-manager keeps
    # generating ~/.zshrc and the oh-my-zsh integration, but redirect the
    # zsh *binary* in ~/.nix-profile/bin/zsh to Apple's /bin/zsh. PATH-
    # resolved `zsh` then runs /bin/zsh — which doesn't hang in nested
    # PTYs the way the nix-built zsh does — and only zsh is shadowed
    # (no global PATH reordering).
    programs.zsh.package = pkgs.runCommandLocal "zsh-system-shim" {} ''
      mkdir -p $out/bin
      ln -s /bin/zsh $out/bin/zsh
    '';
  };
}
