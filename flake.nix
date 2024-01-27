{
  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    } @ inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = nixpkgs.lib;
      in
      {
        packages = lib.mapAttrs
          (n: _v: inputs.${n}.packages.${system}.default)
          (lib.filterAttrs (n: _v: lib.hasPrefix "example" n) inputs);

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            typst
          ];
        };

        formatter = pkgs.writeShellScriptBin "formatter" ''
          set -eoux pipefail
          shopt -s globstar
          ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt .
          ${pkgs.typstfmt}/bin/typstfmt **/*.typ
        '';
      });

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    example1 = {
      url = "path:example1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    example2 = {
      url = "path:example2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
}
