{ ... }:
{
  environment.variables = {
      NIX_SSL_CERT_FILE = "/etc/nix/ca_cert.pem";
      SSL_CERT_FILE = "/etc/nix/ca_cert.pem";
      REQUEST_CA_BUNDLE = "/etc/nix/ca_cert.pem";
  };
}
