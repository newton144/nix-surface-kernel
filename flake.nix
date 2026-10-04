{
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # before linux-firmware was broken
    fwpin.url = "github:NixOS/nixpkgs/6ed8c0b0656a3919a0b46f35a54d7ec7e19dd311";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-stable, nixos-hardware, nixgl, fwpin }@inputs:
    let
      lib = nixpkgs-unstable.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs-stable.legacyPackages.${system};
      fwpin-pkgs = import fwpin {
        inherit system;
      };
    in {

      nixosModules.default = { config, lib, pkgs, ... }: {
        imports = [
          ({ nixpkgs, ... }: {
            nixpkgs.overlays = lib.mkForce [
              (self: super: {
                linux-firmware = fwpin-pkgs.linux-firmware;
              })
            ];
          })
          #nixos-hardware.nixosModules.microsoft-surface-pro-intel
        ];
      };

      checks.${system}.my-module-test = pkgs.testers.runNixOSTest {
        name = "my-module-test";
        nodes.machine = { config, pkgs, ... }: {
          imports = [ self.nixosModules.default ];
        };
        testScript = ''
        '';
      };

    };
}
