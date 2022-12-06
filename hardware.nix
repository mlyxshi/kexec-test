{ modulesPath, pkgs, lib, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "ext4";
  };

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 3;
  boot.loader.efi.canTouchEfiVariables = true;
}
