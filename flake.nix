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

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim = {
      url = "github:nix-community/nixvim";
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

      home-mgr-cfg-l = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsl;
          extraSpecialArgs = { inherit inputs; };
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
            };
          }
        ] ++ addons;
        specialArgs = { inherit user host inputs; };
      };

      home-mgr-cfg-d = {user, addons} : home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsd;
        extraSpecialArgs = { inherit inputs nixvim user; };
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
        jnix = linux-cfg ./nixos/jnix/configuration.nix;
        lenovo = linux-cfg ./nixos/lenovo/configuration.nix;
        dell = linux-cfg ./nixos/dell/configuration.nix;
        obsl = linux-cfg ./nixos/obsl/configuration.nix;
      };

      darwinConfigurations = {
        jpl = darwin-cfg { user = "janmejay"; host = "jpl"; addons = []; };
        js1 = darwin-cfg { user = "janmejay.singh"; host = "LCY79567W2"; addons = [./darwin/zscalar.nix];};
      };	

      # Available through 'home-manager --flake .#janmejay@jnix'
      homeConfigurations = {
        "janmejay@jnix" = home-mgr-cfg-l;
        "janmejay@lenovo" = home-mgr-cfg-l;
        "janmejay@dell" = home-mgr-cfg-l;
        "janmejay@obsl" = home-mgr-cfg-l;
        "janmejay@jpl" = home-mgr-cfg-d { user = "janmejay"; addons = []; };
        "janmejay@js1" = home-mgr-cfg-d { user = "janmejay.singh"; addons = [./home-manager/addons/zscalar.nix]; }; 
      };

      devShells = (import ./modules/shells.nix {nixpkgs = nixpkgs;}).devShells;
   };
}
