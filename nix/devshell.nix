{
  kotlin-language-server,
  llvmPackages_21,
  gradle_9,
  mkShell,
  openssl,
  wayland,
  stdenv,
  jdk25,
  lib,
  icu,
  ... # capture inputs
}:
mkShell {
  buildInputs = [
    llvmPackages_21.lldb
    llvmPackages_21.clang
    kotlin-language-server
    gradle_9
    jdk25
  ];

  nativeBuildInputs = [
    openssl
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
    icu
  ];
}
