{ ... }:
{
  imports = [ ./headless_linux.nix ];

  # `host` resolves to the macOS host so `git clone ssh://host/~/ob/manager`
  # (or `git clone host:ob/manager`) works from inside the VM, using the host's
  # ssh key via the forwarded agent (see bvm.readme.md for the one-time host setup).
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."host" = {
      HostName = "host.lima.internal";
      User = "janmejay.singh";
    };
  };
}
