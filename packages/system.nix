{ pkgs, inputs, ... }:
let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
in
{
  environment.systemPackages = with pkgs; [
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    intel-media-driver
    intel-vaapi-driver
    mesa-demos

    git
    vim
    wget
    
    cloudflare-warp

    qbittorrent
    mpv
   
    lutris
    umu-launcher
    ayugram-desktop
    vesktop

    wineWow64Packages.stable
    winetricks

    libreoffice-still
    hunspell

    unstable.jetbrains-toolbox

    (python3.withPackages (ps: with ps; [
      dbus-python
    ]))

    (pkgs.callPackage ./opera-gx.nix { })

    (pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
      exec "$@"
    '')
  ];
}
