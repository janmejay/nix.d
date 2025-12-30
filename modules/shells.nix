{ nixpkgs, ...}: 
let
  eachSystem = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ];
in {
  devShells = 
    eachSystem (system: 
     let
       p = nixpkgs.legacyPackages.${system};
     in {
        amm = p.mkShell {
          packages = [ p.ammonite_2_13 ];
        };

        linux = p.stdenv.mkDerivation {
          name = "dev-shell";

          nativeBuildInputs = with p; [
            pkg-config
            ncurses
            flex
            bison
          ];

          shellHook = ''
            echo Src tarball: ${p.linux.src}
          '';
        };

        c = p.mkShell {
          name = "C dev";
          packages = with p; [
            gcc
            gdb
            cmake
            ninja
            jemalloc
            openssl
            lz4
            clang
            llvmPackages.bintools
            rustup
            openssl
            lldb
            gcc
            gawk
            python3
            flex
          ];
          shellHook = ''
            echo C Dev
          '';
        };

        fdb = p.mkShell {
          name = "FoundationDB";

          packages = with p; [
            cmake
            ninja
            mono
            jemalloc
            openssl
            lz4
          ];

          shellHook = ''
            echo FDB
          '';
        };

        plot = p.mkShell {
          name = "plot";
          hardeningDisable = [ "all" ];
          packages = [
            (p.python3.withPackages (python-pkgs: with python-pkgs; [
              pandas
              requests
              numpy
              seaborn
              matplotlib
            ]))
          ];
        };

        work = p.mkShell {
          name = "work";
          hardeningDisable = [ "all" ];
          packages = with p; [
            awscli2
            azure-cli
            kubectl
            kubectx
            minikube
            go_1_25
            delve
            clang
            k9s
            kubernetes-helm
            grpcurl
            gh
            yq
            graphqurl
            visualvm
            unzip
            evcxr
            rustc
            gradle
            openjdk
            protobuf
            lua54Packages.lua
            sqlite
            google-cloud-sdk
            ssm-session-manager-plugin
            socat
          ];
          shellHook = ''
            export KUBECONFIG=$HOME/.kube/config
            exec $HOME/.nix-profile/bin/zsh
          '';
          buildInputs = [
            p.sbt
          ];
        };

        work_fhs = (p.buildFHSEnv {
          name = "work_fhs";
          targetPkgs = pkgs: (with pkgs; [
            awscli2
            kubectl
            kubectx
            minikube
            go_1_25
            virtualenv
          ]);
          multiPkgs = pkgs: (with pkgs; [
            udev
            alsa-lib
          ]);
          runScript = "zsh";
        }).env;
      });
}
