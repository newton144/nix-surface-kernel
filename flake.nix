{
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # before linux-firmware was broken
    fwpin.url = "github:NixOS/nixpkgs/6ed8c0b0656a3919a0b46f35a54d7ec7e19dd311";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    #lanzaboote = {
      #url = "github:nix-community/lanzaboote";
      #inputs.nixpkgs.follows = "nixpkgs-stable";
    #};
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
        overlays = [
          nixgl.overlay
          (self: super: {
            linux-firmware = fwpin.linux-firmware;
          })
        ];
      };
      fwpin-pkgs = import fwpin {
        inherit system;
      };
    in {
      surface = { config, lib, pkgs, ... }: {
        #options.services.my-service = {
          #enable = lib.mkEnableOption "my custom service";
        #};
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

        #config = {
          #environment.systemPackages = [ pkgs.hello ];
        #};
      };

      #nixpad = lib.nixosSystem {
        #inherit system;
        #modules = [
          #lanzaboote.nixosModules.lanzaboote
          #(import ./hardware-configuration.nix)
          #(import ./nixpad.nix)
          #(import ./configuration.nix {
            #inherit inputs pkgs nixpkgs lib;
          #})
        #];
      #};
    };
}
