{
  description = "Xar's NixOS configuration (Acer Nitro, Intel+NVIDIA PRIME, KDE Plasma)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative KDE Plasma config (wallpaper, theme, panels, ...) via home-manager
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # `sudo nixos-rebuild switch --flake .#nixos`
      nixosConfigurations.nixos = import ./hosts/nixos inputs;

      formatter.${system} = pkgs.nixfmt-tree;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          self.formatter.${system}
          nixd # Nix language server
          statix # linter
          deadnix # finds unused code
        ];
      };
    };
}
