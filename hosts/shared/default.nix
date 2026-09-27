{ pkgs, lib, ... }:
{
  imports = [
    ./bootloader.nix
    ./network.nix
  ];

  # Set your time zone.
  time.timeZone = "Asia/Tashkent";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Allow unfree packages (needed for the NVIDIA driver, Steam, etc.)
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and nix-command experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
