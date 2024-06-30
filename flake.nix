{
  outputs =
    { self
    , nixpkgs
    , utils
    , ...
    } @ inputs:
    utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        examplesFor = attr: lib.mapAttrs
          (n: _v: inputs.${n}.${attr}.${system}.default)
          (lib.filterAttrs (n: _v: lib.hasPrefix "example" n) inputs);
      in
      {
        packages = examplesFor "packages";

        devShells = examplesFor "devShells" // {
          default = pkgs.mkShell {
            packages = with pkgs; [
              typst
            ];
          };
        };

        formatter = pkgs.writeShellScriptBin "formatter" ''
          set -eoux pipefail
          shopt -s globstar
          ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt .
          ${pkgs.typstfmt}/bin/typstfmt **/*.typ
        '';
      }) // {
      hydraJobs = {
        inherit (self)
          packages devShells;
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";

    example1 = {
      url = "github:stepbrobd/nixology?dir=example1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
    example2 = {
      url = "github:stepbrobd/nixology?dir=example2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
    example3 = {
      url = "github:stepbrobd/nixology?dir=example3";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
  };
}
