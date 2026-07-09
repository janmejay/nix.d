{
  home.stateVersion = "24.05";

  imports = [ ./modules ];

  linux.headless.enable = true;
  nixvim.enable = true;

  programs.zsh.oh-my-zsh.theme = "sunaku";
}
