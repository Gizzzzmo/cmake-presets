{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        nativeBuildInputs = with pkgs; [cmake];
        buildInputs = [];
        packages = with pkgs; [
          alejandra
          mdformat
          python313Packages.mdformat-gfm
          neocmakelsp
          cmake
          clang
          clang-tools
          gcc
          ninja
        ];
      in
        with pkgs; {
          devShells.default = mkShell {
            inherit buildInputs nativeBuildInputs packages;
            shellHook = ''
              export DEFAULT_PROFILE=nix_clang
            '';
          };
        }
    );
}
