{ pkgs, user, ... }:
let 
  dev-utils = builtins.fetchGit {
    url = "https://github.com/janmejay/dev_utils.git";
    rev = "9954323ebdf9be35c059a129e93f52be0654d029";
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
    tree
    fd
    yazi
    watch
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
