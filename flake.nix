{
  description = "My gleam monorepo";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-gleam.url = "github:arnarg/nix-gleam";
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
      in
      {
        packages.default = pkgs.buildGleamApplication {
          src = ./.;
          erlangPackage = pkgs.erlang_27;
        };
        # apps.default = {
        #   type = "app";
        #   program = "${}/bin/my";
        # };
        devShells.system.default = {
          buildInputs = [
            pkgs.gleam
            pkgs.erlang_27
            pkgs.rebar3
            pkgs.inotify-tools
            pkgs.nodejs_22
          ];
        };
      }
    ));
}
