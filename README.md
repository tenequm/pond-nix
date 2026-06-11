# pond-nix

Nix flake for [pond](https://pond.cascade.fyi/) - lossless session storage and hybrid search for AI agent clients.

The flake packages the official prebuilt pond binaries (hosted in this repo's releases). No compilation: it fetches the release tarball for your platform and patches it for Nix.

## Supported systems

- `aarch64-darwin` (Apple Silicon macOS)
- `x86_64-linux`
- `aarch64-linux`

There is no `x86_64-darwin` (Intel macOS) build.

## Run without installing

```sh
nix run github:tenequm/pond-nix -- --help
```

## Install into a profile

```sh
nix profile install github:tenequm/pond-nix
```

## Use as a flake input

```nix
{
  inputs.pond.url = "github:tenequm/pond-nix";

  # In your outputs, either pull the package directly:
  #   pond.packages.${system}.default
  # or apply the overlay so `pkgs.pond` resolves:
  #   nixpkgs.overlays = [ pond.overlays.default ];
}
```

## Develop / smoke-test

```sh
nix flake check        # builds the package and runs `pond --version`
nix build              # builds the package for the current system
```
