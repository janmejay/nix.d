{ ... }:
# Zscaler TLS-inspection support for the Lima VM.
#
# Zscaler MITMs HTTPS with its own CA; the VM's traffic NATs through the Mac, so it
# sees that cert too and nix/git/curl fail to verify (cache.nixos.org narinfo errors).
#
# Point nix (client AND daemon — the daemon does substituter downloads) plus git/curl
# at a CA bundle that includes the Zscaler root. Regenerate the bundle on the Mac per
# README.md ("Work with zscalar") and copy it to ~/.zscaler-ca.pem there; the VM reads
# it via the read-only `~` mount. The bundle must be complete (standard roots + Zscaler),
# because *_CERT_FILE replaces the default trust — the Mac's /etc/nix/ca_cert.pem is.
let
  caBundle = "/Users/janmejay.singh/.zscaler-ca.pem";
in {
  nix.settings.ssl-cert-file = caBundle;
  systemd.services.nix-daemon.environment.NIX_SSL_CERT_FILE = caBundle;

  environment.variables = {
    NIX_SSL_CERT_FILE = caBundle;
    SSL_CERT_FILE = caBundle;
    REQUEST_CA_BUNDLE = caBundle;
    GIT_SSL_CAINFO = caBundle;
  };
}
