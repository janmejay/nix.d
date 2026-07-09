{ lib, ... }:
{
  home.sessionVariables = {
    NIX_SSL_CERT_FILE = "/etc/nix/ca_cert.pem";
    SSL_CERT_FILE = "/etc/nix/ca_cert.pem";
    REQUEST_CA_BUNDLE = "/etc/nix/ca_cert.pem";
  };

  # Export the macOS keychain CA bundle (incl. the Zscaler root) to ~/.zscaler-ca.pem
  # so the Lima build VM (bvm) reads it via the mounted home — no manual copy. Only
  # public certs are exported (-t certs), so no admin prompt. Generated only when
  # missing; delete the file and re-switch to refresh after a Zscaler CA rotation.
  home.activation.zscalerCaBundle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.zscaler-ca.pem" ]; then
      /usr/bin/security export -t certs -f pemseq \
        -k /System/Library/Keychains/SystemRootCertificates.keychain -o "$HOME/.zscaler-ca.root.pem"
      /usr/bin/security export -t certs -f pemseq \
        -k /Library/Keychains/System.keychain -o "$HOME/.zscaler-ca.system.pem"
      cat "$HOME/.zscaler-ca.root.pem" "$HOME/.zscaler-ca.system.pem" > "$HOME/.zscaler-ca.pem"
      rm -f "$HOME/.zscaler-ca.root.pem" "$HOME/.zscaler-ca.system.pem"
    fi
  '';
}
