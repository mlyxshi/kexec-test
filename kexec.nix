{ pkgs, lib, config, modulesPath, ... }:{

  imports = [
    ./fileSystem.nix
    ./strip.nix
  ];

  # boot.initrd.systemd.enable = true;


  system.stateVersion = lib.trivial.release;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  boot.initrd.availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "virtio_balloon" "virtio_console" ];
  # remove default kernel modules: https://github.com/NixOS/nixpkgs/blob/660e7737851506374da39c0fa550c202c824a17c/nixos/modules/system/boot/kernel.nix#L214
  boot.initrd.includeDefaultModules = false;

  networking.useNetworkd = true;
  systemd.network.wait-online.anyInterface = true;
  services.getty.autologinUser = "root";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe"
  ];

  system.build.kexec = pkgs.writeScript "kexec-boot" ''
    #!/usr/bin/env bash
    cp ${config.system.build.kernel}/bzImage  .
    cp ${config.system.build.netbootRamdisk}/initrd.zst .
     
    echo "--------------------------------------------------"
    echo "Wait..."
    echo "After SSH connection lost, ssh root@ip and enjoy NixOS!"
    kexec --kexec-syscall-auto --load ./bzImage --initrd=./initrd.zst --command-line "init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}"
    kexec -e
  '';
}



# Reference: 
# initrd
# https://github.com/nix-community/nixos-images/blob/main/nix/kexec-installer/module.nix
# https://unix.stackexchange.com/questions/163346/why-is-it-that-my-initrd-only-has-one-directory-namely-kernel
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/stage-1-init.sh
# https://landley.net/writing/rootfs-intro.html
# https://landley.net/writing/rootfs-howto.html
# https://landley.net/writing/rootfs-programming.html
# https://man7.org/linux/man-pages/man7/bootup.7.html