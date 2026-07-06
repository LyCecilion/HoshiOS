{
  description = "HoshiOS x86 toy operating system development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          llvm = pkgs.llvmPackages;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.qemu
              pkgs.nasm
              llvm.clang-unwrapped
              llvm.lld
              llvm.llvm
              pkgs.gdb
              llvm.clang-tools
              pkgs.gnumake
              pkgs.coreutils
            ];
          };
        });
    };
}
