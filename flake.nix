{
  description = "Oatmeal, a quiet macOS shortcut confirmation utility";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nox.url = "github:playfairs/nox/v1.2.2-stable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nox,
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
      formatterFor = pkgs: import ./nix/formatter.nix { inherit pkgs; };
    in
    {
      formatter = forAllSystems (pkgs: formatterFor pkgs);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.clang
            pkgs.swift
            pkgs.clang-tools
            pkgs.csharpier
            pkgs.swift-format
            nox.packages.${pkgs.system}.default
          ];
          shellHook = ''
            export SDKROOT="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)"
          '';
        };
      });
    };
}
