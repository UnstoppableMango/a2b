{
  pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix;
    in
    import (fetchTree nixpkgs.locked) {
      overlays = [
        (import "${fetchTree gomod2nix.locked}/overlay.nix")
      ];
    }
  ),
  buildGoApplication ? pkgs.buildGoApplication,
}:

buildGoApplication {
  pname = "a2b";
  version = "0.0.1";
  src = pkgs.lib.cleanSource ./.;
  modules = ./gomod2nix.toml;

  checkPhase = ''
    go test ./... -ginkgo.label-filter="!E2E"
  '';
}
