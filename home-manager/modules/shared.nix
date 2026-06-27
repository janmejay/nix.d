{ pkgs, user, email, ... }:
let 
  warpd = pkgs.callPackage ../../pkgs/warpd {};
  dev-utils = builtins.fetchGit {
    url = "https://github.com/janmejay/dev_utils.git";
    rev = "040d73ae8b6b14707292821499f587d7597da888";
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

  programs.git = {
    enable = true;
    settings = {
      color.ui = "auto";
      alias = {
        ci = "commit";
        co = "checkout";
        st = "status";
        ls = "branch -a";
        cp = "cherry-pick";
        stack = "!git-stack";
        first-downstream = "!git-first-downstream";
        local-commits = "!git-all-local-commits";
        mark-landed = "!git-mark-branch-landed";
        rebase-stacked = "!git-rebase-stacked-diff";
        remove-deleted = "!git ls-files -d | xargs git rm";
        add-untracked = "!git ls-files -o --exclude-standard | xargs git add -v";
        add-remove = "!git remove-deleted && git add-untracked";
        purge = "!git clean -fdx";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
        graft = "!git-graft-stack";
        wt = "worktree";
      };
      core = {
        editor = "nvim";
        pager = "less -F -x4";
      };
      push.default = "current";
      pull.rebase = false;
      branch.autosetupmerge = "true";
      gui = {
        fontui = "-family \"Ubuntu Mono\" -size 5 -weight normal -slant roman -underline 0 -overstrike 0";
        fontdiff = "-family \"Ubuntu Mono\" -size 5 -weight normal -slant roman -underline 0 -overstrike 0";
      };
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
      user = {
        name = "Janmejay Singh";
        email = email;
      };
    };
    signing.format = null;
  };

  home.file = {
    ".config" = {
      source = ../../dots/dot_config;
      recursive = true;
    };
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
    nodejs_latest
    warpd
    opencode
    claude-code
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

    PROMPT=$'%{\033]133;A\033\\%}'$PROMPT$'%{\033]133;B\033\\%}'
    autoload -Uz add-zsh-hook
    emit_cmd_start() { printf '\033]133;C\033\\' }
    add-zsh-hook preexec emit_cmd_start
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
