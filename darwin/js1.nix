{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  networking.computerName = "LCY79567W2";
  networking.hostName = "LCY79567W2";
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
  users.users."janmejay.singh" = {
    home = "/Users/janmejay.singh";
    shell = pkgs.zsh;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [ 
    	"karabiner-elements"
	"intellij-idea-ce"
	"shortcat"
	#"scoot"
	#"mouseless"
	#"homerow"
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
    primaryUser = "janmejay.singh";
    defaults = {
      dock.autohide = true;
      finder.AppleShowAllFiles = true;
      loginwindow.GuestEnabled = false;
    };
  };
}
