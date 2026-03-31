{
  description = "Complete NixOS and Home Manager Flake";

  inputs = {
    # System Packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # User Management
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
    let
      system = "x86_64-linux"; # Change to aarch64-linux if on ARM
      user = "noah";
      hostname = "chronos";
    in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = { inherit inputs user hostname; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit user hostname; };
          home-manager.backupFileExtension = ".bak";
          home-manager.users.${user} = import ./home-manager/home.nix;
        }
      ];
    };
  };
}
