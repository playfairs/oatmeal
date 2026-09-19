{
  description = "Oatmeal, a quiet macOS shortcut confirmation utility";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nox.url = "github:playfairs/nox/v1.2.2-stable";

  outputs = { self, nixpkgs, nox }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ pkgs.clang pkgs.swift pkgs.clang-tools nox.packages.${pkgs.system}.default ];
          shellHook = ''
            export SDKROOT="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)"
          '';
        };
      });
    };
}
