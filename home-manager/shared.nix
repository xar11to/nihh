{ ... }:
let
  modules = import ../lib/folder.nix { };
in
{
  imports = modules.modules;

  # This value determines the home-manager release your configuration is
  # compatible with. Leave it at the release you first set this up on.
  home.stateVersion = "26.05";
}
