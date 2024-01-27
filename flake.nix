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
        packages = lib.genAttrs
          (lib.remove null
            (lib.forEach (builtins.attrNames inputs) (n:
              if lib.hasPrefix "example" n
              then n
              else null
            )))
          (ex: inputs.${ex}.packages.${system}.default);

        formatter = pkgs.nixpkgs-fmt;
      });

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    example1 = {
      url = "path:./example1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    example2 = {
      url = "path:./example2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
}
