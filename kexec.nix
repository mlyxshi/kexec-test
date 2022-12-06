{ pkgs, lib, config, modulesPath, ... }:
let
  kernelTarget = pkgs.hostPlatform.linux-kernel.target;
  arch = pkgs.hostPlatform.uname.processor; #https://github.com/NixOS/nixpkgs/blob/93de6bf9ed923bf2d0991db61c2fd127f6e984ae/lib/systems/default.nix#L103
  kernelName = "${kernelTarget}-${arch}";
  initrdName = "initrd-${arch}.zst";
  kexecScriptName = "kexec-${arch}";
  kexec-musl-bin = "kexec-musl-${arch}";

  kexecScript = pkgs.writeScript "kexec-boot" ''
    #!/usr/bin/env bash
    set -e   

    echo "Downloading kexec-musl-bin" && curl -LO https://github.com/mlyxshi/kexec-test/releases/download/latest/${kexec-musl-bin} && chmod +x ./${kexec-musl-bin}
    echo "Downloading initrd" && curl -LO https://github.com/mlyxshi/kexec-test/releases/download/latest/${initrdName}
    echo "Downloading kernel" && curl -LO https://github.com/mlyxshi/kexec-test/releases/download/latest/${kernelName}
 
    echo "--------------------------------------------------"
    echo "Wait..."
    echo "After SSH connection lost, ssh root@ip and enjoy NixOS!"
    ./${kexec-musl-bin} --kexec-syscall-auto --load ./${kernelName} --initrd=./${initrdName}  --command-line "init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}"
    ./${kexec-musl-bin} -e
  '';
in
{

  imports = [
    ./fileSystem.nix
    ./strip.nix
    ./kernelModule.nix
  ];

  system.stateVersion = lib.trivial.release;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.initrd.systemd.enable = true;

  networking.useNetworkd = true;
  systemd.network.wait-online.anyInterface = true;
  services.getty.autologinUser = "root";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe"
  ];

  system.build.kexec = pkgs.runCommand "buildkexec" { } ''
    mkdir -p $out
    ln -s ${config.system.build.kernel}/${kernelTarget}         $out/${kernelName}
    ln -s ${config.system.build.netbootRamdisk}/initrd.zst      $out/${initrdName}
    ln -s ${kexecScript}                                        $out/${kexecScriptName}
    ln -s ${pkgs.pkgsStatic.kexec-tools}/bin/kexec              $out/${kexec-musl-bin}
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