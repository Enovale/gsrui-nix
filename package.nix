{
  config,
  pkgs ? import <nixpkgs> { },
  stdenv,
  lib,
  fetchurl,
  pkg-config,
  addDriverRunpath,
  desktop-file-utils,
  makeWrapper,
  meson,
  ninja,
  libpulseaudio,
  libdrm,
  gpu-screen-recorder,
  libglvnd,
  libX11,
  libXrandr,
  libXcomposite,
  libXcursor,
  libXext,
  libXi,
  libcap,
  hyprland,
  notify,
  wayland,
  wayland-scanner,
  wrapperDir ? "/run/wrappers/bin",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-screen-recorder-ui";
  version = "1.7.1";

  src = fetchurl {
    url = "https://dec05eba.com/snapshot/gpu-screen-recorder-ui.git.${finalAttrs.version}.tar.gz";
    hash = "sha256-wB9iS3MFCeuI+GkXm9WJgu88KfqjKfmaItQk8uItFpw=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    meson
    ninja
    wayland-scanner
  ];

  buildInputs = [
    libpulseaudio
    libdrm
    libX11
    libXrandr
    libXcomposite
    libXcursor
    libXext
    libXi
    libcap
    wayland
  ];

  preFixup =
    let
      gpu-screen-recorder-wrapped = gpu-screen-recorder.override {
        inherit wrapperDir;
      };
    in
    ''
      wrapProgram "$out/bin/gsr-ui" \
        --prefix PATH : ${wrapperDir} \
        --suffix PATH : ${
          lib.makeBinPath [
            hyprland
            notify
            gpu-screen-recorder-wrapped
          ]
        } \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            libglvnd
            addDriverRunpath.driverLink
          ]
        }
    '';

  #postInstall = ''
  #  substituteInPlace $out/lib/systemd/user/gpu-screen-recorder-ui.service \
  #    --replace-fail "gsr-ui" "$out/bin/gsr-ui"
  #'';

  meta = {
    #changelog = "https://git.dec05eba.com/gpu-screen-recorder-ui/tree/com.dec05eba.gpu_screen_recorder.appdata.xml#n82";
    description = "Shadowplay-like frontend for gpu-screen-recorder.";
    homepage = "https://git.dec05eba.com/gpu-screen-recorder-ui/about/";
    license = lib.licenses.gpl3Only;
    mainProgram = "gpu-screen-recorder-ui";
    maintainers = with lib.maintainers; [
      {
        email = "enovale@proton.me";
        name = "enova";
      }
    ];
    platforms = [ "x86_64-linux" ];
  };
})
