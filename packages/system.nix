{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    intel-media-driver
    intel-vaapi-driver

    git
    vim
    wget

    umu-launcher
    ayugram-desktop

    (lutris.override {
      extraPkgs = pkgs: with pkgs; [
        vulkan-tools
        vulkan-loader
        mesa-demos
      ];
    })

    wineWow64Packages.stable
    winetricks
    mesa-demos

    libreoffice-still
    hunspell

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
