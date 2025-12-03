_Bootstrap_

* general nixos process: layout partitions, mount under /mnt, `nixos-generate-config --root /mnt`
# nix-env -f '<nixpkgs>' -iA emacs git

* copy age-key to root-readable /mnt/var/lib/sops-nix/keys.txt

# git clone https://github.com/janmejay/nixos.d
* move nixos config in /mnt/etc/nixos to nixos/<env> dir
  and modify flake.nix, modify configuration to include common-config

# nixos-install --flake .#<host>
* set password for root on prompt
* IMPORTANT: also set password for `janmejay` and `guest` and only then reboot!

* after reboot DO-NOT-LOGIN to xsession, instead get a shell session move the nixos.d dir to ~/projects, fix ownership

$ export NIX_CONFIG="experimental-features = nix-command flakes"
$ nix shell nixpkgs#home-manager
$ sudo nixos-rebuild switch --flake .#<host>
$ home-manager switch --flake .#janmejay@<hostname>


_Upgrade_

$ nix flake update
$ nix flake check
$ sudo nixos-rebuild switch --flake .#<host>
$ home-manager switch --flake .#janmejay@<hostname>


_GC_
$ nix-env --list-generations
$ ./trim-generations.sh 2 0 home-manager
$ sudo nix-collect-garbage -d
$ sudo nixos-rebuild switch --flake .#obsl
$ nixos-rebuild list-generations


# Nix darwin
* Install with determinate installer (no to avoid determinate nix)
* Create flake
  * nix run nix-darwin/master#darwin-rebuild --switch --flake .#js1
  * home-manager switch --flake .#janmejay@js1
* Exit `zscalar` to have rebuild working
* Rebuild
  * sudo darwin-rebuild switch --flake .#js1
  * (same home-mgr cmd)


# Work with zscalar
* security export -t certs -f pemseq -k /Library/Keychains/System.keychain -o /tmp/certs-system.pem
* security export -t certs -f pemseq -k /System/Library/Keychains/SystemRootCertificates.keychain -o /tmp/certs-root.pem
* cat /tmp/certs-root.pem /tmp/certs-system.pem > /tmp/ca_cert.pem
* sudo mv /tmp/ca_cert.pem /etc/nix/
* sudo vim /Library/LaunchDaemons/org.nixos.nix-daemon.plist
* Ensure following entries 
  ```
    <key>EnvironmentVariables</key>
    <dict>
      <key>NIX_SSL_CERT_FILE</key>
      <string>/etc/nix/ca_cert.pem</string>
      <key>SSL_CERT_FILE</key>
      <string>/etc/nix/ca_cert.pem</string>
      <key>REQUEST_CA_BUNDLE</key>
      <string>/etc/nix/ca_cert.pem</string>
    </dict>
  ```
* Restart daemon
  ```
    $ sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
    $ sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
  ```
* Reboot (for good measure)
* Export env-vars
  ```
    export NIX_SSL_CERT_FILE=/etc/nix/ca_cert.pem
    export SSL_CERT_FILE=/etc/nix/ca_cert.pem
  ```
* Add this to nix config?
  ```
    environment.variables = {
        NIX_SSL_CERT_FILE = "/etc/nix/ca_cert.pem";
        SSL_CERT_FILE = "/etc/nix/ca_cert.pem";
        REQUEST_CA_BUNDLE = "/etc/nix/ca_cert.pem";
    };
  ```

# Get copyq working
* xattr -rd com.apple.quarantine /Applications/CopyQ.app
* codesign -f --deep -s - /Applications/CopyQ.app
* xattr -d com.apple.quarantine /Applications/"CopyQ.app"
