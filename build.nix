{ pkgs, lib, config, modulesPath, ... }:
let
  kernelTarget = pkgs.hostPlatform.linux-kernel.target;
  arch = pkgs.hostPlatform.uname.processor;
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
 
    # INITRD_TMP=$(mktemp -d --tmpdir=.)
    # cd "$INITRD_TMP" 
    # mkdir -p initrd/ssh && cd initrd
    # for i in /home/$SUDO_USER/.ssh/authorized_keys /root/.ssh/authorized_keys /etc/ssh/authorized_keys.d/root; do
    #   if [[ -e $i && -s $i ]]; then 
    #     echo "--------------------------------------------------"
    #     echo "Get SSH key from: $i"
    #     cat $i >> ssh/authorized_keys
    #   fi     
    # done
    # for i in /etc/ssh/ssh_host_*; do cp $i ssh; done
   
    # [[ -n "$1" ]] && echo "--------------------------------------------------" && echo "Downloading AutoRun Script" && curl -Lo autorun.sh "$1"
    # for arg in "''${@:2}"; do echo $arg >> autorunParameters; done      # begin at the second argument
  
    # find | cpio -o -H newc --quiet | gzip -9 > ../extra.gz
    # cd .. && cat extra.gz >> ../${initrdName}
    # cd .. && rm -r "$INITRD_TMP"
    # echo "--------------------------------------------------"
    # echo "Wait..."
    # echo "After SSH connection lost, ssh root@ip and enjoy NixOS!"
    ./${kexec-musl-bin} --kexec-syscall-auto --load ./${kernelName} --initrd=./${initrdName}  --command-line "init=/bin/init ${toString config.boot.kernelParams}"
    ./${kexec-musl-bin} -e
  '';
in
{

  system.build.kexec = pkgs.runCommand "buildkexec" { } ''
    mkdir -p $out
    ln -s ${config.system.build.kernel}/${kernelTarget}         $out/${kernelName}
    ln -s ${config.system.build.initialRamdisk}/initrd.zst      $out/${initrdName}
    ln -s ${kexecScript}                                        $out/${kexecScriptName}
    ln -s ${pkgs.pkgsStatic.kexec-tools}/bin/kexec              $out/${kexec-musl-bin}
  '';
}

