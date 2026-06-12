{ lib, fetchurl, stdenv, autoPatchelfHook, installShellFiles, zlib }:
let
  inherit (stdenv) hostPlatform;
  inherit (hostPlatform) system;
  version = "0.8.0";
  shaMap = {
    x86_64-linux = "1dyl1lgrsprvc0yzkvm8lb5gpyk4rl0ppzhjxqrcqyq3ls4g15mn";
    aarch64-linux = "1mfywj747b1gs4dym4vxnh70sy94gys30svdv28yz3671shnivmj";
    aarch64-darwin = "1hnaqxsdmn3g71xk02wxa6r9pmcbjdihrkgd63f8xsr6yb752bm0";
  };
  urlMap = {
    x86_64-linux = "https://github.com/tenequm/pond-nix/releases/download/pond-v0.8.0/pond-x86_64-unknown-linux-gnu.tar.xz";
    aarch64-linux = "https://github.com/tenequm/pond-nix/releases/download/pond-v0.8.0/pond-aarch64-unknown-linux-gnu.tar.xz";
    aarch64-darwin = "https://github.com/tenequm/pond-nix/releases/download/pond-v0.8.0/pond-aarch64-apple-darwin.tar.xz";
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
  nativeBuildInputs = [ installShellFiles ] ++ lib.optionals hostPlatform.isLinux [ autoPatchelfHook ];

  # The released Linux build is CPU-only candle + vendored onig + rustls,
  # so the sole dynamic deps beyond glibc are libgcc_s/libstdc++.
  buildInputs = lib.optionals hostPlatform.isLinux [ stdenv.cc.cc.lib zlib ];

  # Completions ship pre-generated in the tarball: the binary can't
  # run here (autoPatchelfHook rewrites the interpreter later, in
  # fixupPhase).
  installPhase = ''
    runHook preInstall
    install -Dm755 pond $out/bin/pond
    installShellCompletion --bash completions/pond.bash --zsh completions/_pond --fish completions/pond.fish
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
