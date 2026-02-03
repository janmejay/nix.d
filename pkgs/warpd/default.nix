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
      rev = "fd0f01e366706c8cab12a973b4bc3b2c34f2228e";
      hash = "sha256-g6knKrg9dZ3ewpdSQnNs6fBTYMcRrW48j93m6h7kFpI=";
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
