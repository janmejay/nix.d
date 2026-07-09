{
  home.stateVersion = "24.05";
  
  imports = [ ./modules  ];
  
  emacs.enable = true;
  http-cache.enable = true;
  linux.headless.enable = true;
  linux.workstation.enable = true;
  nixvim.enable = false;
}
