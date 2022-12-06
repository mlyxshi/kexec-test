{ config, pkgs, lib, nixpkgs, ... }: {

  documentation.enable = false;
  documentation.nixos.enable = false;
  programs.command-not-found.enable = false;

  nix = {
    registry.nixpkgs.flake = nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "http://cache.mlyxshi.com" ];
      trusted-public-keys = [ "cache.mlyxshi.com:qbWevQEhY/rV6wa21Jaivh+Lw2AArTFwCB2J6ll4xOI=" ];
    };
  };


  nixpkgs.config.allowUnfree = true;

  users.users.root = {
    hashedPassword = "$6$fwJZwHNLE640VkQd$SrYMjayP9fofIncuz3ehVLpfwGlpUj0NFZSssSy8GcIXIbDKI4JnrgfMZxSw5vxPkXkAEL/ktm3UZOyPMzA.p0";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" ];
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "bat";
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    bat
    neovim-unwrapped
    lf
  ];

  environment.etc."lf/lfrc".text = ''
    set hidden true
    set number true
    set drawbox true
    set dircounts true
    set incsearch true
    set period 1
    map Q   quit
    map D   delete
    cmd open ''${{ $EDITOR "$f"}}
  '';

  environment.shellAliases = {
    r = "lf"; # like ranger 
    v = "nvim";
  };

  boot.kernel.sysctl."vm.swappiness" = 100;
  zramSwap.enable = true; # Enable zram, otherwise machine below 1GB RAM will OOM when evaluating nix flake config
  zramSwap.memoryPercent = 200;
  zramSwap.memoryMax = 2 * 1024 * 1024 * 1024;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = lib.trivial.release;


  systemd.network.wait-online.anyInterface = true;
  services.getty.autologinUser = "root";

  networking = {
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = false;
  };

  systemd.network.networks = {
    dhcp = {
      # Ampere A1[aarch64]   # E2.1.Micro[x86_64]
      name = if pkgs.hostPlatform.isAarch64 then "enp0s3" else "ens3";
      DHCP = "yes";
    };
  };

  system.activationScripts."diff-closures".text = ''
    [[ -e "/run/current-system" ]] && ${pkgs.nix}/bin/nix store  diff-closures /run/current-system "$systemConfig"
  '';

}