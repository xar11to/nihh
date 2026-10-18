{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      type=image
      background=${../../extra/loginW.png}
    '')
  ];
}
