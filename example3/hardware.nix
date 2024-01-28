{ lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];

  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
