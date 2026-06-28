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
      ".config/karabiner/karabiner.json".source = ../../dots/karabiner/karabiner.json;
      ".config/aerospace/aerospace.toml".source = ../../dots/aerospace.toml;
      ".config/alacritty/alacritty.toml".source = ../../dots/alacritty/alacritty.toml;
      ".config/ghostty/config".source = ../../dots/ghostty/config;
    };

    # macOS ncurses has no built-in `alacritty` / `alacritty-direct` terminfo
    # entries, so shells started under TERM=alacritty fail termcap lookups
    # (set-environment, prompts, etc.). Compile alacritty's bundled source
    # into ~/.terminfo at activation time so the entries are local to the
    # user without needing root.
    home.activation.alacrittyTerminfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /usr/bin/tic -xe alacritty,alacritty-direct \
        -o "$HOME/.terminfo" \
        "${pkgs.alacritty.src}/extra/alacritty.info" >/dev/null 2>&1 || true
    '';

    # macOS 10.14+ disables font smoothing app-wide by default; alacritty
    # doesn't opt back in, so glyphs render noticeably thinner than wezterm.
    # AppleFontSmoothing=2 (medium) restores the heavier rendering. Takes
    # effect on next full launch of alacritty (Cmd+Q, not just close window).
    home.activation.alacrittyFontSmoothing = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /usr/bin/defaults write org.alacritty AppleFontSmoothing -int 2
    '';

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
