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
      rev = "42e9fceb2144c0a8901f380fc60ef1702fe51193";
      hash = "sha256-tY5+YBxw5B/IIS+1IM92iMkS0ddTQ6dOc2NmWrbG+gg=";
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
