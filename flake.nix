{
  description = "n2n packaged for nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    n2n = {
      url = "github:ntop/n2n/dev";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        packages.n2n = pkgs.stdenv.mkDerivation {
          name = "n2n";
          version = inputs.n2n.shortRev;
          src = inputs.n2n;

          nativeBuildInputs = with pkgs; [
            autoreconfHook
            pkg-config
          ];
          buildInputs = with pkgs; [openssl libcap zstd];

          postPatch = ''
            patchShebangs autogen.sh
          '';

          preAutoreconf = ''
            ./autogen.sh
          '';

          configureFlags = [
            "--with-zstd"
            "--with-openssl"
            "--enable-cap"
          ];

          PREFIX = placeholder "out";
        };
      }
    );
}
