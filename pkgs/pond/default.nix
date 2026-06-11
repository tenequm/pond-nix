{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
  zlib,
}:
let
  inherit (stdenv) hostPlatform;
  inherit (hostPlatform) system;
  version = "0.6.0";
  base = "https://github.com/tenequm/pond-nix/releases/download/pond-v${version}";
  shaMap = {
    x86_64-linux = "44a43ab89272298c52323dca844da011e9c20c35cda94ad2a49de548fefdb553";
    aarch64-linux = "abde632155918f345c1eb816759c9d3ba5c49b53a0fdf6803e9c84f17a6fcf6e";
    aarch64-darwin = "b4631b3ed6701ebd4322cf55ab14c21304c0592f785ee21555e16dbab683a143";
  };
  urlMap = {
    x86_64-linux = "${base}/pond-x86_64-unknown-linux-gnu.tar.xz";
    aarch64-linux = "${base}/pond-aarch64-unknown-linux-gnu.tar.xz";
    aarch64-darwin = "${base}/pond-aarch64-apple-darwin.tar.xz";
  };
in
stdenv.mkDerivation {
  pname = "pond";
  inherit version;

  src = fetchurl {
    url = urlMap.${system} or (throw "pond: no prebuilt binary for ${system}");
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  # Prebuilt glibc ELF won't run on NixOS until its interpreter and RPATH are
  # rewritten to Nix-store paths; the darwin Mach-O needs no patching.
  nativeBuildInputs = lib.optionals hostPlatform.isLinux [ autoPatchelfHook ];

  # The released Linux build is CPU-only candle + vendored onig + rustls, so the
  # sole dynamic deps beyond glibc are libgcc_s/libstdc++ (cc.cc.lib) and zlib.
  buildInputs = lib.optionals hostPlatform.isLinux [
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 pond "$out/bin/pond"
    runHook postInstall
  '';

  meta = {
    description = "Lossless storage and hybrid search for sessions from any AI agent client";
    homepage = "https://pond.cascade.fyi/";
    changelog = "https://github.com/tenequm/pond-nix/releases/tag/pond-v${version}";
    license = lib.licenses.asl20;
    mainProgram = "pond";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames urlMap;
  };
}
