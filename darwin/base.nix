{ pkgs, user, host, ... }:
{
  nixpkgs.config.allowUnfree = true;
  networking.computerName = host;
  networking.hostName = host;
  environment.systemPackages = with pkgs; [
    obsidian
    google-chrome
    git
    wezterm
    neovim
    home-manager
    tmux
    ripgrep
    fd
    bat
    eza
    zsh
    aerospace
    gnupg
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
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
  ];
  users.users."${user}" = {
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [ 
      "karabiner-elements"
      "intellij-idea-ce"
      "copyq"
    ];
  };
  programs.zsh.enable = true;
  nix = {
    enable = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  system = {
    stateVersion = 6;
    primaryUser = user;
    defaults = {
      dock.autohide = true;
      finder.AppleShowAllFiles = true;
      loginwindow.GuestEnabled = false;
      NSGlobalDomain = {
        InitialKeyRepeat = 14;
        KeyRepeat = 2;
        ApplePressAndHoldEnabled = false;
      };
    };
  };
}
