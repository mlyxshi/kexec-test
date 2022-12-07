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
  };

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = lib.trivial.release;


  systemd.network.wait-online.anyInterface = true;
  services.getty.autologinUser = "root";

  networking = {
    hostName = "test";
    useNetworkd = true;
    useDHCP = true;
    firewall.enable = false;
    usePredictableInterfaceNames = false;
  };

}