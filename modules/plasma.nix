{ pkgs, ... }:
{
  programs.plasma = {
    enable = true;

    workspace = {
      # Point this at any image on disk — swap the path for your own picture.
      # Known caveat (plasma-manager #583): on some Plasma 6.6 point releases
      # this option silently stops re-applying after an upgrade until you
      # log out/in again — if the wallpaper doesn't change after a rebuild,
      # that's the first thing to check.
      wallpaper = "/home/xaruto/Pictures/wallpaper.jpg";
    };
  };
}
