# bvm — NixOS build VM on Lima

Headless aarch64 NixOS VM for Linux builds + nix-shells over ssh. Defined in this flake
(`nixosConfigurations.bvmp`/`bvmw`, `homeConfigurations."lima@bvmp"`/`"lima@bvmw"`), rebuilt inside the
VM against this `flake.lock`. `limactl` ships via home-manager (`shared.nix`).

Two nixos variants — build the one matching the host:
- **`bvmp`** — personal Macs (no Zscaler). Skip every Zscaler step below.
- **`bvmw`** — work Mac (js1, Zscaler CA trust via `nixos/zscalar.nix`).

Below, `<repo>` is the flake path in the mounted host home, e.g.
`/Users/janmejay/projects/nix.d` (personal) or `/Users/janmejay.singh/projects/nix.d` (js1).

Files: `lima/bvm.yaml` · `nixos/bvm/configuration.nix` · `nixos/zscalar.nix` · `home-manager/bvm.nix`

## One time (Mac)
```bash
# bvmw (js1) only — generates ~/.zscaler-ca.pem for the VM:
home-manager switch --flake .#janmejay@js1
sudo systemsetup -setremotelogin on                # for `git clone host:...` from the VM
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
```

## Initial setup
```bash
limactl start ./lima/bvm.yaml --name bvm           # downloads image, boots ssh-ready
limactl shell bvm
# bvmw only: disable Zscaler on the Mac for this first rebuild, then re-enable after.
sudo nixos-rebuild boot --flake <repo>#bvmp        # bvmp personal / bvmw work
sudo reboot
# reconnect — home-manager CLI is now on PATH:
limactl shell bvm
home-manager switch --flake <repo>#lima@bvmp        # bvmp personal / bvmw work
```

## Usage
```bash
limactl start bvm | limactl stop bvm               # persistent; start is a no-op if running
limactl shell bvm                                  # or `ssh bvm` after Include ~/.lima/bvm/ssh.config
git clone host:ob/manager                          # in VM: clone work repos to native disk
```

## Upgrade / GC (in VM)
```bash
# Mac: nix flake update && commit
sudo nixos-rebuild boot --flake <repo>#bvmp && sudo reboot   # bvmp personal / bvmw work
home-manager switch --flake <repo>#lima@bvmp        # bvmp personal / bvmw work
./trim-generations.sh 2 0 home-manager && sudo nix-collect-garbage -d
```

## Delete
```bash
limactl stop bvm && limactl delete bvm
```

## Notes
- Use `boot`+reboot, not `switch` (live switch fails to stop the busy host-home mount).
- Zscaler is trusted via `~/.zscaler-ca.pem` (`nixos/zscalar.nix`); refresh it when the CA rotates.
- Can't disable Zscaler for the first rebuild? Pre-trust the daemon once:
  `printf '[Service]\nEnvironment="NIX_SSL_CERT_FILE=/Users/janmejay.singh/.zscaler-ca.pem"\n' | sudo tee /etc/systemd/system/nix-daemon.service.d/zscaler.conf && sudo systemctl daemon-reload && sudo systemctl restart nix-daemon`
- Resources (`lima/bvm.yaml`): cpus 12 / 24GiB / 250GiB — sized for `~/ob/vector`.
- Guest user `lima` / home `/home/lima` are pinned in `lima/bvm.yaml` (`user.name`/`user.home`);
  the host home mounts read-only at `/Users/<macUser>`. Changing them needs a VM recreate.
