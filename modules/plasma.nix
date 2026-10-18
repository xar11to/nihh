{ pkgs, ... }:
{
  programs.plasma = {
    enable = true;

    workspace.wallpaper = ../extra/wallpaper.png;

    kscreenlocker.appearance.wallpaper = ../extra/loginW.png;
  };
}
