{ pkgs, treefmt-nix }:
(treefmt-nix.lib.evalModule pkgs (_: {
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    clang-format.enable = true;
    csharpier.enable = true;
  };

  settings.formatter.clang-format = {
    options = [ "--style=file" ];
  };
})).config.build.wrapper