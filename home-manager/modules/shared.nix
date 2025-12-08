{ pkgs, user, ... }:
let 
  dev-utils = builtins.fetchGit {
    url = "https://github.com/janmejay/dev_utils.git";
    rev = "f9ae57589605dfde400387eafe1e464ff269c35a";
    submodules = true;
    ref = "master";
  };
in
{
  home.username = user;

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR="nvim";
  };
  home.shellAliases = {
    l = "eza";
    c = "bat";
  };

  fonts.fontconfig.enable = true;

  home.file = {
    ".config" = {
      source = ../../dots/dot_config;
      recursive = true;
    };
    ".gitconfig".source = ../../dots/gitconfig;
    ".dev_utils".source = dev-utils;
    ".jq".source = "${dev-utils}/rc/jq";
    ".tmux.conf".source = ../../dots/tmux.conf;
  };

  home.packages = with pkgs; [
    sops 
    rustup
    eza
    bat
    fzf
    silver-searcher
    jq
    ripgrep
    cascadia-code
    dejavu_fonts
    powerline-fonts
    ubuntu-sans-mono
    intel-one-mono
    source-code-pro
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    tree
    fd
    yazi
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = ''
    source ~/.dev_utils/rc/shared_shell_config
    DEFAULT_USER=${user}
    prompt_context() {
      if (( $SHLVL > 1 )) ; then
        n=$(echo $name | sed -re "s/,.+//")
        prompt_segment white black "$n/$SHLVL"
      fi
    }
    '';
    oh-my-zsh= {
      enable = true;
      plugins = ["git" "python" "docker" "fzf"];
      theme = "agnoster";
    };
  };

  programs.kitty = {
    enable = true;
    themeFile = "3024_Night";
    shellIntegration.enableZshIntegration = true;
    font = {
      name = "DejaVu Sans Mono";
      size = 15.5;
    };
    extraConfig = "enable_audio_bell no";
  };
}
