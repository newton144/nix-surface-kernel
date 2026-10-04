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
      nixpkgs = nixpkgs-unstable;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        #overlays = [
          #nixgl.overlay
          #(self: super: {
            #linux-firmware = fwpin.linux-firmware;
          #})
        #];
      };
      fwpin-pkgs = import fwpin {
        inherit system;
      };
    in {

      nixosModules.default = { config, lib, pkgs, ... }: {
        imports = [
          ({ nixpkgs, ... }: {
            nixpkgs.overlays = [
              (self: super: {
                linux-firmware = fwpin-pkgs.linux-firmware;
              })
            ];
          })
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
        ];
      };

      checks.${system}.my-module-test = pkgs.testers.runNixOSTest {
        name = "my-module-test";
        nodes.machine = { config, pkgs, ... }: {
          # Import your module directly from the flake
          imports = [ self.nixosModules.default ];
          
          # Enable or configure options provided by your module
          #my-service.enable = true; 
        };

        #testScript = ''
          #start_all()
          #machine.wait_for_unit("my-service.service")
          #machine.succeed("curl http://localhost:8080")
        #'';
      };

    };
}
