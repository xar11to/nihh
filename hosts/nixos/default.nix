{
  nixpkgs,
  home-manager,
  plasma-manager,
  ...
}@inputs:
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
  }
  // {
    hostname = "nixos";
  };

  modules = [
    ./configuration.nix

    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        # Move pre-existing files (e.g. old fontconfig/kdeglobals) aside as
        # *.backup instead of aborting activation on a collision.
        backupFileExtension = "backup";

        sharedModules = [
          plasma-manager.homeModules.plasma-manager
        ];

        extraSpecialArgs = { inherit inputs; };
        users.xaruto = import ../../home-manager/xaruto-home.nix;
      };
    }
  ];
}
