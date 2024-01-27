{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.writeShellApplication {
          name = "cheese";
          runtimeInputs = [ pkgs.cowsay ];
          text = "cowsay cheese";
        };

        devShells.default = pkgs.mkShell {
          packages = [ self.packages.${system}.default ];
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
