{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.test = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
         ./nix-dabei.nix
         ./build.nix
      ];
      specialArgs = { inherit nixpkgs; };
    };
  };

}
