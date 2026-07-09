{ ... }:
{
  imports = [
    ./shared.nix
    ./emacs.nix
    ./http-cache.nix
    ./linux-headless.nix
    ./linux-workstation.nix
    ./osx.nix
    ./nixvim.nix
  ];
}
