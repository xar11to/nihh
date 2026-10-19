{ config, pkgs, lib, ... }:
{
  imports = [
    # Hardware scan — untouched
    ./hardware-configuration.nix

    # System package list
    ../../packages/system.nix

    # Shared config across all of Xar's hosts (currently just this one)
    ../shared

    # NVIDIA PRIME / i915 setup
    ./gpu.nix

    # Eduroam wifi
    ./eduroam.nix

    # Login page wallpaper
    ./sddm.nix
  ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  console.keyMap = "ru";

  zramSwap.enable = true;   # no swap partition, so zram instead

  # Configure keymap in X11 — RU/US toggle on Win+Space
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:win_space_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Color profiles
  services.colord.enable = true;

  # Sound via pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pipewire."99-force-rate" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 48000 ];
      };
    };
  };

  # For external I2C-controlled peripherals (e.g. ddcutil)
  hardware.i2c.enable = true;

  users.users."xar11to" = {
    isNormalUser = true;
    description = "xar11to";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
    packages = with pkgs; [
      kdePackages.kate
      thunderbird
    ];
  };

  programs.firefox.enable = true;

  programs.nix-ld.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.dconf.enable = true;
  
  # Don't drop into emergency mode if the Lexar is missing
  fileSystems."/mnt/games".options = [ "nofail" "x-systemd.device-timeout=5s" ];

  #console.keyMap = "us";    # was "ru": TTY has no layout toggle, so passwords typed there come out wrong

  fonts.packages = with pkgs; [
    liberation_ttf
    carlito
    caladea

    # Windows-metric-compatible fonts many Wine/Proton games and launchers
    # expect (Arial, Times New Roman, Tahoma, Segoe UI, Calibri, ...).
    # allowUnfree is already on (see hosts/shared/default.nix) — required
    # for these two, since they package Microsoft's own font files.
    corefonts
    vista-fonts

    # Broad Unicode fallback so missing glyphs (CJK, symbols, emoji) show up
    # as actual characters instead of "tofu" boxes in games, Discord, etc.
    dejavu_fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  environment.variables.EDITOR = "vim";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Leave this at the release of your first install.
  system.stateVersion = "26.05";
}
