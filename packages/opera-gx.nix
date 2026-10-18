{
  alsa-lib,
  atk,
  cairo,
  cups,
  curl,
  dbus,
  dpkg,
  expat,
  fetchurl,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  gtk4,
  lib,
  libX11,
  libxcb,
  libXScrnSaver,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXtst,
  libdrm,
  libnotify,
  libpulseaudio,
  libuuid,
  libxshmfence,
  libgbm,
  libglvnd,
  nspr,
  nss,
  pango,
  stdenv,
  systemd,
  at-spi2-atk,
  at-spi2-core,
  autoPatchelfHook,
  wrapGAppsHook3,
  qt6,
  proprietaryCodecs ? false,
  vivaldi-ffmpeg-codecs,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "opera-gx";
  version = "137.0.6036.65";

  src = fetchurl {
    url = "https://download3.operacdn.com/ftp/pub/opera_gx/${finalAttrs.version}/linux/opera-gx-stable_${finalAttrs.version}_amd64.deb";
    hash = "sha256-ar+qYbEfOcGZolRSFDR+utbeKqNmHJjkpnLx/JQHTzA=";
  };
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    curl
    dbus
    expat
    fontconfig.lib
    freetype
    gdk-pixbuf
    glib
    gtk3
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libdrm
    libglvnd
    libnotify
    libuuid
    libxcb
    libxshmfence
    libgbm
    nspr
    nss
    pango
    (lib.getLib stdenv.cc.cc)
    qt6.qtbase
  ];

  runtimeDependencies = [
    # Works fine without this except there is no sound.
    libpulseaudio.out

    # GL/EGL loader, dlopen'd at runtime by ANGLE. Without it the GPU process
    # crashes (libEGL.so.1 not found) and the browser falls back to software
    # rendering.
    libglvnd

    # This is a little tricky. Without it the app starts then crashes. Then it
    # brings up the crash report, which also crashes. `strace -f` hints at a
    # missing libudev.so.0.
    (lib.getLib systemd)

    # Error at startup:
    # "Illegal instruction (core dumped)"
    gtk3
    gtk4
  ]
  ++ lib.optionals proprietaryCodecs [ vivaldi-ffmpeg-codecs ];

  dontWrapGApps = true;

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r usr $out
    cp -r usr/share $out/share
    # we already using QT6, autopatchelf wants to patch this as well
    find $out -name "libqt5_shim.so" -exec rm {} +
    ln -s $out/usr/bin/opera-gx $out/bin/opera-gx
    runHook postInstall
  '';

  meta = {
    homepage = "https://www.opera.com";
    description = "Faster, safer and smarter web browser";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ vunnyso ];
  };
})
