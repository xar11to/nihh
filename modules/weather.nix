{ pkgs, ... }:
{
  # `pogoda` — quick weather check for Jizzakh from wttr.in, no API key needed.
  # `pogoda3` gives a 3-day forecast instead of the current conditions.
  home.packages = [
    (pkgs.writeShellScriptBin "pogoda" ''
      exec ${pkgs.curl}/bin/curl -s "wttr.in/Jizzakh?lang=ru&M"
    '')
    (pkgs.writeShellScriptBin "pogoda3" ''
      exec ${pkgs.curl}/bin/curl -s "wttr.in/Jizzakh?lang=ru&M&2"
    '')
  ];
}
