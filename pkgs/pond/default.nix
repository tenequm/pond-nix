{ lib, fetchurl, stdenv, autoPatchelfHook, zlib }:
let
  inherit (stdenv) hostPlatform;
  inherit (hostPlatform) system;
  version = "0.7.0";
  shaMap = {
    x86_64-linux = "0d05bvn1cm60cfjmlrjjpr9pwkm9dfp0sif65dx2nb82lzs6q80c";
    aarch64-linux = "1vn8rla9p9z2nn0r2dkqxkcwwv2fvs0q6fj6s4hflh6aaa4f5vkw";
    aarch64-darwin = "14ijpdj4c4kvccvsnnzk4hasbfx64grnjxbykmkxrci10cd4md3k";
  };
  urlMap = {
    x86_64-linux = "https://github.com/tenequm/pond-nix/releases/download/pond-v0.7.0/pond-x86_64-unknown-linux-gnu.tar.xz";
    aarch64-linux = "https://github.com/tenequm/pond-nix/releases/download/pond-v0.7.0/pond-aarch64-unknown-linux-gnu.tar.xz";
    aarch64-darwin = "https://github.com/tenequm/pond-nix/releases/download/pond-v0.7.0/pond-aarch64-apple-darwin.tar.xz";
  };
in
stdenv.mkDerivation {
  pname = "pond";
  inherit version;

  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  # Prebuilt glibc ELF won't run on NixOS until its interpreter and RPATH
  # are rewritten to Nix-store paths; darwin Mach-O needs no patching.
  nativeBuildInputs = lib.optionals hostPlatform.isLinux [ autoPatchelfHook ];

  # The released Linux build is CPU-only candle + vendored onig + rustls,
  # so the sole dynamic deps beyond glibc are libgcc_s/libstdc++.
  buildInputs = lib.optionals hostPlatform.isLinux [ stdenv.cc.cc.lib zlib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 pond $out/bin/pond
    runHook postInstall
  '';

  meta = {
    description = "Lossless storage and hybrid search for sessions from any AI agent client";
    homepage = "https://pond.cascade.fyi/";
    changelog = "https://github.com/tenequm/pond-nix/releases/tag/pond-v${version}";
    license = lib.licenses.asl20;
    mainProgram = "pond";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];
    maintainers = with lib.maintainers; [ ];
  };
}
