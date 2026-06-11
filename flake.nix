{
  description = "pond - lossless session storage and hybrid search for AI agent clients";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # pond ships prebuilt binaries only for these three; there is no
      # x86_64-darwin build, so it is deliberately absent from the list.
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake.overlays.default = final: _prev: {
        pond = final.callPackage ./pkgs/pond { };
      };

      perSystem =
        { pkgs, self', ... }:
        {
          packages.pond = pkgs.callPackage ./pkgs/pond { };
          packages.default = self'.packages.pond;

          apps.pond = {
            type = "app";
            program = "${self'.packages.pond}/bin/pond";
            meta.description = "Run the pond CLI";
          };
          apps.default = self'.apps.pond;

          checks.smoke = pkgs.runCommand "pond-smoke" { } ''
            ${self'.packages.pond}/bin/pond --version
            touch "$out"
          '';
        };
    };
}
