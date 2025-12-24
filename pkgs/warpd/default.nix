{
  stdenv,
  lib,
  fetchFromGitHub,
  pkgs,
}:
let
  warpd = stdenv.mkDerivation rec {
    pname = "warpd";
    version = "1.3.5-osx";

    src = fetchFromGitHub {
      owner = "janmejay";
      repo = "warpd";
      rev = "71196910f8795a715ef35dc9067474c00da2b1e9";
      hash = "sha256-b6ccfY31jz+iG2BcRnRAorcp6ETMMO38oFfyx/GW2tc=";
    };

    buildInputs = with pkgs; [
      apple-sdk
    ];

    buildPhase = ''
      PREFIX=${placeholder "out"} DESTDIR="" make
    '';

    installPhase = ''
      install -D -m755 bin/warpd $out/bin/warpd
    '';

    enableParallelBuilding = true;


    meta = with lib; {
      description = "A modal keyboard driven interface for mouse manipulation.";
      license = licenses.mit;
      maintainers = with maintainers; [peterhoeg];
      platforms = platforms.darwin;
    };
  };
in
warpd
