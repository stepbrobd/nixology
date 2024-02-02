{ lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];

  # build/boot w/ qumu vm with nixos-rebuild build-vm
  # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
  boot = {
    # pkgs.linuxPackages, takes a derivation, so you can BYO
    kernelPackages = pkgs.linuxPackages_6_7;

    # pkgs.linuxKernel.packages.linux_6_7.*
    boot.extraModulePackages = with config.boot.kernelPackages; [ ];

    # https://nixos.wiki/wiki/Linux_kernel
    boot.kernelParams = [ /* loglevel, systemd-boot, ... */ ];

    # kernel modules
    # boot.kernelModules = [ "yourmodulename" ]; # auto load on boot
    # boot.extraModulePackages = [ yourmodulename ]; # manual load/remove w/ modprobe
  };

  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
