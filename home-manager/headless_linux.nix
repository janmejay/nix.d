{ lib, ... }:
{
  home.stateVersion = "24.05";

  imports = [ ./modules ];

  linux.headless.enable = true;
  nixvim.enable = true;

  programs.zsh.oh-my-zsh.theme = "sunaku";

  # sunaku has no agnoster-style prompt_context hook, so prepend a segment showing
  # the nix-shell name + nesting depth, mirroring the host agnoster override in
  # shared.nix. $name is set by `nix develop` (e.g. "s1-env"), empty in a plain
  # nested shell; ${name%%,*} strips any trailing metadata like the sed there does.
  # mkAfter runs this after oh-my-zsh has loaded the theme and set PROMPT.
  programs.zsh.initContent = lib.mkAfter ''
    if (( SHLVL > 1 )); then
      PROMPT="%K{white}%F{black} ''${name%%,*}/''${SHLVL} %f%k''${PROMPT}"
    fi
  '';
}
