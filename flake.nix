{
  description = "My gleam monorepo";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # nix-gleam.url = "github:arnarg/nix-gleam";
    nix-gleam.url = "github:silasbrack/nix-gleam";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-gleam,
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            nix-gleam.overlays.default
          ];
        };
        matcha = pkgs.rustPlatform.buildRustPackage rec {
          pname = "matcha";
          version = "0.19.0";
          nativeBuildInputs = with pkgs; [ pkg-config ];

          src = pkgs.fetchFromGitHub {
            owner = "michaeljones";
            repo = pname;
            rev = version;
            hash = "sha256-Yz1eGbE97NsEA/mKlo1y19w8Dp0r+548XeSeCfFoRFQ=";
          };
          cargoHash = "sha256-7wFu0B39mIp54I0PA0F/IIdu7oF976cotsISnEU+oEc=";
        };
      in
      {
        packages.default = pkgs.buildGleamApplication {
          src = ./.;
          erlangPackage = pkgs.erlang_27;
        };
        devShells.default = pkgs.mkShell {
          packages = [ matcha ];
          buildInputs = with pkgs; [
            gleam
            erlang_27
            rebar3
            inotify-tools
            nodejs_22
          ];
        };
      }
    ));
}
