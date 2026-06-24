{ nixpkgs, ...}: 
let
  eachSystem = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ];
in {
  devShells = 
    eachSystem (system: 
     let
       p = nixpkgs.legacyPackages.${system};
       work_pkgs = with p; [
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
            (google-cloud-sdk.withExtraComponents
             (with google-cloud-sdk.components; [
              gke-gcloud-auth-plugin
             ]))
            ssm-session-manager-plugin
            socat
            colima
            docker
            docker-compose
            python312Packages.virtualenv
            pstree
            jwt-cli
            python313Packages.tox
          ];
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

        ob = p.mkShell {
          name = "ob";
          hardeningDisable = [ "all" ];
          packages = work_pkgs;
          shellHook = ''
            export KUBECONFIG=$HOME/.kube/ob-config
            export OBS_K8S_SOCKS_PROXY=socks5://localhost:5000
            export AWS_PROFILE=ob
            exec ${if system == "aarch64-darwin" then "/bin/zsh" else "$HOME/.nix-profile/bin/zsh"}
          '';
          buildInputs = [
            p.sbt
          ];
        };

        ob-dev = p.mkShell {
          name = "ob-dv";
          hardeningDisable = [ "all" ];
          packages = work_pkgs;
          shellHook = ''
            export KUBECONFIG=$HOME/.kube/ob-dev-config
            export AWS_PROFILE=ob-dev
            exec ${if system == "aarch64-darwin" then "/bin/zsh" else "$HOME/.nix-profile/bin/zsh"}
          '';
          buildInputs = [
            p.sbt
          ];
        };

        s1 = p.mkShell {
          name = "s1";
          hardeningDisable = [ "all" ];
          # curl https://raw.githubusercontent.com/scalyr/scalyr-tool/master/scalyr > ~/ob/tools/scalyr
          packages = work_pkgs ++ [
            p.postgresql
            p.kubelogin-oidc
          ];
          shellHook = ''
            export KUBECONFIG=$HOME/.kube/eks-config
            . ~/ob/.sec/env.sh
            PATH=$PATH:~/ob/tools
            exec ${if system == "aarch64-darwin" then "/bin/zsh" else "$HOME/.nix-profile/bin/zsh"}
          '';
        };
    });
}
