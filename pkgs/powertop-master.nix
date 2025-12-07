{
  lib,
  stdenv,
  autoconf-archive,
  autoreconfHook,
  fetchFromGitHub,
  gettext,
  libnl,
  libtraceevent,
  libtracefs,
  ncurses,
  pciutils,
  pkg-config,
  xorg,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "powertop";
  version = "master";

  src = fetchFromGitHub {
    owner = "fenrus75";
    repo = "powertop";
    rev = "master";
    hash = "sha256-OrDhavETzXoM6p66owFifKXv5wc48o7wipSypcorPmA=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    gettext
    libnl
    libtraceevent
    libtracefs
    ncurses
    pciutils
    zlib
  ];

  postPatch = ''
    substituteInPlace src/main.cpp --replace-fail "/sbin/modprobe" "modprobe"
    substituteInPlace src/calibrate/calibrate.cpp --replace-fail "/usr/bin/xset" "${lib.getExe xorg.xset}"
    substituteInPlace src/tuning/bluetooth.cpp --replace-fail "/usr/bin/hcitool" "hcitool"
  '';

  meta = {
    homepage = "https://github.com/fenrus75/powertop";
    description = "Analyze power consumption on Intel-based laptops (master branch)";
    mainProgram = "powertop";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
