{
  description = "Oatmeal, a quiet macOS shortcut confirmation utility";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nox.url = "github:playfairs/nox/v1.2.2-stable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, nox, treefmt-nix }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
      formatterFor = pkgs: import ./nix/formatter.nix { inherit pkgs treefmt-nix; };
    in {
      formatter = forAllSystems (pkgs: formatterFor pkgs);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ pkgs.clang pkgs.swift pkgs.clang-tools pkgs.csharpier nox.packages.${pkgs.system}.default ];
          shellHook = ''
            export SDKROOT="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)"
          '';
        };
      });
    };
}
