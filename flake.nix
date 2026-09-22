{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/26.05";

  outputs = { nixpkgs, ... }@inputs:
  let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in
  {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs { inherit system; };
    in rec {
      oatmeal = pkgs.callPackage ./nix/devshell.nix { inherit inputs; };
      default = oatmeal;
    });
  };    
}

