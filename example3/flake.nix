{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          packages.default = pkgs.callPackage ./pcaddy.nix { };

          devShells.default = pkgs.mkShell {
            packages = [ self.packages.${system}.default ];
          };

          formatter = pkgs.nixpkgs-fmt;
        }) // {
      # nix build .#nixosConfigurations.example3.config.system.build.toplevel
      nixosConfigurations.example3 = nixpkgs.lib.nixosSystem {
        modules = [
          ./hardware.nix
          ./service.nix
        ];
      };
    };
}
