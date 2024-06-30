{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.writeShellApplication {
          name = "moo";
          runtimeInputs = [ pkgs.cowsay ];
          text = "cowsay moo";
        };

        devShells.default = pkgs.mkShell {
          packages = [ self.packages.${system}.default ];
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
