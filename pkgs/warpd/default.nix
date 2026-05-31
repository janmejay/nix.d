{
  stdenv,
  lib,
  fetchFromGitHub,
  pkgs,
}:
let
  warpd = stdenv.mkDerivation rec {
    pname = "warpd";
    version = "1.3.5-osx-dbg";

    src = fetchFromGitHub {
      owner = "janmejay";
      repo = "warpd";
      rev = "4e312e731d568260cc4b81895f8050c1c7f2871b";
      hash = "sha256-DoHMF4Lsux2ppTMBeuvtx25n6OANxBM3oC/Gk2SM5SU=";
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
