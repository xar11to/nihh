{ ... }:
let
  files = builtins.readDir ../modules;
  file_names = builtins.attrNames files;
  modules_list = builtins.map (el: ../modules/${el}) file_names;
in
{
  modules = modules_list;
}
