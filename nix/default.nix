{
  buildGoApplication,
  pkgs,
  lib,
  ux,
}:
buildGoApplication {
  pname = "a2b";
  version = "0.0.1";
  src = lib.cleanSource ./..;
  modules = ./gomod2nix.toml;

  checkPhase = ''
    go test ./... -ginkgo.label-filter="!E2E"
  '';
}
