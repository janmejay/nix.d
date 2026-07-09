{ config, pkgs, lib, ... }:
let
  cfg = config.osx;

  warpd = pkgs.callPackage ../../pkgs/warpd {};

  # Keys that get left_shift injected while shift_lock is on. Covers all
  # printable ANSI keys with a shifted form; arrows/fn keys are intentionally
  # excluded so shift+arrow selection isn't broken by the lock.
  shiftableKeys =
    [ "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
      "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"
      "1" "2" "3" "4" "5" "6" "7" "8" "9" "0"
      "grave_accent_and_tilde" "hyphen" "equal_sign"
      "open_bracket" "close_bracket" "backslash"
      "semicolon" "quote"
      "comma" "period" "slash" ];

  applyShift = key: {
    type = "basic";
    from = { key_code = key; };
    to = [ { key_code = key; modifiers = [ "left_shift" ]; } ];
    conditions = [ { type = "variable_if"; name = "shift_lock"; value = 1; } ];
  };

  karabinerConfig = {
    profiles = [ {
      name = "Default profile";
      selected = true;
      virtual_hid_keyboard = { country_code = 0; keyboard_type_v2 = "ansi"; indicate_sticky_modifier_keys_state = false; };
      complex_modifications.rules = [
        {
          description = "left_command: Escape on tap, Command on hold";
          manipulators = [ {
            type = "basic";
            from = { key_code = "left_command"; modifiers = { optional = [ "any" ]; }; };
            to = [ { key_code = "left_command"; } ];
            to_if_alone = [ { key_code = "escape"; } ];
          } ];
        }
        {
          description = "caps_lock -> left_control";
          manipulators = [ {
            type = "basic";
            from = { key_code = "caps_lock"; modifiers = { optional = [ "any" ]; }; };
            to = [ { key_code = "left_control"; } ];
          } ];
        }
        {
          description = "left_shift tap arms one-shot shift (next key only; hold still acts as shift)";
          manipulators = [ {
            type = "basic";
            from = { key_code = "left_shift"; modifiers = { optional = [ "any" ]; }; };
            to = [ { key_code = "left_shift"; lazy = true; } ];
            to_if_alone = [ { sticky_modifier = { left_shift = "on"; }; } ];
          } ];
        }
        {
          description = "right_shift tap toggles shift_lock (hold still acts as shift)";
          manipulators = [
            {
              type = "basic";
              from = { key_code = "right_shift"; modifiers = { optional = [ "any" ]; }; };
              to = [ { key_code = "right_shift"; lazy = true; } ];
              to_if_alone = [ { set_variable = { name = "shift_lock"; value = 1; }; } ];
              conditions = [ { type = "variable_if"; name = "shift_lock"; value = 0; } ];
            }
            {
              type = "basic";
              from = { key_code = "right_shift"; modifiers = { optional = [ "any" ]; }; };
              to = [ { key_code = "right_shift"; lazy = true; } ];
              to_if_alone = [ { set_variable = { name = "shift_lock"; value = 0; }; } ];
              conditions = [ { type = "variable_if"; name = "shift_lock"; value = 1; } ];
            }
          ];
        }
        {
          description = "shift_lock: inject left_shift on typing keys while locked";
          manipulators = map applyShift shiftableKeys;
        }
      ];
    } ];
  };

  karabinerJson = pkgs.writeText "karabiner.json" (builtins.toJSON karabinerConfig);
in
{
  options.osx = {
    enable = lib.mkEnableOption "Pull osx specific config / pkgs";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      choose-gui
      warpd
    ];

    home.file = {
      ".config/karabiner/karabiner.json".source = karabinerJson;
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
