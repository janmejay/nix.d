{
  description = "NixConfig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-lima = {
      url = "github:nixos-lima/nixos-lima/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, nix-darwin, nix-homebrew, home-manager, nixvim, sops-nix, ... }@inputs:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      pkgsl = nixpkgs.legacyPackages.${linuxSystem};
      pkgsd = nixpkgs.legacyPackages.${darwinSystem};

      home-mgr-cfg-l = email : home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsl;
          extraSpecialArgs = { inherit inputs email; user = "janmejay"; };
          modules = [ 
            ({ ... }: {
              home.username = "janmejay";
              home.homeDirectory = "/home/janmejay";
            })
           ./home-manager/local_linux.nix 
           nixvim.homeModules.nixvim
          ];
      };

      linux-cfg = cfg-file : nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { inherit inputs; };
        modules = [ cfg-file sops-nix.nixosModules.sops ];
      };

      darwin-cfg = {user, host, addons}: nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        modules = [ 
          ./darwin/base.nix
          nix-homebrew.darwinModules.nix-homebrew {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = user;
              taps = {
                "homebrew/core" = inputs.homebrew-core;
                "homebrew/cask" = inputs.homebrew-cask;
                "homebrew/bundle" = inputs.homebrew-bundle;
              };
              mutableTaps = false;
              autoMigrate = true;
            };
          }
        ] ++ addons;
        specialArgs = { inherit user host inputs; };
      };

      home-mgr-cfg-d = {user, email, addons, ai ? "copilot"} : home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsd;
        extraSpecialArgs = { inherit inputs nixvim user ai email; };
        modules = [ 
            ({ ... }: {
              home.username = user;
              home.homeDirectory = "/Users/${user}";
            })
            ./home-manager/darwin.nix 
            nixvim.homeModules.nixvim
        ] ++ addons;
      };
    in {

      # build: 'nixos-rebuild --flake .#the-hostname'
      nixosConfigurations = {
        lenovo = linux-cfg ./nixos/lenovo/configuration.nix;
        dell = linux-cfg ./nixos/dell/configuration.nix;
        obsl = linux-cfg ./nixos/obsl/configuration.nix;

        # Headless aarch64 NixOS build VM run via Lima (see lima/bvm.yaml,
        # bvm.readme.md). Rebuilt from inside the VM against this flake.lock.
        bvm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.nixos-lima.nixosModules.lima
            ./nixos/bvm/configuration.nix
            ./nixos/zscalar.nix
          ];
        };
      };

      darwinConfigurations = {
        jpl = darwin-cfg { user = "janmejay"; host = "jpl"; addons = []; };
        js1 = darwin-cfg { user = "janmejay.singh"; host = "HV9JX62PP7"; addons = [./darwin/zscalar.nix];};
      };	

      # Available through 'home-manager --flake .#janmejay@jnix'
      homeConfigurations = {
        "janmejay@jnix" = home-mgr-cfg-l "singh.janmejay@gmail.com";
        "janmejay@lenovo" = home-mgr-cfg-l "singh.janmejay@gmail.com";
        "janmejay@dell" = home-mgr-cfg-l "singh.janmejay@gmail.com";
        "janmejay@obsl" = home-mgr-cfg-l "singh.janmejay@gmail.com";
        "janmejay@jpl" = home-mgr-cfg-d { user = "janmejay"; email = "singh.janmejay@gmail.com"; ai = "copilot"; addons = []; };
        "janmejay@js1" = home-mgr-cfg-d { user = "janmejay.singh"; email = "janmejay.singh@sentinelone.com"; ai = "copilot"; addons = [./home-manager/addons/zscalar.nix]; };

        # Lima build VM: guest user is `lima` with home /home/lima.guest (fixed by
        # the nixos-lima image). Reuses ./home-manager/local_linux.nix via bvm.nix.
        # Verify home dir in the VM with `echo $HOME` and adjust if it differs.
        "lima@bvm" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          extraSpecialArgs = { inherit inputs; email = "janmejay.singh@sentinelone.com"; user = "lima"; };
          modules = [
            ({ ... }: {
              home.username = "lima";
              home.homeDirectory = "/home/lima.guest";
            })
            ./home-manager/bvm.nix
            nixvim.homeModules.nixvim
          ];
        };
      };

      devShells = (import ./modules/shells.nix {nixpkgs = nixpkgs;}).devShells;
   };
}
