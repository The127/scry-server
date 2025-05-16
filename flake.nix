{
  description = "Project flake with fswatch and tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux"; # adapt if needed
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.just
            pkgs.hurl
            pkgs.nim
            pkgs.nimble
          ];
        };
      };
    };
  };
}
